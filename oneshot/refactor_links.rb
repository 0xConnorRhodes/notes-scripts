directory = File.expand_path('~/notes')

def replace_pattern(file_path)
  content = File.read(file_path)
  new_content = content.gsub('[[_tk', '[[t')

  if content != new_content
    File.write(file_path, new_content)
    puts "Updated: #{file_path}"
  end
end

files = Dir.glob("#{directory}/**/*.md")

files.each do |f|
  replace_pattern(f)
end