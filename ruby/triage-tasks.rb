require_relative "fzf"
require "pry"

notes_folder = File.expand_path("~/notes")

tasks = Dir.glob(File.join(notes_folder, 'tk_*.md')).map {|f| File.basename(f)}

binding.pry