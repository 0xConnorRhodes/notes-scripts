require_relative "modules/ruby/fzf"

scripts_dir = File.expand_path("~/code/notes-scripts")

options = {
  "new task" => "python3 {scripts_dir}/new-task.py",
  "list tasks" => "python3 {scripts_dir}/list-tasks.py",
  "triage tasks" => "ruby #{scripts_dir}/triage-tasks.rb"
}

choice = fzf(options.keys)[0]

exec(options[choice])