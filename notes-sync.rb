#!/usr/bin/env ruby

notes_path = File.expand_path('~/notes')

Dir.chdir(notes_path) do
  # Add all changes
  system('git add .')

  # Commit with a message
  commit_message = "Update notes - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  system("git commit -m '#{commit_message}'")

  # Push the changes
  system('git push')
end

