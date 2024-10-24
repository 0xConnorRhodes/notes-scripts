require 'date'

class TaskLister
  def initialize
    @notes_folder = File.join(File.expand_path('~'), 'notes')
  end

  def get_tasks_by_date(key_string, date_limit)
    date_tasks = `rg -d 1 -l "#{key_string}" #{@notes_folder}/tk_*`.split("\n")

    date_tasks.each do |t|
      # int value of due date from file
      task_date = File.readlines(t).grep(/#{key_string}/)[0].match(/\d{6}/)[0].to_i

      date_tasks -= Array(t) unless task_date <= date_limit
    end

    # slice off file path, task prefix, and extension. Keep _ so no char replacement needed later
    return date_tasks.map {|i| i[@notes_folder.length+3..-4]}
  end
end

today = Date.today.strftime('%y%m%d').to_i
tasks = TaskLister.new

due_tasks = tasks.get_tasks_by_date("due_date: ", today)
due_soon_tasks = (tasks.get_tasks_by_date("due_date: ", today+2) - due_tasks)
start_tasks = tasks.get_tasks_by_date("start_date: ", today) - due_soon_tasks

if due_tasks.length > 0
  puts "due tasks:"
  puts due_tasks
end

if due_soon_tasks.length > 0
  puts "due soon tasks:"
  puts due_soon_tasks
end

if start_tasks.length > 0
  puts "start tasks:"
  puts start_tasks
end