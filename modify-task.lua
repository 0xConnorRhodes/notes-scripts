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
-- #region Select With Fzf -> table of tasks
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

-- #region rename references, move file
    for _, task in pairs(fileChoicesTbl) do
        local currentLink = "[["..task.."]]"
        local utcTime = os.time(os.date("!*t"))
        local centralOffset = -6 * 3600
        local centralTime = utcTime + centralOffset
        local date = os.date("%y%m%d", centralTime)
        local doneFilename = task:gsub("✅ ", date..'-')

        -- generate a file handle with files that contain the pattern (standard out from ripgrep)
        local grep_command = ('rg -F -l --color=never "%s" %s'):format(currentLink, notesPath)
        local handle = io.popen(grep_command)
        local matchingFiles = handle:read("*a"):gsub('\n$','')
        handle:close()
        
    for line in matchingFiles:gmatch("([^\n]+)") do
        -- escape square brackets for sed command
        local escapedStr = currentLink:gsub("%[", "\\["):gsub("%]", "\\]")
        -- generate relative link to filed done task
        local replacementStr = '\\[\\[_tk\\/'..taskOperation..'\\/'..doneFilename..'\\]\\]'
        
        local sedCmd = ("sed -i 's/%s/%s/g' '%s'"):format(escapedStr, replacementStr, line)
        os.execute(sedCmd)
    end
    -- move file
    local sourcePath = notesPath..'/'..task..'.md'
    local destPath = notesPath..'/_tk/'..taskOperation..'/'..doneFilename..'.md'
    local mvCmd = ("mv '%s' '%s'"):format(sourcePath, destPath)
    os.execute(mvCmd)
    print(taskOperation:upper()..': '..task)
    end
-- #endregion
-- end elseif done|drop|hold
elseif taskOperation == 'undone' or
       taskOperation == 'undrop' or
       taskOperation == 'unhold' then
-- #region Select With Fzf -> table of tasks
    local operationFolder = taskOperation:sub(3)
    local fzfFilesTbl = {}
    for file in io.popen(('ls %s/_tk/%s'):format(notesPath,operationFolder)):lines() do
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

-- #region rename references, move file
    for _, task in pairs(fileChoicesTbl) do
        local currentLinks = {}
        currentLinks.noAlias = '[[_tk/'..operationFolder..'/'..task..']]'
        currentLinks.withAlias = '[[_tk/'..operationFolder..'/'..task..'|'..task..']]'
        local doneFilename = '✅ '..task:sub(8)

        for _, link in pairs(currentLinks) do
            local grep_command = ('rg -F -l --color=never "%s" %s'):format(link, notesPath)
            local handle = io.popen(grep_command)
            local matchingFiles = handle:read("*a"):gsub('\n$','')
            handle:close()

            for line in matchingFiles:gmatch("([^\n]+)") do
                -- escape square brackets for sed command
                local escapedStr = link:gsub("%[", "\\["):gsub("%]", "\\]")
                -- generate relative link to filed done task
                local replacementStr = '\\[\\['..doneFilename..'\\]\\]'

                local sedCmd = ("sed -i 's#%s#%s#g' '%s'"):format(escapedStr, replacementStr, line)
                os.execute(sedCmd)
            end
        end

        -- move file
        local sourcePath = notesPath..'/_tk/'..operationFolder..'/'..task..'.md'
        local destPath = notesPath..'/'..doneFilename..'.md'
        local mvCmd = ("mv '%s' '%s'"):format(sourcePath, destPath)
        os.execute(mvCmd)

        print(taskOperation:upper()..': '..task)
    end
-- #endregion
-- end elseif undone|undrop|unhold
end