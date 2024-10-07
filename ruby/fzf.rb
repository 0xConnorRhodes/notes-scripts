def fzf(args = '-m')
  io = IO.popen('fzf ' + args, 'r+')
  begin
    stdout, $stdout = $stdout, io
    yield rescue nil
  ensure
    $stdout = stdout
  end
  io.close_write
  io.readlines.map(&:chomp)
end

# result = fzf { puts [1, 2, 3, 4 ]}