local notesPath = ""
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/zk_notes'
end

local taskOperation = arg[1]
if #arg == 0 then
    print('No argument specified')
    print("Usage: modify-task.lua [done|drop|undone|undrop]")

elseif taskOperation == 'done' or
       taskOperation == 'drop' or
       taskOperation == 'hold' then

-- #region Select With Fzf -> table of filenames
    local fzfFilesTbl = {}
    for file in io.popen(string.format('ls %s/✅*', notesPath)):lines() do
        local fileName = file:gsub(notesPath..'/', ''):gsub('.md$', '')
        table.insert(fzfFilesTbl, fileName)
    end
    local fzfFilesStr = table.concat(fzfFilesTbl, '\n')

    local fileChoicesStr = io.popen(
        string.format('echo "%s" | fzf -m --prompt=%s', fzfFilesStr, taskOperation:upper()..':')
    ):read('*a')

    local fileChoicesTbl = {}
    for line in fileChoicesStr:gmatch("([^\n]+)") do
        table.insert(fileChoicesTbl, line:gsub('\n','')..'') -- last concat needed to squash number returned by gsub
    end
-- #endregion

-- #region rename references
    for _, v in pairs(fileChoicesTbl) do
        print(v)
    end
-- [ ] generate the link to look for
-- [ ] find files with that link
-- [ ] replace that content in those files
-- #endregion

-- #region move file and print status
-- [ ] move file
-- [ ] print status
-- #endregion
end -- end of elseif done|drop|hold