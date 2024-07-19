-- CONFIG
local notesPath = ''
if os.getenv('HOSTNAME') == 'devct' then
    notesPath = os.getenv("HOME")..'/notes'
elseif os.getenv("TERMUX_APP_PID") then
    notesPath = os.getenv("HOME")..'/storage/dcim/notes'
end

-- FUNCTIONS
local function get_input(prompt)
    io.write(prompt..': ')
    return io.read():gsub('%s$', '')
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

-- LOGIC
print('Adding New Task:')
local task_name = get_input('task')
local note = get_input('note')
local due_date = get_input('due')

if #task_name == 0 then
    print('no task')
    os.exit(0)
end

local filename = 'tk_'..task_name..'.md'
local filepath = notesPath..'/'..filename

local formattedContent = [[]]

if #due_date > 0 then
    formattedContent = formattedContent..'---\ndue_date: '..due_date..'\n---'
end

if #note > 0 then
    if #due_date > 0 then
        formattedContent = formattedContent..'\n\n'..note
    else
        formattedContent = formattedContent..note
    end
end

if not file_exists(filepath) then
    local file = io.open(filepath, "w")
    file:write(formattedContent)
    file:close()
    print('wrote: '..filename)
else
    print('file already exists')
end