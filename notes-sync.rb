#!/usr/bin/env ruby

require_relative 'upload_attachments'
require 'pry'

notes_path = File.expand_path('~/notes')

upload_attachments

Dir.chdir(notes_path) do
  system('git pull')

  system('git add .')

  commit_message = "Update notes - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  system("git commit -m '#{commit_message}'")

  system('git push')
end

