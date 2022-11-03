#! /usr/bin/env ruby
#
## Script to transform xlsx to tabular file. 
## By default, selects sheet 1 and column 1.

ROOT_PATH = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path(File.join(ROOT_PATH, '..', 'lib')))

require 'optparse'
require 'cmdtabs'
require 'xsv'

#######################
## OPTPARSE
#######################

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  options[:columns2extract] = [0]
  opts.on("-c", "--columns2extract INTEGER", "Column position to extract (1 based). Default 1") do |data|
    options[:columns2extract] = parse_column_indices(sep = ",", item)
  end

  options[:input_file] = nil
  opts.on("-i", "--input_file PATH", "Input xlsx file") do |path|
    options[:input_file] = path
  end

  options[:output_file] = 'table.txt'
  opts.on("-o", "--output_file PATH", "Output tabular file") do |path|
    options[:output_file] = path
  end

  options[:sheet_number] = 0
  opts.on("-s", "--sheet_number INTEGER", "Sheet number to work with. Default 1") do |data|
    options[:sheet_number] = data.to_i - 1
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

end.parse! 

#######################
## MAIN
#######################

#See https://github.com/martijn/xsv

x = Xsv.open(options[:input_file])
sheet = x.sheets[options[:sheet_number]]
storage = extract_data_from_sheet(sheet, options[:columns2extract])
write_output_data(storage, options[:output_file])