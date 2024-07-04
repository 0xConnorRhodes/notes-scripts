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

local function renameTaskReferences(noteTable, operation, taskLink, doneFile)
    local escaped_str = taskLink:gsub("%[", "\\["):gsub("%]", "\\]")
    local replacement_str = '\\[\\[_tk\\/'..operation..'\\/'..doneFile:gsub("%.md$", "")..'\\]\\]'

    for _, note in ipairs(noteTable) do
        local sed_cmd = "sed -i 's/"..escaped_str.."/"..replacement_str.."/g'"..' "'..note..'"'
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

    renameTaskReferences(files, taskOperation, task_link, done_filename)
    moveFile(taskOperation, selectedFile, done_filename, notesPath)
    print(taskOperation:upper()..': '..selectedFile:gsub('.md', ''))
elseif taskOperation == 'undone' or
       taskOperation == 'undrop' or
       taskOperation == 'unhold' then
    local subFolderName = taskOperation:sub(3)
    local filesString = table.concat(getFiles(notesPath..'/_tk/'..subFolderName), '\n')
    local selectedFile = fzfListFiles(filesString, taskOperation)
    -- TODO: renameTaskReferences with correct *un* behavior
    unMoveFile(notesPath, subFolderName, selectedFile)
    print(taskOperation:upper()..': '..selectedFile:gsub('.md', ''))
end