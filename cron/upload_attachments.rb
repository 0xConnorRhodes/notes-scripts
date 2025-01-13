#!/usr/bin/env ruby

require 'dotenv/load'

notes_dir = ENV['NOTES_DIR']
remote_dir = ENV['REMOTE_DIR']

attachments = Dir.glob(File.join(notes_dir, 'zattachments', '*'))
attachments = attachments.map {|f| File.basename(f)}

remote_files = `rsync --list-only '#{remote_dir}/'`.split("\n").map { |line| line.split.last }

attachments.each do |attachment|
  remote_filename = attachment.downcase.gsub(' ', '-')
  remote_filename = remote_filename.gsub(/[\(\)\[\]'"]/, '') # strip problematic characters

  if remote_files.include?(remote_filename)
    puts "Warning: #{remote_filename} already exists on remote, exiting"
    exit 1
  end

  upload = false
  file_data = {
    wiki_link_files: `rg -F -l "zattachments/#{attachment}]]" "#{notes_dir}"`.split("\n"),
    md_link_files: `rg -F -l "zattachments/#{attachment})" "#{notes_dir}"`.split("\n"),
    wiki_short_link_files: `rg -F -l "![[#{attachment}]]" "#{notes_dir}"`.split("\n"),
  }

  # skip dangling attachments
  files = file_data[:wiki_link_files] + file_data[:md_link_files] + file_data[:wiki_short_link_files]
  if files.count == 0
    present_files = `rg -F -l "#{attachment}" "#{notes_dir}"`.split("\n")
    puts "No files found for #{attachment}, removing"
    `rm "#{notes_dir}/zattachments/#{attachment}"` if present_files.count == 0
    next
  end

  remote_filename = attachment.downcase.gsub(' ', '-')
  remote_filename = remote_filename.gsub(/[\(\)\[\]'"]/, '') # strip problematic characters

  file_data[:wiki_link_files].each do |file_path|
    file_content = File.read(file_path)
    # match any amount of ../ in relative path
    pattern = /!?\[\[(?:\.\.\/)*zattachments\/#{attachment}\]\]/
    matches = file_content.scan(pattern)
    matches.uniq.each do |match|
      puts "replacing #{match} in #{file_path}"
      new_link = "![](#{ENV['STATIC_URL']}/#{remote_filename}?#{ENV['ACCESS_TOKEN']})"
      File.write(file_path, file_content.gsub(match, new_link))
      upload = true
    end
  end

  file_data[:md_link_files].each do |file_path|
    file_content = File.read(file_path)
    # match any amount of ../ in relative path and any link text
    pattern = /!?\[[^\]]*\]\((?:\.\.\/)*\/?zattachments\/#{attachment}\)/
    matches = file_content.scan(pattern)
    matches.uniq.each do |match|
      puts "replacing #{match} in #{file_path}"
      new_link = "![](#{ENV['STATIC_URL']}/#{remote_filename}?#{ENV['ACCESS_TOKEN']})"
      File.write(file_path, file_content.gsub(match, new_link))
      upload = true
    end
  end

  file_data[:wiki_short_link_files].each do |file_path|
    file_content = File.read(file_path)
    # match any amount of ../ in relative path
    search_string = "![[#{attachment}]]"
    if file_content.include?(search_string)
      puts "replacing #{search_string} in #{file_path}"
      new_link = "![](#{ENV['STATIC_URL']}/#{remote_filename}?#{ENV['ACCESS_TOKEN']})"
      File.write(file_path, file_content.gsub(search_string, new_link))
      upload = true
    end
  end

  if upload
    puts "Uploading #{attachment}"
    puts `rsync --remove-source-files '#{notes_dir}/zattachments/#{attachment}' '#{remote_dir}/#{remote_filename}'`
  end
end
