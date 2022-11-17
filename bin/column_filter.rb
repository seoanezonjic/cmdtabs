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

        options[:cols_to_show] = nil
        opts.on( '-c', '--column STRING', 'Column/s to show (1 based). Format: x,y,z..' ) do |column|            
                options[:cols_to_show] = parse_column_indices(sep = ",", column)
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
        opts.on( '-s', '--search STRING', 'c for match in every columns set, s some match in some column. Default c' ) do |search_mode|
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

        options[:header] = nil
        opts.on( '-H', '--header', 'indicate if files have header' ) do 
                options[:header] = true
        end

        # Set a banner, displayed at the top of the help screen.
        opts.banner = "Usage: column_filter.rb -t tabulated_file \n\n"

        # This displays the help screen
        opts.on( '-h', '--help', 'Display this screen' ) do
                puts opts
                exit
        end

end 
optparse.parse!

##################################################################################################
## MAIN
##################################################################################################
abort('Tabulated file not specified') if options[:table_file].nil?
file_names = Dir.glob(options[:table_file])
input_files = load_several_files(file_names, options[:separator])
filtered_table = merge_and_filter_tables(input_files, options)
write_output_data(filtered_table)
 