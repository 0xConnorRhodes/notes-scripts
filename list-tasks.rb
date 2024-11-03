require 'date'
require_relative 'modules/ruby/TaskLister'
require_relative 'modules/ruby/fzf'
require 'pry'

class ListTasksMenu
  def initialize
    @scripts_dir = File.expand_path('~/code/notes-scripts')
    @today = Date.today.strftime('%y%m%d').to_i
    @tasks = TaskLister.new
  end

  def generate_output
    due_tasks = @tasks.get_tasks_by_date("due_date: ", @today)
    due_soon_tasks = (@tasks.get_tasks_by_date("due_date: ", @today+2) - due_tasks)
    start_tasks = @tasks.get_tasks_by_date("start_date: ", @today) - (due_tasks + due_soon_tasks)

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

    return output
  end
end

# scripts_dir = File.expand_path('~/code/notes-scripts')

# today = Date.today.strftime('%y%m%d').to_i
# tasks = TaskLister.new

# due_tasks = tasks.get_tasks_by_date("due_date: ", today)
# due_soon_tasks = (tasks.get_tasks_by_date("due_date: ", today+2) - due_tasks)
# start_tasks = tasks.get_tasks_by_date("start_date: ", today) - (due_tasks + due_soon_tasks)

menu = ListTasksMenu.new

output = menu.generate_output

puts output

exit(0)
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

  loop do
    choices = fzf(output, '-m')

    if choices.include? 'q'
      exit(0)
    elsif choices.include? 'ls' 
      output.delete('q')
      output.delete('ls')
      output.reverse!
      puts output
      exit(0)
    elsif choices.length == 1
      operation = fzf(['edit', 'done', 'drop', 'hold'])[0]
      task_file = File.expand_path("~/notes/tk#{choices[0]}.md")
      case operation
      when 'edit'
        system("nvim \"#{task_file}\"")
      when 'done'
        nil
      when 'drop'
        nil
      when 'hold'
        nil
      end
    else
      operation = fzf(['done', 'drop', 'hold'])[0]
      choices.each do |choice|
        case operation
        when 'done'
          `ruby #{scripts_dir}/modify-task.rb done`
        when 'drop'
          `ruby #{scripts_dir}/modify-task.rb drop`
        when 'hold'
          `ruby #{scripts_dir}/modify-task.rb hold`
        end
      end
    end
  end
end
