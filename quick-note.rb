#!/usr/bin/env ruby
require 'fileutils'

template = <<~MD
  # 

MD

drafts_dir = File.expand_path('~/notes/df')
time = Time.now.strftime('%y%m%d%H%M%S')

File.write(File.join(drafts_dir, "#{time}.md"), template)

file_path = File.join(drafts_dir, "#{time}.md")

termux_test = ENV['TERMUX_APP_PID'] ? true : false
if termux_test
  system("termux-open #{file_path}")
else
  system("nvim +startinsert! #{file_path}")
end
