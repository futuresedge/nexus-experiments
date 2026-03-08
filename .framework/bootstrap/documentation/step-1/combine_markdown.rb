#!/usr/bin/env ruby

# Usage:
#   ruby combine_markdown.rb path/to/markdown_dir [output_filename]
#
# Example:
#   ruby combine_markdown.rb ./notes all_notes.md

dir_path = ARGV[0]
output_name = ARGV[1] || "combined.md"

if dir_path.nil? || dir_path.strip.empty?
  warn "Usage: ruby #{File.basename($0)} path/to/markdown_dir [output_filename]"
  exit 1
end

unless Dir.exist?(dir_path)
  warn "Directory does not exist: #{dir_path}"
  exit 1
end

# Ensure absolute paths
dir_path = File.expand_path(dir_path)
output_path = File.join(dir_path, output_name)

# Get all .md files (non-recursive) except the output file itself
markdown_files = Dir.glob(File.join(dir_path, "*.md")).sort
markdown_files.reject! { |f| File.expand_path(f) == output_path }

if markdown_files.empty?
  warn "No markdown files found in #{dir_path}"
  exit 1
end

File.open(output_path, "w") do |out|
  markdown_files.each_with_index do |file, idx|
    filename = File.basename(file)

    # Optional: add a heading before each file's content
    out.puts "# #{filename}"
    out.puts

    content = File.read(file, encoding: "UTF-8")
    out.write(content)
    out.puts

    # Optional: separator between files (except after last one)
    out.puts "\n---\n" if idx < markdown_files.size - 1
    out.puts
  end
end

puts "Wrote #{markdown_files.size} files into #{output_path}"
