require 'date'
require_relative 'modules/ruby/TaskLister'
require_relative 'modules/ruby/fzf'


today = Date.today.strftime('%y%m%d').to_i
tasks = TaskLister.new

due_tasks = tasks.get_tasks_by_date("due_date: ", today)
due_soon_tasks = (tasks.get_tasks_by_date("due_date: ", today+2) - due_tasks)
start_tasks = tasks.get_tasks_by_date("start_date: ", today) - (due_tasks + due_soon_tasks)

output = []
if due_tasks.length > 0
  output << "due tasks:"
  output += due_tasks
end

if due_soon_tasks.length > 0
  output << "due soon tasks:"
  output += due_soon_tasks
end

if start_tasks.length > 0
  output << "start tasks:"
  output += start_tasks
end

if ENV['TERMUX_VERSION']
  puts output
else
  output.unshift('q')
  output.unshift('ls')
  output.reverse!
  choices = fzf(output, '-m')
  exit(0) if choices.include? 'q'
  puts 'continue'
end
