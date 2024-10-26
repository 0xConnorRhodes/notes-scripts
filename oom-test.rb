require_relative 'modules/ruby/OOMarkdown'
require 'pry'

file = File.expand_path '~/notes/dn_241025.md'

oom = OOMarkdown.new

test = oom.append_to_heading(file, nil, nil)

puts test