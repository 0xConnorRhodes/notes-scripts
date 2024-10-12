require 'highline'
require 'mustache'
require 'pry'

class TaskTemplate < Mustache
  self.template_file = File.join(File.dirname(__FILE__), 'template.mustache')
end

class TaskCreator
  def initialize
    @notes_folder = File.expand_path("~/notes")
  end

  def get_task_str
    cli = HighLine.new
    # task_str = cli.ask "task: "
    # task_str = 'new task'
    task_str = 'new task s 241014'
    # task_str = 'new task d 241014'
    # task_str = 'new task s 241014 d 241015'
  end

  def create_task_file task_str
    file_content = render_file_content(task_str)
    puts file_content
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

    def render_file_content task_str
      task_data = process_task_str(task_str)
      # file_lines = ['# meta', "\n", '# info', "\n\n", '# mtks', '- [ ] ', "\n"]
      file_lines = ["# meta\n", "\n", "# info\n", "\n\n", "# mtks\n", "- [ ] \n", "\n"]

      if task_data[:start_date] == nil and task_data[:due_date] == nil
        file_lines.insert(1, "- \n")
      end

      if task_data[:due_date]
        file_lines.insert(1, "- due_date: #{task_data[:due_date]}\n")
      end

      if task_data[:start_date]
        file_lines.insert(1, "- start_date: #{task_data[:start_date]}\n")
      end

      file_lines.join()
    end

end # end Class

new_task = TaskCreator.new
task_str = new_task.get_task_str
new_task.create_task_file(task_str)