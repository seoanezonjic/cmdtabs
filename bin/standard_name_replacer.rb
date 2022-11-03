#! /usr/bin/env ruby

ROOT_PATH = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path(File.join(ROOT_PATH, '..', 'lib')))
require 'optparse'
require 'cmdtabs.rb'



#####################################################################
## OPTPARSE
######################################################################

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

	options[:output_file] = nil
	opts.on("-o", "--output_file PATH", "Output file ") do |item|
		options[:output_file] = item
	end

	options[:input_separator] = "\t"
	opts.on("-s", "--input_separator STRING", "Separator character") do |item|
		options[:input_separator] = item
	end

	options[:columns] = [1]
	opts.on("-c", "--columns STRING", "Columns indexes (1 based), comma separated, to perform the ID translations.") do |item|
    	options[:columns] = parse_column_indices(sep = ",", item)
	end

	options[:from] = [0]
	opts.on("-f", "--from INTEGER", "Column in index file to take reference value. Default 1. Numeration is 1 based") do |item|
    	options[:from] = item.to_i - 1
	end

	options[:to] = [1]
	opts.on("-t", "--to INTEGER", "Column in index file to take the value that will be used in substitution. Default 2. Numeration is 1 based") do |item|
    	options[:to] = item.to_i - 1
	end

end.parse!


##################################################################################################
## MAIN
##################################################################################################

input_index = load_input_data(options[:index_file])
indexed_index = index_array(input_index, options[:from], options[:to])

input_table = load_input_data(options[:input_file], options[:input_separator])

tabular_output_translated, tabular_output_untraslated = name_replaces(input_table, options[:input_separator], options[:columns], indexed_index)

write_output_data(tabular_output_translated, options[:output_file], options[:input_separator])
write_output_data(tabular_output_untraslated, options[:output_file], options[:input_separator])
