#! /usr/bin/env ruby

ROOT_PATH = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path(File.join(ROOT_PATH, '..', 'lib')))
require 'optparse'
require 'cmdtabs'


#####################################################################
## OPTPARSE
######################################################################

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:a_file] = nil
  opts.on("-a", "--a_file PATH", "Path to input file") do |item|
    options[:a_file] = item
  end

  options[:b_file] = nil
  opts.on("-b", "--a_file PATH", "Path to input file") do |item|
    options[:b_file] = item
  end

  options[:a_cols] = [0]
  opts.on("-A", "--a_cols STRING", "Index of columns in base 1 to compare") do |item|
    options[:a_cols] = parse_column_indices(sep = ",", item)
  end

  options[:b_cols] = [0]
  opts.on("-B", "--b_cols STRING", "Index of columns in base 1 to compare") do |item|
    options[:b_cols] = parse_column_indices(sep = ",", item)
  end

  options[:count] = false
  opts.on("-c", "--count", "Only compute number of matches") do
    options[:count] = true
  end

  options[:keep] = 'c'
  opts.on("-k", "--keep STRING", "Keep records. c for common, 'a' for specific of file a, 'b' for specific of file b and 'ab' for specific of file a AND b") do |item|
    options[:keep] = item
  end

  options[:full] = false
  opts.on("--full", "Give full record") do |item|
    options[:full] = true
  end

  options[:sep] = "\t"
  opts.on("-s", "--separator STRING", "column character separator") do |item|
    options[:sep] = item
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

input_data_a = load_input_data(options[:a_file], options[:sep])
input_data_b = load_input_data(options[:b_file], options[:sep])

a_records, full_a_rec = load_records(input_data_a, options[:a_cols], options[:full])
b_records, full_b_rec = load_records(input_data_b, options[:b_cols], options[:full])

common = a_records & b_records
a_only = a_records - common
b_only = b_records - common
if options[:count]
	puts "a: #{a_only.length}"
	puts "b: #{b_only.length}"
	puts "c: #{common.length}"
else
	if options[:keep] == 'c'
    common = common.map{|r| full_a_rec[r] + full_b_rec[r]} if options[:full]
		write_output_data(common, nil, options[:sep])
	elsif options[:keep] == 'a'
    a_only = a_only.map{|r| full_a_rec[r]} if options[:full]
		write_output_data(a_only, nil, options[:sep])
	elsif options[:keep] == 'b'
    b_only = b_only.map{|r| full_a_rec[r]} if options[:full]
		write_output_data(b_only, nil, options[:sep])
	elsif options[:keep] == 'ab'
    if options[:full]
      a_only = a_only.map{|r| full_a_rec[r]} if options[:full]
      b_only = b_only.map{|r| full_a_rec[r]} if options[:full]
    end
		write_output_data(a_only + b_only, nil, options[:sep])
	end
end
