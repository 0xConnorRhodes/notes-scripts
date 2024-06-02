local notesPath = ""
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/zk_notes'
end

local function getFiles()
    local files = {}
    for file in io.popen('ls ' .. notesPath .. '/✅*'):lines() do
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

function moveDoneFile()
    -- should return new relative path from the notes directory to the _done folder
end

-- BEGIN SCRIPT LOGIC
-- Get the list of files
local files = getFiles()

-- Prepare a string with all file names for fzf input
local filesString = table.concat(files, '\n')

-- Run fzf to let the user select a file
local selectedFile = io.popen('echo "' .. filesString .. '" | fzf'):read()

local files = findTaskReferences(notesPath, generateOriginalLink(selectedFile))
-- print(generateOriginalLink(selectedFile))

-- DEBUG
for _, file in pairs(files) do
    print(file)
end

-- vim:syntax=lua