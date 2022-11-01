#! /usr/bin/env ruby
ROOT_PATH = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path(File.join(ROOT_PATH, '..', 'lib')))

require 'optparse'
require 'cmdtabs'

#####################################################################
## OPTIONS
######################################################################
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!


##################################################################################################
## MAIN
##################################################################################################

files = load_files(ARGV)
merged = merge_files(files)
write_output_data(merged)
