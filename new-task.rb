require 'highline'
require 'pry'

class TaskCreator
  def initialize
    @notes_folder = File.expand_path("~/notes")
  end

  def get_task_str
    cli = HighLine.new
    # task_str = cli.ask "task: "
    task_str = 'new task s 241014'
  end

  def create_task_file task_str
    task_data = process_task_str(task_str)
  end

  private
    def process_task_str task_str
      start_match = task_str.match(/s \d{6}/)
      start_date = start_match ? start_match[0].slice(2..-1).to_i : nil
      due_match = task_str.match(/d \d{6}/)
      due_date = due_match ? due_match[0].slice(2..-1).to_i : nil
      task_name = task_str.sub(start_match.to_s, '').sub(due_match.to_s, '').strip

      task_data = { task_name: task_name, start_date: start_date, due_date: due_date }
    end

end # end Class

new_task = TaskCreator.new
task_str = new_task.get_task_str
new_task.create_task_file(task_str)