notesPath = os.getenv("HOME")..'/notes'

local fzfFilesTbl = {}
for file in io.popen(('ls %s'):format(notesPath)):lines() do
    local fileName = file:gsub(notesPath..'/', ''):gsub('.md$', '')
    if fileName:match('🖥️') then
	    fileName = fileName:gsub('🖥️','🖥️ ')
        print('true')
    end
    table.insert(fzfFilesTbl, fileName)
end
local fzfFilesStr = table.concat(fzfFilesTbl, '\n')

local fileChoiceStr = io.popen(
    string.format('echo "%s" | fzf', fzfFilesStr)
):read('*a')

local fileChoiceStrip = fileChoiceStr:sub(1, #fileChoiceStr-1)

if fileChoiceStrip:match('🖥️ ') then
    fileChoiceStrip = fileChoiceStrip:gsub('🖥️ ','🖥️')
end

command = ('nvim "%s"'):format(notesPath..'/'..fileChoiceStrip..'.md')
os.execute(command)