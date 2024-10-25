require 'date'
require_relative '../modules/TaskLister'
require 'pry'

def build_on_deck_section(due_tasks_arr, due_soon_tasks_arr, start_tasks_arr)
  on_deck_section = []
  on_deck_section += ['### due'] + due_tasks_arr.map{|i| "- [[tk#{i}]]"} + ["\n"] if due_tasks_arr.length > 0
  on_deck_section += ['### due soon'] + due_soon_tasks_arr.map{|i| "- [[tk#{i}]]"} + ["\n"] if due_soon_tasks_arr.length > 0
  on_deck_section += ['### start'] + start_tasks_arr.map{|i| "- [[tk#{i}]]"} + ["\n"] if start_tasks_arr.length > 0

  return on_deck_section
end

NOTES_FOLDER = File.join(File.expand_path('~'), 'notes')
tasks = TaskLister.new

today = Date.today.strftime('%y%m%d').to_i
daily_note_path = File.join(NOTES_FOLDER, "dn_#{today}.md")

due_tasks = tasks.get_tasks_by_date("due_date: ", today)
due_soon_tasks = tasks.get_tasks_by_date("due_date: ", today+3) - due_tasks
start_tasks = tasks.get_tasks_by_date("start_date: ", today) - due_soon_tasks

on_deck_md = build_on_deck_section(due_tasks, due_soon_tasks, start_tasks)

dn_content = File.readlines(daily_note_path)

if dn_content.grep("# Daily Log\n").empty?
  puts "Error: Daily note does not contain Daily Log heading"
end

unless dn_content.grep("## on deck\n").empty?
  puts "Error: on deck heading already present"
end