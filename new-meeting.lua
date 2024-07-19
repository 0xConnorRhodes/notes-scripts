-- #region CONFIG
local notesPath = ''
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/notes'
end
-- #endregion

-- TODO: pick account

-- TODO: generate meeting filename

-- TODO: create meeting file with link to parrent account

-- TODO: add link to meeting in the # meetings section of corresponding account note