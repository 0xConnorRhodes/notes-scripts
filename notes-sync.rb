#!/usr/bin/env ruby

notes_path = File.expand_path('~/notes')

Dir.chdir(notes_path) do
  system('git pull')

  system('git add .')

  commit_message = "Update notes - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  system("git commit -m '#{commit_message}'")

  system('git push')
end

