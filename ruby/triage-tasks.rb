require 'fileutils'
require 'date'
require_relative 'fzf'

current_date = Time.now
formatted_date = current_date.strftime('%y%m%d')

notes_folder = File.expand_path("~/notes")

tasks = Dir.glob(File.join(notes_folder, 'tk_*.md')).map {|f| File.basename(f)}
tasks = tasks.map {|i| i.sub('tk_', '')}.map {|i| i.sub('.md', '')}
tasks.unshift('q')

chosen_tasks = fzf(tasks, "-m --preview='bat ~/notes/tk_{}.md --color=always --style=plain -l markdown'")
exit if chosen_tasks[0] == 'q'

operation = fzf(['done', 'drop', 'hold', 'q'])[0]
exit if operation == 'q'

chosen_tasks.each do |task|
  move_from = File.join(notes_folder, "tk_#{task}.md")
  move_to = File.join(notes_folder, '_tk', operation, "#{formatted_date}-#{task}.md")

  FileUtils.mv(move_from, move_to)

  search_string = "tk_#{task}"
  files_with_links = `rg -l -F "[[#{search_string}]]" ~/notes`.split("\n")
  replace_string = "_tk/#{operation}/#{formatted_date}-#{task}"

  files_with_links.each do |f|
    `sed -i 's##{search_string}##{replace_string}#g' "#{f}"`
  end

  puts "#{operation.upcase}: #{task}"
end