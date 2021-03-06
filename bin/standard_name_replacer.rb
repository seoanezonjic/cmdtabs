#! /usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: #{__FILE__} [options]"

	options[:input_file] = nil
	opts.on("-i", "--input_file PATH", "Input file ") do |input_file|
		options[:input_file] = input_file
	end

	options[:index_file] = nil
	opts.on("-I", "--index_file PATH", "Index file ") do |item|
		options[:index_file] = item
	end

	options[:input_separator] = "\t"
	opts.on("-s", "--input_separator STRING", "Separator character") do |item|
		options[:input_separator] = item
	end

	options[:columns] = [1]
	opts.on("-c", "--columns STRING", "Columns indexes, comma separated, to perform the ID translations.") do |item|
		options[:columns] = item.split(','). map{|i| i.to_i - 1}
	end

	options[:from] = 0
	opts.on("-f", "--from INTEGER", "Column in index file to take reference value. Default 1. Numeration is 1 based") do |item|
		options[:from] = item.to_i - 1
	end

	options[:to] = 1
	opts.on("-t", "--to INTEGER", "Column in index file to take the value that will be used in substitution. Default 2. Numeration is 1 based") do |item|
		options[:to] = item.to_i - 1
	end

end.parse!

#Load index
index = {}
File.open(options[:index_file]).read.each_line do |line|
	line.chomp!
	fields = line.split("\t")
	index[fields[options[:from]]] = fields[options[:to]]
end

#Reemplaza nombres
File.open(options[:input_file]+'_rep','w') do |f| 
	File.open(options[:input_file]).each do |line|
		fields = line.chomp.split(options[:input_separator])
		options[:columns].each do |col|
			new_string = index[fields[col]]
			fields[col] = new_string if !new_string.nil?
		end
		f.puts fields.join(options[:input_separator])
	end
end 
