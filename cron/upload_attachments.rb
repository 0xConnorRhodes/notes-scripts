require 'dotenv/load'

notes_dir = ENV['NOTES_DIR']
remote_dir = ENV['REMOTE_DIR']

attachments = Dir.glob(File.join(notes_dir, 'zattachments', '*'))
attachments = attachments.map {|f| File.basename(f)}

# for each local_attachment, check if it is linked in the notes
# requirements: check for relative and name link for wiki-link and markdown link
count = 0
attachments.each do |attachment|
  count += 1
  puts "Processing item #{count}"

  upload = false
  file_data = {
    wiki_link_files: `rg -F -l "zattachments/#{attachment}]]" "#{notes_dir}"`.split("\n"),
    md_link_files: `rg -F -l "zattachments/#{attachment})" "#{notes_dir}"`.split("\n"),
  }

  # skip dangling attachments
  files = file_data[:wiki_link_files] + file_data[:md_link_files]
  if files.count == 0
    # puts "No files found for #{attachment}"
    # `rm "#{notes_dir}/zattachments/#{attachment}"`
    next
  end

  remote_filename = attachment.downcase.gsub(' ', '-')
  remote_filename = remote_filename.gsub(/[\(\)\[\]'"]/, '') # strip problematic characters

  file_data[:wiki_link_files].each do |file_path|
    file_content = File.read(file_path)
    link = "![[zattachments/#{attachment}]]"
    if file_content.include?(link)
      puts "replacing #{link} in #{file_path}"
      new_link = "![](#{ENV['STATIC_URL']}/#{remote_filename}?#{ENV['ACCESS_TOKEN']})"
      File.write(file_path, file_content.gsub(link, new_link))
      upload = true
    end
  end

  # TODO: logic for md links

  if upload
    puts "Uploading #{attachment}"
    puts `rsync --remove-source-files '#{notes_dir}/zattachments/#{attachment}' '#{remote_dir}/#{remote_filename}'`
  end
end
