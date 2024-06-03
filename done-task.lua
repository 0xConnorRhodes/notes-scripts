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
    for file in io.popen('ls '..folder..'/✅*'):lines() do
        local fileName = file:match(".+/([^/]+)$")  -- Extract only the file name
        table.insert(files, fileName)
    end
    return files
end

local function generateOriginalLink(input_string)
    -- Remove the file extension from the string
    local transformedString = input_string:gsub("%.md$", "")
    
    -- Surround the transformed string with [[ and ]]
    local result = "[["..transformedString.."]]"
    
    return result
end

local function generateDoneFilename(input_string)
    local date = os.date("%y%m%d")
    local done_file = string.gsub(input_string, "✅ ", date..'-')
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

local function renameTaskReferences(note_table, task_link, done_file)
    local escaped_str = task_link:gsub("%[", "\\["):gsub("%]", "\\]")
    local replacement_str = '\\[\\[_done\\/'..done_file:gsub("%.md$", "")..'\\]\\]'

    for _, note in ipairs(note_table) do
        local sed_cmd = "sed -i 's/"..escaped_str.."/"..replacement_str.."/g'"..' "'..note..'"'
        os.execute(sed_cmd)
    end
end

-- TODO
local function moveDoneFile(file, folder)
    -- should return new relative path from the notes directory to the _done folder
end

-- SCRIPT LOGIC
local filesString = table.concat(getFiles(notesPath), '\n') -- prepare string for fzf input
local selectedFile = io.popen('echo "'..filesString..'" | fzf'):read()
local task_link = generateOriginalLink(selectedFile)
local done_filename = generateDoneFilename(selectedFile)
local files = findTaskReferences(notesPath, task_link)

-- renameTaskReferences(files, task_link, done_filename)
-- moveDoneFile(selectedFile, notesPath)

-- DEBUG

-- vim:syntax=lua