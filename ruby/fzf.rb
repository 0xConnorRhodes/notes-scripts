def fzf(collection, args = '')
  io = IO.popen('fzf ' + args, 'r+')
  begin
    collection.each { |item| io.puts(item) }
    io.close_write
    io.readlines.map(&:chomp)
    # results = io.readlines.map(&:chomp)
    # results.size == 1 ? results.first : results
  ensure
    io.close_write unless io.closed?
  end
end