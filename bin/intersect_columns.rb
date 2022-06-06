#! /usr/bin/env ruby

require 'optparse'

#####################################################################
## METHODS
######################################################################

def load_records(file, cols, sep, full)
	recs = {}
  full_recs = {}
	File.open(file).each do |line|
		fields = line.chomp.split(sep)
    values = cols.map{|c| fields[c]}
		recs[values] = true
    full_recs[values] = fields if full
	end
	return recs.keys, full_recs
end

def print_recs(recs, sep)
	recs.each do |rec|
		puts rec.join(sep)
	end
end

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
  opts.on("-A", "--a_cols STRING", "Index of columns in base 0 to compare") do |item|
    options[:a_cols] = item.split(',').map{|n| n.to_i}
  end

  options[:b_cols] = [0]
  opts.on("-B", "--b_cols STRING", "Index of columns in base 0 to compare") do |item|
    options[:b_cols] = item.split(',').map{|n| n.to_i}
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

a_records, full_a_rec = load_records(options[:a_file], options[:a_cols], options[:sep], options[:full])
b_records, full_b_rec = load_records(options[:b_file], options[:b_cols], options[:sep], options[:full])

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
		print_recs(common, options[:sep])
	elsif options[:keep] == 'a'
    a_only = a_only.map{|r| full_a_rec[r]} if options[:full]
		print_recs(a_only, options[:sep])
	elsif options[:keep] == 'b'
    b_only = b_only.map{|r| full_a_rec[r]} if options[:full]
		print_recs(b_only, options[:sep])
	elsif options[:keep] == 'ab'
    if options[:full]
      a_only = a_only.map{|r| full_a_rec[r]} if options[:full]
      b_only = b_only.map{|r| full_a_rec[r]} if options[:full]
    end
		print_recs(a_only + b_only, options[:sep])
	end
end
