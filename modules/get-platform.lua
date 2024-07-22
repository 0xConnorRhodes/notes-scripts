if os.getenv('HOSTNAME') == 'devct' then
    NotesPath = os.getenv("HOME")..'/notes'
    Platform = 'devct'
elseif os.getenv("TERMUX_APP_PID") then
    NotesPath = os.getenv("HOME")..'/storage/dcim/notes'
    Platform = 'Android'
end