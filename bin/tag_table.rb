#!/usr/bin/env ruby

require 'optparse'
def load_and_parse_tags(tags, sep)
	parsed_tags = []
	tags.map do |tag| 
		if File.exist?(tag)
			File.open(tag).each do |line|
				parsed_tags << line.chomp.split(sep)
				break
			end
		else
			parsed_tags << tag.split(sep)
		end
	end
	return parsed_tags.flatten
end

def tag_and_write_file(input_file, tags, header, sep)
	empty_header = Array.new(tags.length, "") if header
	
		input_file.each_with_index do |fields, n_row|
			if n_row == 0 && header 
				puts empty_header.dup.concat(fields).join(sep)
				next
			end
			puts tags.dup.concat(fields).join(sep)
		end
	
end

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

input_file = File.readlines(options[:input_file]).map{|line| line.chomp.split("\t") }
tags = load_and_parse_tags(options[:tags], options[:sep])
tag_and_write_file(input_file, tags, options[:header], options[:sep])