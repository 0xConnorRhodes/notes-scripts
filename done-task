if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/zk_notes'
end

-- Function to get a list of files starting with ✅ in the specified directory
function getFiles()
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

print(selectedFile)

-- vim:syntax=lua