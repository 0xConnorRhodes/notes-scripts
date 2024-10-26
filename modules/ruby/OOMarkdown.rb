require 'pry'

class OOMarkdown
  def append_to_heading(file, heading, append_lines)
  # given a heading, parse all text under that heading (including nested subheadings)
  # append the append_lines array to this section of the file and write the full contents back to the file
    file_lines = File.readlines(file)
    segment_start = file_lines.index(heading)

    unless segment_start
      puts "Error: given heading is not in the file"
      exit(1)
    end

    heading_level = heading.match(/^(#+).*/)&.[](1)
    segment_end = nil

    file_lines[segment_start+1..-1].each do |line|
      if line[0..heading_level.length] == heading_level + " "
        segment_end = file_lines.index(line)
        break
      end
      segment_end = -1
    end

    new_file_lines = file_lines[..segment_end-1] + append_lines + ["\n"] + file_lines[segment_end..]
    File.open(file, 'w') { |file| file.puts new_file_lines }
  end
end

# oom = OOMarkdown.new()

# note = File.expand_path('~/notes/dn_241025.md') 
# heading = "# Today I *get* to\n"
# # heading = "## my one thing\n"

# test = oom.append_to_heading(note, heading, %w(newline1 newline2 newline3))