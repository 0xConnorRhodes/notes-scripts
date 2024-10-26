require 'highline'
require 'date'
require_relative 'modules/ruby/fzf'
require 'pry'

NOTES_FOLDER = File.join(File.expand_path('~'), 'notes')

note_template = <<-TEMPLATE
[[{{ meetand }}]]

# context

# folks
- 

# log
- 

TEMPLATE


class NewMeeting
  def choose_meetand
    vaccounts_list = File.readlines(File.join(NOTES_FOLDER, '.vaccounts.list')).map(&:chomp)
    @rdex_list = File.readlines(File.join(NOTES_FOLDER, '.rdex.list')).map(&:chomp)
    @circles_list = File.readlines(File.join(NOTES_FOLDER, '.circles.list')).map(&:chomp)
    meetands = (vaccounts_list + @rdex_list + @circles_list).uniq
    chosen_meetand = fzf(meetands)[0]
  end

  def write_file(meeting_with, meeting_purpose, template)
    date = Date.today.strftime("%y%m%d").to_s

    # add space between meetand and meeting purpose if meeting purpose is supplied
    meeting_purpose = ' ' + meeting_purpose if meeting_purpose.length > 0

    file_name = "mt_#{date} #{meeting_with}#{meeting_purpose}.md"
    filepath = "#{NOTES_FOLDER}/#{file_name}"

    if @rdex_list.grep(meeting_with).any?
      meetand_link = "r_"+meeting_with
    elsif @circles_list.grep(meeting_with).any?
      meetand_link = "c_"+meeting_with
    else
      meetand_link = meeting_with
    end

    rendered_template = template.gsub('{{ meetand }}', meetand_link)

    File.open(filepath, 'w') do |f|
      f.puts rendered_template
    end

    puts "wrote: #{file_name}"
  end
end

cli = HighLine.new
meet = NewMeeting.new

meetand = meet.choose_meetand()

if meetand == 'NEW'
  meetand = cli.ask "meetand: "
end

purpose = cli.ask "purpose: "

meet.write_file(meetand, purpose, note_template)