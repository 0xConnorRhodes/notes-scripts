-- CONFIG
local notesPath = ""
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/zk_notes'
end

-- FUNCTIONS
local function getFiles(folder)
    local files = {}
    for file in io.popen('ls '..folder):lines() do
        local fileName = file:gsub(notesPath..'/', ''):gsub('.md$', '')
        table.insert(files, fileName)
    end
    return files
end

local function fzfListFiles(filesString, taskOperation)
    local fileName = io.popen('echo "'..filesString..'" | fzf --prompt='..taskOperation:upper()..':'):read()
    local fileName = fileName..'.md'
    return fileName
end

local function generateOriginalLink(inputString)
    -- take filename and return [[✅ wikilink]]
    local transformedString = inputString:gsub("%.md$", "")
    local result = "[["..transformedString.."]]"
    return result
end

local function generateArchivedLinks(inputString, taskOperation)
    local strippedExtension = inputString:gsub("%.md$", "")
    local taskFolderName = taskOperation:sub(3)
    local possibleLinks = {}
    possibleLinks.noAlias = "[[_tk/"..taskFolderName..'/'..strippedExtension.."]]"
    possibleLinks.withAlias = "[[_tk/"..taskFolderName..'/'..strippedExtension.."|"..strippedExtension.."]]"
    return possibleLinks
end

local function generateArchiveFilename(inputString)
    local utcTime = os.time(os.date("!*t"))
    local centralOffset = -6 * 3600
    local centralTime = utcTime + centralOffset
    local date = os.date("%y%m%d", centralTime)

    local done_file = string.gsub(inputString, "✅ ", date..'-')
    return done_file
end

local function findTaskReferences(directory, pattern)
    -- generate a file handle with files that contain the pattern (standard out from ripgrep)
    local grep_command = 'rg -F -l --color=never "'..pattern..'" "'..directory..'"'
    local handle = io.popen(grep_command)
    local matching_files = handle:read("*a")
    handle:close()

    -- iterate through each line of the file handle and put each line into a table (except for the trailing newline)
    local matching_files_table = {}
    for line in matching_files:gmatch("([^\n]*)\n?") do
        if line ~= "" then
            table.insert(matching_files_table, line)
        end
    end

    return matching_files_table
end

local function renameDoneTaskReferences(noteTable, operation, taskLink, doneFile)
    -- escape square brackets for sed command
    local escaped_str = taskLink:gsub("%[", "\\["):gsub("%]", "\\]")
    -- generate relative link to filed done task
    local replacement_str = '\\[\\[_tk\\/'..operation..'\\/'..doneFile:gsub("%.md$", "")..'\\]\\]'

    for _, note in ipairs(noteTable) do
        local sed_cmd = "sed -i 's/"..escaped_str.."/"..replacement_str.."/g'"..' "'..note..'"'
        os.execute(sed_cmd)
    end
end

local function renameUndoneTaskReferences(noteTable, operation, taskLink, doneFile)
    -- escape existing string for sed command
    local escaped_str = taskLink:gsub("%[", "\\["):gsub("%]", "\\]"):gsub("%/", "\\/")
    -- generate new link
    -- local replacement_str = '\\[\\[_tk\\/'..operation..'\\/'..doneFile:gsub("%.md$", "")..'\\]\\]'

    local startIndex = taskLink:find('-') + 1
    local taskName = ''
    local pipeIndex = taskLink:find('|')
    local bracketIndex = taskLink:find(']')
    if pipeIndex then
        taskName = taskLink:sub(startIndex, pipeIndex-1)
    else
        taskName = taskLink:sub(startIndex, bracketIndex-1)
    end

    local replacement_str = '\\[\\['..doneFile:gsub("%.md$", "")..'\\]\\]'

    for _, note in ipairs(noteTable) do
        -- local sed_cmd = "sed -i 's/"..escaped_str.."/"..replacement_str.."/g'"..' "'..note..'"'
        local sed_cmd = string.format("sed -i 's/%s/%s/g' %s", escaped_str, replacement_str, note)
        os.execute(sed_cmd)
    end
end

local function moveFile(operation, startFile, endFile, folder)
    local sourcePath = folder..'/'..startFile
    local destPath = folder..'/_tk/'..operation..'/'..endFile
    local command = string.format("mv '%s' '%s'", sourcePath, destPath)
    os.execute(command)
end

local function unMoveFile(filePath, subFolder, startFile)
    local sourcePath = filePath..'/_tk/'..subFolder..'/'..startFile
    local destFile = '✅ '..startFile:sub(8)
    local destPath = filePath..'/'..destFile
    local command = string.format("mv '%s' '%s'", sourcePath, destPath)
    os.execute(command)
end

local function stringInTable(str, tbl)
    for _, value in pairs(tbl) do
        if value == str then
            return true
        end
    end
    return false
end

-- LOGIC
local taskOperation = arg[1]
if #arg == 0 then
    print('No argument specified')
    print("Usage: modify-task.lua [done|drop|undone|undrop]")

elseif taskOperation == 'done' or
       taskOperation == 'drop' or
       taskOperation == 'hold' then
    local filesString = table.concat(getFiles(notesPath..'/✅*'), '\n') -- prepare string for fzf input
    local selectedFile = fzfListFiles(filesString, taskOperation)
    local task_link = generateOriginalLink(selectedFile)
    local done_filename = generateArchiveFilename(selectedFile)
    local files = findTaskReferences(notesPath, task_link)

    renameDoneTaskReferences(files, taskOperation, task_link, done_filename)
    moveFile(taskOperation, selectedFile, done_filename, notesPath)
    print(taskOperation:upper()..': '..selectedFile:gsub('.md', ''))
elseif taskOperation == 'undone' or
       taskOperation == 'undrop' or
       taskOperation == 'unhold' then
    local subFolderName = taskOperation:sub(3)
    local filesString = table.concat(getFiles(notesPath..'/_tk/'..subFolderName), '\n')
    local selectedFile = fzfListFiles(filesString, taskOperation)

    local taskLinks = generateArchivedLinks(selectedFile, taskOperation)

    local filesWithLinks = {}
    for _, v in pairs(taskLinks) do
        local files = findTaskReferences(notesPath, v)
        for _, v in pairs(files) do
            if not stringInTable(v, filesWithLinks) then
                table.insert(filesWithLinks, v)
            end
        end
    end

    -- now I have a deduplicated list of all files with either link format present in them
    for _, v in pairs(filesWithLinks) do
        print(v)
        -- rename task references (no need for operation, so a new function?)
        -- renameTaskReferences(files, taskOperation, taskLink, done_filename)
    end

    -- unMoveFile(notesPath, subFolderName, selectedFile)
    -- print(taskOperation:upper()..': '..selectedFile:gsub('.md', ''))
end