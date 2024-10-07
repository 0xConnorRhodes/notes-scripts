require_relative "fzf"
require "pry"

notes_folder = File.expand_path("~/notes")

tasks = Dir.glob(File.join(notes_folder, 'tk_*.md')).map {|f| File.basename(f)}

chosen_tasks = fzf(tasks, "-m --preview='bat ~/notes/{} --color=always --style=plain -l markdown'")

p chosen_tasks