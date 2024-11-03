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
    # generate sequential output for single puts to terminal
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

  def fzf_display_output output, editor:, preview: false
      output.unshift('q')
      output.unshift('ls')
      output.reverse!

      if preview
        preview_cmd = "--preview='bat ~/notes/tk{}.md --color=always --style=plain -l markdown'"
        choices = fzf(output, "-m #{preview_cmd}")
      else
        choices = fzf(output, '-m')
      end

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
          system("#{editor} \"#{task_file}\"")
        when 'done'
          # TODO: function to move note and update links
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
            nil
          when 'drop'
            nil
          when 'hold'
            nil
          end
        end
      end
  end
end

menu = ListTasksMenu.new

if ENV['TERMUX_VERSION']
  raw_output = menu.generate_output
  puts raw_output
else
  loop do
    raw_output = menu.generate_output
    menu.fzf_display_output(raw_output, editor: 'nvim', preview: true)
  end
end