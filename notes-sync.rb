#!/usr/bin/env ruby

require 'dotenv/load'
Dotenv.load(File.join(File.dirname(__FILE__), '.env'))
require_relative 'modules/upload_attachments'

$notes_path = File.expand_path('~/notes')

require 'pry'

upload_attachments

Dir.chdir($notes_path) do
  system('git pull')

  system('git add .')

  commit_message = "Update notes - #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  system("git commit -m '#{commit_message}'")

  system('git push')
end

