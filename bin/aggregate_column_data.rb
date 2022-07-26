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

  options[:input] = nil
  opts.on("-i", "--input_file PATH", "Path to input file") do |item|
    options[:input] = item
  end

  options[:col_index] = nil
  opts.on("-x", "--column_index INTEGER", "Column index (0 based) to use as reference") do |item|
    options[:col_index] = item.to_i
  end

  options[:sep] = ','
  opts.on("-s", "--separator STRING", "Character separator when collapse data") do |item|
    options[:sep] = item
  end

  options[:col_aggregate] = nil
  opts.on("-a", "--column_aggregate INTEGER", "Column index (0 based) to extract data and join for each id in column index") do |item|
    options[:col_aggregate] = item.to_i
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
  input_file = File.open(options[:input])
end

agg_data = aggregate_column(input_file, options[:col_index], options[:col_aggregate])
save_aggregated(agg_data, options[:sep])
