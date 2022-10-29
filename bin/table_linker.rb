#!/usr/bin/env ruby
# Pedro Seoane Zonjic 13-12-2012
# Toma la informacion extraida de un archivo tabulado (donde la primera columna es el idetificador) en base a una lista de identificadores proporcionada
# la informacion se guarda en el archivo de salida

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

	options[:input_file] = nil
	opts.on("-i", "--input_file PATH", "Path to input file") do |item|
		options[:input_file] = item
	end

	options[:linker_file] = nil
	opts.on("-l", "--linker_file PATH", "Path to file linker") do |item|
		options[:linker_file] = item
	end

	options[:drop_line] = false
	opts.on("--drop", "Write the lines whose identifiers have been matched") do |item|
		options[:drop_line] = true
	end

	options[:sep] = "\t"
	opts.on("-s", "--separator STRING", "column character separator") do |item|
		options[:sep] = item
	end

	options[:output_file] = nil
	opts.on("-o", "--output_file PATH", "Output file ") do |item|
		options[:output_file] = item
	end

	opts.on_tail("-h", "--help", "Show this message") do
		puts opts
		exit
	end
end.parse!



##################################################################################################
## MAIN
##################################################################################################

input_linker = load_input_data(options[:linker_file])
indexed_linker = index_array(input_linker)
input_table = load_input_data(options[:input_file], "\t", 2)

linked_table = link_table(indexed_linker, input_table, options[:drop_line], options[:sep])
write_output_data(linked_table, options[:output_file])