require('modules.lua.get-platform')

local savePath = NotesPath..'/s'

io.write('Name: ')
local saveName = io.read('*l')

local saveFileName = saveName..'.md'

local saveFilePath = savePath..'/'..saveFileName

local testFile = io.open(saveFilePath, 'r')
if not testFile then
    os.execute(string.format('touch "%s"', saveFilePath))
    print('Created: '..saveFilePath)
else
    print('Error: '..saveFileName..' already exists')
    testFile:close()
end