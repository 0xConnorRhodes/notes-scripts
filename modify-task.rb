require 'fileutils'
require_relative 'modules/ruby/fzf'
require 'date'

class TaskMover
  def initialize
    @notes_folder =  File.join(File.expand_path('~'), 'notes')
    @done_folder = File.join(@notes_folder, 't', 'done')
    @drop_folder = File.join(@notes_folder, 't', 'drop')
    @hold_folder = File.join(@notes_folder, 't', 'hold')
  end

  def done_task
    tasks = get_current_tasks
    chosen = fzf(tasks, '-m')

    exit(0) if chosen.include? 'q'

    file_date = Date.today.strftime('%y%m%d').to_s

    chosen.each do |t|
      t_filed = t.sub("tk_", file_date + '-')
      FileUtils.move("#{@notes_folder}/#{t}", "#{@done_folder}/#{t_filed}")
      puts "DONE: #{t}"
    end
  end

  private
    def get_current_tasks
      tasks = Dir.glob("#{@notes_folder}/tk*.md").map{|i| i[@notes_folder.length+1..]}
      tasks << 'q'
    end

    def get_filed_tasks folder
      tasks = Dir.glob("#{folder}/*.md")
    end
end

taskmv = TaskMover.new

case ARGV[0]
when "done"
  taskmv.done_task
end