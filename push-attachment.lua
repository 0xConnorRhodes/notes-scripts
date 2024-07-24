local natsBucket = 'https://sfs.connorrhodes.com/nats'

local tokenFile = io.open(os.getenv('HOME')..'/code/notes-scripts/templates/.sfs-nats-token', 'r')

local natsToken = ''
if tokenFile then
    natsToken = tokenFile:read('*a'):gsub('\n$','')
    tokenFile:close()
else
    print('no token file')
    os.exit(1)
end

for _, file in ipairs(arg) do
    local baseName, extension = file:match('(.+)%.(.+)')

    print('Name for '..file)
    local newName = io.read()
    if #newName == 0 then
       newName = baseName
    end
    newName = newName:gsub("%s+$", "") -- remove trailing spaces
    newName = newName:lower()
    newName = newName:gsub('%s+', ' ')
    newName = newName:gsub(' ', '-')
    local newFile = newName..'.'..extension
    local uploadPath = 's:/zstore/static_files/nats/'..newFile
    local testCommand = string.format('rsync -q --dry-run "%s" > /dev/null 2>&1', uploadPath)
    local uploadCommand = string.format('rsync --remove-sent-files "%s" "%s"', file, uploadPath)
    local filePresent = os.execute(testCommand)
    if filePresent then
        print('file already uploaded')
        local embedLink = '![]('..natsBucket..'/'..newFile..'?'..natsToken..')'
        print(embedLink)
        os.exit()
    end
    os.execute(uploadCommand)
    local embedLink = '![]('..natsBucket..'/'..newFile..'?'..natsToken..')'
    print(embedLink)
end