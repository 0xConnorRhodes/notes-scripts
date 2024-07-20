--#region CONFIG
local notesPath = ''
local platform = ''
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/notes'
    platform = 'Android'
end

local template = [[{{account_link}}
# Folks

# Context

# Log]]
--#endregion

--#region Generate Note Content
local account = (
    io.popen(
        ('cat "%s" | fzf'):format(notesPath..'/.vaccounts.list')
    ):read('*a'):gsub('\n$', '')
)

if #account == 0 then
    os.exit(1)
end

local date = os.date("%y%m%d", os.time())

io.write('desc: ')
local description = io.read():gsub('%s$', '')

local noteName = ('mt_%s %s %s'):format(date, account, description)
local noteNameExt = noteName..'.md'
--#endregion

--#region Render Template and Write Content
local outputFilePath = notesPath..'/'..noteNameExt

local renderedContent = template:gsub('{{account_link}}', '[['..account..']]')

local noteFile = io.open(outputFilePath, "w")
if noteFile then
    noteFile:write(renderedContent)
    noteFile:close()
    print(noteNameExt..' written successfully.')
else
    print("Error opening file for writing.")
end
--#endregion

-- #region Add Link from Parent Note
local accountFile = account..'.md'
local headerCheckCmd = ("rg '^# Meetings$' '%s'"):format(notesPath..'/'..accountFile)
local headerCheckResult = io.popen(headerCheckCmd):read('*a')

if #headerCheckResult > 0 then
    local accountFileReadHandle = io.open(notesPath..'/'..accountFile, 'r')
    local accountFileContent = accountFileReadHandle:read('*a')
    accountFileReadHandle:close()

    local meetingLink = '- [['..noteName..']]'

    local lines = {}
    for line in accountFileContent:gmatch("[^\r\n]+") do
        table.insert(lines, line)
        if line:match('# Meetings') then
            table.insert(lines, meetingLink)
        end
    end

    local newContent = table.concat(lines, '\n')

    local accountFileWriteHandle = io.open(notesPath..'/'..accountFile, 'w')
    accountFileWriteHandle:write(newContent)
    accountFileWriteHandle:close()
    print('Link added to parent file')
else
    print('WARNING: Unable to add link to account file, Meetings header not present')
end
-- #endregion

if platform == 'Android' then
    os.execute('termux-open '..notesPath..'/'..noteNameExt)
end