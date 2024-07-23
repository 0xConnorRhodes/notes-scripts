local notesPath = ''
local platform = ''
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
    platform = 'devct'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/notes'
    platform = 'Android'
end

local savePath = notesPath..'/s'

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

if platform == 'Android' then
    os.execute(string.format('termux-open "%s"', saveFilePath))
elseif platform == 'devct' then
    os.execute(string.format('nvim -c "startinsert" "%s"', saveFilePath))
else
    print('Created: '..saveFilePath)
end