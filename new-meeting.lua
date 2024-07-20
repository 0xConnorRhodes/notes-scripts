-- #region CONFIG
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
-- #endregion

-- #region Generate Note Content
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

local noteName = ('mt_%s %s %s.md'):format(date, account, description)
-- #endregion

-- #region Render Template and Write Content
local outputFilePath = notesPath..'/'..noteName

local renderedContent = template:gsub('{{account_link}}', '[['..account..']]')

local file = io.open(outputFilePath, "w")
if file then
    file:write(renderedContent)
    file:close()
    print(noteName..' written successfully.')
else
    print("Error opening file for writing.")
end
eeeeeeeeeeeee

-- #region Add Link from Parent Note
-- TODO: check that the parent note has a heading named '^# Meetings'. If not, exit and warn

-- TODO: If '^# Meetings' is present then add a link to the note at the top of that heading

-- #endregion