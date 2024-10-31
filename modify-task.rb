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

  def file_task function
    case function
    when "done"
      file_folder = @done_folder
    when "drop"
      file_folder = @drop_folder
    when "hold"
      file_folder = @hold_folder
    end

    tasks = get_current_tasks
    chosen = fzf(tasks, '-m')

    exit(0) if chosen.include? 'q'

    file_date = Date.today.strftime('%y%m%d').to_s

    chosen.each do |t|
      t_filed = t.sub("tk_", file_date + '-')
      FileUtils.move("#{@notes_folder}/#{t}", "#{file_folder}/#{t_filed}")
      puts "#{function.upcase}: #{t}"
    end
  end

  def unfile_task function
    case function
    when "undone"
      file_folder = @done_folder
    when "undrop"
      file_folder = @drop_folder
    when "unhold"
      file_folder = @hold_folder
    end

    tasks = get_filed_tasks file_folder
    chosen = fzf(tasks, '-m')

    exit(0) if chosen.include? 'q'

    chosen.each do |t|
      t_unfiled = t.sub(/^\d{6}-/, 'tk_')
      FileUtils.move("#{file_folder}/#{t}", "#{@notes_folder}/#{t_unfiled}")
      puts "#{function.upcase}: #{t}"
    end
  end

  private
    def get_current_tasks
      tasks = Dir.glob("#{@notes_folder}/tk*.md").map{|i| i[@notes_folder.length+1..]}
      tasks << 'q'
    end

    def get_filed_tasks folder
      tasks = Dir.glob("#{folder}/*.md").map{|i| i[folder.length+1..]}
      tasks << 'q'
    end
end

taskmv = TaskMover.new

case ARGV[0]
when "done"
  taskmv.file_task "done"
when "drop"
  taskmv.file_task "drop"
when "hold"
  taskmv.file_task "hold"
when "undone"
  taskmv.unfile_task "undone"
when "undrop"
  taskmv.unfile_task "undrop"
when "unhold"
  taskmv.unfile_task "unhold"
end