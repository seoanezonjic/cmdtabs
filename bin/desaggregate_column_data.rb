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
  opts.banner = "Usage: #{__FILE__} [options]"

  options[:input] = nil
  opts.on("-i", "--input_file PATH", "Path to input file") do |item|
    options[:input] = item
  end

  options[:col_index] = nil
  opts.on("-x", "--column_index INTEGER", "Column index (1 based) to use as reference") do |item|
    options[:col_index] = item.to_i - 1
  end

  options[:sep] = ","
  opts.on("-s", "--sep_char STRING", "Field character delimiter") do |item|
    options[:sep] = item
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!


##################################################################################################
## MAIN
##################################################################################################

input_table = load_input_data(options[:input])
desagg_data = desaggregate_column(input_table, options[:col_index], options[:sep])
write_output_data(desagg_data)


