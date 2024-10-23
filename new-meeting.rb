require_relative 'modules/ruby/fzf'
require 'pry'

NOTES_FOLDER = File.join(File.expand_path('~'), 'notes')

def choose_meetand
  vaccounts_list = File.readlines(File.join(NOTES_FOLDER, '.vaccounts.list')).map(&:chomp)
  rdex_list = File.readlines(File.join(NOTES_FOLDER, '.rdex.list')).map(&:chomp)
  meetands = (vaccounts_list + rdex_list).uniq
  chosen_meetand = fzf(meetands)
end

meetand = choose_meetand()

binding.pry