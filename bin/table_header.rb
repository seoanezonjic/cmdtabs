#!/usr/bin/env ruby

ROOT_PATH = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.expand_path(File.join(ROOT_PATH, '..', 'lib')))

require 'find'
require 'optparse'
require 'cmdtabs'


#################################################################################################
## INPUT PARSING
#################################################################################################
options = {}

optparse = OptionParser.new do |opts|
        options[:table_file] = nil
        opts.on( '-t', '--table_file FILE', 'Input tabulated file' ) do |table_file|
            options[:table_file] = table_file
        end

        options[:column] = [0]
        opts.on( '-c', '--column STRING', 'Column/s to show. Format: x,y,z..' ) do |column|            
                options[:column] = parse_column_indices(sep = ",", column)
        end

        options[:col_filter] = nil
        opts.on( '-f', '--col_filter STRING', 'Select columns where search keywords. Format: x,y,z..' ) do |col_filter|
                options[:col_filter] =  parse_column_indices(sep = ",", col_filter)
        end      

        options[:keywords] = nil
        opts.on( '-k', '--keywords STRING', 'Keywords for select rows. Format: key1_col1&key2_col1%key1_col2&key2_col2' ) do |keywords|
                options[:keywords] = keywords
        end

        options[:search_mode] = 'c'
        opts.on( '-s', '--search STRING', 'c a match per column, s some match in some column. Default c' ) do |search_mode|
                options[:search_mode] = search_mode
        end

        options[:match_mode] = 'i'
        opts.on( '-m', '--match_mode STRING', 'i string must include the keyword, c for fullmatch. Default i') do |match_mode|
                options[:match_mode] = match_mode
        end

        options[:separator] = "\t"
        opts.on( '-p', '--separator STRING', 'Separator used in fields. Default i') do |separator|
                options[:separator] = separator
        end

        options[:reverse] = false
        opts.on( '-r', '--reverse', 'Select not matching' ) do 
                options[:reverse] = true
        end

        options[:uniq] = false
        opts.on( '-u', '--uniq', 'Delete redundant items' ) do 
                options[:uniq] = true
        end

        # Set a banner, displayed at the top of the help screen.
        opts.banner = "Usage: table_header.rb -t tabulated_file \n\n"

        # This displays the help screen
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
if options[:table_file].nil?
	puts 'Tabulated file not specified'
	Process.exit
end

pattern = build_pattern(options[:col_filter], options[:keywords])

names = []
options[:column].length.times do
    names << []
end
if options[:table_file].include?('*')
	Find.find(Dir.pwd) do |path|
		if FileTest.directory?(path)
			next
		else
           	if File.basename(path) =~ /#{options[:table_file]}/
				names = check_file(path, names, options, pattern) 
			end
		end
	end	
else
	names = check_file(options[:table_file], names, options, pattern)
end

report(names)
