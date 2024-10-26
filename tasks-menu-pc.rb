require_relative "modules/ruby/fzf"

scripts_dir = File.expand_path("~/code/notes-scripts")

options = {
  new_task: "ruby #{scripts_dir}/new-task.rb",
  list_tasks: "ruby #{scripts_dir}/list-tasks.rb",
  triage_tasks: "ruby #{scripts_dir}/triage-tasks.rb",
  done_task: "lua5.4 #{scripts_dir}/modify-task.lua done",
  drop_task: "lua5.4 #{scripts_dir}/modify-task.lua drop",
  hold_task: "lua5.4 #{scripts_dir}/modify-task.lua hold",
  undone_tasks: "lua5.4 #{scripts_dir}/modify-task.lua undone",
  undrop_tasks: "lua5.4 #{scripts_dir}/modify-task.lua undrop",
  unhold_tasks: "lua5.4 #{scripts_dir}/modify-task.lua unhold"
}

choice = fzf(options.keys)[0].to_sym
exec(options[choice])
