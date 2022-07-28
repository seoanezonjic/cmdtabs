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

  options[:id_col] = 1
  opts.on("-c", "--id_col INTEGER", "Column number to select IDs. Default 1") do |data|
    options[:id_col] = data.to_i
  end

  options[:data_col] = 2
  opts.on("-d", "--data_col INTEGER", "Column number to select data. Default 1") do |data|
    options[:data_col] = data.to_i
  end

  options[:header_id] = nil
  opts.on("-e", "--header_id STRING", "Header identifier. Use it whether it needs to be removed") do |data|
    options[:header_id] = data
  end

  options[:input_file] = nil
  opts.on("-i", "--input_file PATH", "Input xlsx file") do |path|
    options[:input_file] = path
  end

  options[:output_file] = 'table.txt'
  opts.on("-o", "--output_file PATH", "Output tabular file") do |path|
    options[:output_file] = path
  end

  options[:sheet_number] = 1
  opts.on("-s", "--sheet_number INTEGER", "Sheet number to work with. Default 1") do |data|
    options[:sheet_number] = data.to_i
  end

  options[:data_type] = nil
  opts.on("-t", "--data_type STRING", "Data type to apply corrections. Options: enod.") do |data|
    options[:data_type] = data
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

storage = []
x = Xsv.open(options[:input_file])
sheet = x.sheets[options[:sheet_number]]
extract_data_from_sheet(sheet, storage, options[:header_id], options[:id_col], options[:data_col])
write_tab_file(storage, options[:output_file])



# sheet_names = x.sheets.map(&:name)
# sheet_names.each do |sht_name|
#   sheet = x.sheets_by_name(sht_name).first
#   sht_name.gsub!(/[,\. ]/ , "_")
#   File.open(options[:output_file] + '_' + sht_name, 'w') do |f|
#     sheet.each do |row|
#       first_cell = row[0]
#       next if first_cell.nil? || first_cell.class == Date
#       first_cell.gsub!(/^[\(,]/, '')
#       first_cell.gsub!(/[\),]$/, '')
#       first_cell.strip!
#       next if first_cell.empty?
#       f.puts first_cell
#     end
#   end
# end
