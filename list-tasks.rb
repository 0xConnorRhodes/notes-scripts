require 'date'
require_relative 'modules/ruby/TaskLister'

today = Date.today.strftime('%y%m%d').to_i
tasks = TaskLister.new

due_tasks = tasks.get_tasks_by_date("due_date: ", today)
due_soon_tasks = (tasks.get_tasks_by_date("due_date: ", today+2) - due_tasks)
start_tasks = tasks.get_tasks_by_date("start_date: ", today) - (due_tasks + due_soon_tasks)

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