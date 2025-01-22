#!/usr/bin/env ruby

require 'dotenv/load'
Dotenv.load(File.join(File.dirname(__FILE__), '.env'))
require_relative 'modules/upload_attachments'
require_relative 'modules/rename_temp_tasks'

$notes_path = File.expand_path('~/notes')

rename_temp_tasks

unless system('ping -c 1 -W 1 1.1.1.1 > /dev/null 2>&1')
  puts "No internet connection"
  exit
end

upload_attachments

Dir.chdir($notes_path) do
  system('git add .')

  commit_message = "Update notes - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  system("git commit -m '#{commit_message}'")

  system('git pull --rebase')

  system('git push')
end

