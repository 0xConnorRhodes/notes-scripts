def rename_temp_tasks
  temp_tasks = Dir.glob(File.join($notes_path, '_tk_*'))

  return if temp_tasks.length <= 1

  puts "Renaming temp tasks"

  # Sort by filename and remove the most recent task
  temp_tasks.sort!
  temp_tasks.pop

  temp_tasks.each do |task|
    first_line = File.readlines(task).first.strip
    if first_line.start_with?('# ')
      title = first_line[2..]
                .downcase
                .gsub(/[^a-z0-9_\s-]/, '')
      new_name = File.join(File.dirname(task), "tk_#{title}.md")
      File.rename(task, new_name)
    end
  end
end
