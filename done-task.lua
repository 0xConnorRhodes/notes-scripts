if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/zk_notes'
end

-- Function to get a list of files starting with ✅ in the specified directory
local function getFiles()
    local files = {}
    for file in io.popen('ls ' .. notesPath .. '/✅*'):lines() do
        local fileName = file:match(".+/([^/]+)$")  -- Extract only the file name
        table.insert(files, fileName)
    end
    return files
end

-- Get the list of files
local files = getFiles()

-- Prepare a string with all file names for fzf input
local filesString = table.concat(files, '\n')

-- Run fzf to let the user select a file
local selectedFile = io.popen('echo "' .. filesString .. '" | fzf'):read()

local function generateOriginalLink(input_string)
    -- Remove the file extension from the string
    local transformedString = input_string:gsub("%.md$", "")
    
    -- Surround the transformed string with [[ and ]]
    local result = "[["..transformedString.."]]"
    
    return result
end

local function findTaskReferences(directory, pattern)
    local files = {}
    local p = io.popen('ls "'..directory..'"/*.md')

    for file in p:lines() do
        local grep_command = 'rg -F -l -q --color=never "'..pattern..'" "'..file..'"'
        if os.execute(grep_command) then
            table.insert(files, file)
        end
    end

    p:close()
    return files
end

function moveDoneFile()
    -- should return new relative path from the notes directory to the _done folder
end

local files = findTaskReferences(notesPath, generateOriginalLink(selectedFile))
-- print(generateOriginalLink(selectedFile))

for _, file in pairs(files) do
    print(file)
end

-- vim:syntax=lua