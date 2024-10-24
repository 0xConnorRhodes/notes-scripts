require_relative "modules/ruby/fzf"

scripts_dir = File.expand_path("~/code/notes-scripts")

options = {
  new_task: "ruby #{scripts_dir}/new-task.rb",
  list_tasks: "ruby #{scripts_dir}/list-tasks.rb",
  triage_tasks: "ruby #{scripts_dir}/triage-tasks.rb"
}

choice = fzf(options.keys)[0].to_sym
exec(options[choice])