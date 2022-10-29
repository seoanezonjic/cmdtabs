#!/usr/bin/env ruby

ROOT_PATH = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path(File.join(ROOT_PATH, '..', 'lib')))
require 'optparse'
require 'cmdtabs'


#################################################################################################
## INPUT PARSING
#################################################################################################
options = {}

optparse = OptionParser.new do |opts|
        options[:input_file] = nil
        opts.on( '-i', '--input_file PATH', 'Input tabulated file' ) do |input_file|
            options[:input_file] = input_file
        end

    	options[:tags] = nil
        opts.on( '-t', '--tags STRING', 'Strings or files (only first linewill be used) sepparated by commas' ) do |tags|
                options[:tags] =  tags.split(",")
        end    

        options[:sep] = "\t"
        opts.on( '-s', '--sep CHR', 'Character that separates fields in tags' ) do |chr|
                options[:sep] =  chr
        end        

        options[:header] = false
        opts.on( '-H', '--header', 'Indicate if input file has a header line' ) do 
                options[:header] =  true
        end  

      

 		opts.on( '-h', '--help', 'Display this screen' ) do
                puts opts
                exit
        end

end # End opts

# parse options and remove from ARGV
optparse.parse!

##################################################################################################
## MAIN
##################################################################################################

input_table = load_input_data(options[:input_file])
tags = load_and_parse_tags(options[:tags], options[:sep])
taged_table = tag_file(input_table, tags, options[:header])
write_output_data(taged_table, nil, options[:sep])
