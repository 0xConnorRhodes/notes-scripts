--#region CONFIG
local notesPath = ''
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/notes'
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
local headerCheckResult = io.popen(headerCheckCmd):read("*a")

if #headerCheckResult > 0 then
    print('header present')
else
    print('WARNING: Unable to add link to account file, Meetings header not present')
end

-- TODO: If '^# Meetings' is present then add a link to the note at the top of that heading

-- #endregion