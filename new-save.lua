require('modules.lua.get-platform')

local savePath = NotesPath..'/s'

io.write('Name: ')
local saveName = io.read('*l')

local saveFileName = saveName..'.md'

local saveFilePath = savePath..'/'..saveFileName

local testFile = io.open(saveFilePath, 'r')
if not testFile then
    os.execute(string.format('touch "%s"', saveFilePath))
else
    print('Error: '..saveFileName..' already exists')
    testFile:close()
end

if Platform == 'Android' then
    os.execute(string.format('termux-open "%s"', saveFilePath))
elseif Platform == 'devct' then
    os.execute(string.format('nvim -c "startinsert" "%s"', saveFilePath))
else
    print('Created: '..saveFilePath)
end