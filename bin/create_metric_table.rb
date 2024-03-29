#!/usr/bin/env ruby

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

  options[:corrupted] = nil
  opts.on("-c", "--corrupted PATH", "File where corrupted metrics are stored") do |path|
    options[:corrupted] = path
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

##################################################################################################
## MAIN
##################################################################################################
metric_file = load_input_data(ARGV[0])
attributes = ARGV[1].split(',')
samples_tag = attributes.shift
metric_names, indexed_metrics = index_metrics(metric_file, attributes)
table_output, corrupted_records = create_table(indexed_metrics, samples_tag, attributes, metric_names)
write_output_data(table_output, ARGV[2])
write_output_data(corrupted_records, options[:corrupted]) if !options[:corrupted].nil? && !corrupted_records.empty?