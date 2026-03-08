#!/usr/bin/env ruby
# Usage: ruby concat_markdown.rb <directory_path> [output_filename]

require 'pathname'

dir_path = ARGV[0]
output_filename = ARGV[1] || '_concatenated.md'

abort "Usage: ruby concat_markdown.rb <directory_path> [output_filename]" unless dir_path
abort "Directory not found: #{dir_path}" unless Dir.exist?(dir_path)

output_path = File.join(dir_path, output_filename)

md_files = Dir.glob(File.join(dir_path, '*.md'))
            .reject { |f| File.basename(f) == output_filename }
            .sort

abort "No markdown files found in #{dir_path}" if md_files.empty?

puts "Found #{md_files.size} markdown file(s):"

File.open(output_path, 'w') do |out|
  md_files.each_with_index do |file, index|
    puts "  #{index + 1}. #{File.basename(file)}"
    content = File.read(file)
    out.write(content)
    out.write("\n\n---\n\n") unless index == md_files.size - 1
  end
end

puts "\nConcatenated output written to: #{output_path}"
