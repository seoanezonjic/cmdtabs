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
  opts.on("-x", "--column_index INTEGER", "Column index (0 based) to use as reference") do |item|
    options[:col_index] = item.to_i
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

if options[:input] == '-'
  input_file = STDIN
else
  input_file = File.open(options[:input] )
end
desagg_data = desaggregate_column(input_file, options[:col_index], options[:sep])
save_desaggregated(desagg_data)


