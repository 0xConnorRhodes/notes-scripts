require 'fileutils'
require 'date'
require_relative 'fzf'

class NoteController
  def initialize(notes_folder, date, tasks_arr)
    @notes_folder = notes_folder
    @date = date
    @tasks = tasks_arr
  end
end

notes_folder = File.expand_path("~/notes")
date = Time.now.strftime('%y%m%d')
tasks = Dir.glob(File.join(notes_folder, 'tk_*.md'))

scheduled_tasks = `rg -l -F -d 1 "start_date: " ~/notes`.split("\n")
future_tasks = []
scheduled_tasks.each do |f|
 start_date = `grep "start_date: " "#{f}"`
 start_date = start_date.match(/\d{6}/)[0].to_i
 if start_date > date.to_i
   future_tasks.push(f)
 end
end
tasks = tasks - future_tasks

tasks = tasks.map {|f| File.basename(f)}.map {|i| i.sub('tk_', '')}.map {|i| i.sub('.md', '')}
tasks.unshift('q')

chosen_tasks = fzf(tasks, "-m --preview='bat ~/notes/tk_{}.md --color=always --style=plain -l markdown'")
exit if chosen_tasks[0] == 'q'

operation_list = ['done', 'drop', 'hold', 'q']
operation_list.unshift('edit') if chosen_tasks.length == 1
operation = fzf(operation_list)[0]
exit if operation == 'q'


def refile_tasks(task_array, task_operation)
  task_array.each do |task|
    move_from = File.join(NOTES_FOLDER, "tk_#{task}.md")
    move_to = File.join(NOTES_FOLDER, '_tk', task_operation, "#{date}-#{task}.md")

    FileUtils.mv(move_from, move_to)

    search_string = "tk_#{task}"
    files_with_links = `rg -l -F -d 1 "[[#{search_string}]]" ~/notes`.split("\n")
    replace_string = "_tk/#{task_operation}/#{date}-#{task}"

    files_with_links.each do |f|
      `sed -i 's##{search_string}##{replace_string}#g' "#{f}"`
    end

    puts "#{task_operation.upcase}: #{task}"
  end
end 
ndregion

egion actions
if operation == 'edit'
  edit_file = File.join(NOTES_FOLDER, "tk_#{chosen_tasks[0]}.md")
  exec("nvim \"#{edit_file}\"")
end

#TODO: add tag functionality and factor this code into a file_task method
refile_tasks(chosen_tasks, operation)
# chosen_tasks.each do |task|
#   move_from = File.join(notes_folder, "tk_#{task}.md")
#   move_to = File.join(notes_folder, '_tk', operation, "#{date}-#{task}.md")

#   FileUtils.mv(move_from, move_to)

#   search_string = "tk_#{task}"
#   files_with_links = `rg -l -F -d 1 "[[#{search_string}]]" ~/notes`.split("\n")
#   replace_string = "_tk/#{operation}/#{date}-#{task}"

#   files_with_links.each do |f|
#     `sed -i 's##{search_string}##{replace_string}#g' "#{f}"`
#   end

#   puts "#{operation.upcase}: #{task}"
# end