#!/usr/bin/env ruby 


def load_input_data(input_path, sep="\t", limit=0)
	if input_path == '-'
	  input_data = STDIN
	else
	  input_data = File.readlines(input_path)
	end
	input_data_arr = input_data.map {|line| line = line.chomp.split(sep, limit)}
	return input_data_arr
end 

def load_several_files(all_files, sep = "\t", limit=0)
        loaded_files = {}
        all_files.each do |file|
				if FileTest.directory?(file)
                	STDERR.puts "#{file} is not a valid file"
                	next
				end
                loaded_files[file] = load_input_data(file, sep, limit)
        end
        return loaded_files
end

def index_array(array, col_from=0, col_to=1)
	indexed_array = {}
	array.each do |elements|
		indexed_array[elements[col_from]] = elements[col_to]
	end
	return indexed_array
end

def write_output_data(output_data, output_path=nil, sep="\t")
	if !output_path.nil?
		File.open(output_path, 'w') do |out_file|
			output_data.each do |line|
				out_file.puts(line.join(sep))
			end
		end
	else
		output_data.each do |line|
			STDOUT.puts line.join(sep)		
		end
	end
end

# aggregate_column_data.rb
def aggregate_column(input_table, col_index, col_agg, sep)
  aggregated_data = {}
  aggregated_data_arr = []
  input_table.each do |fields|
    key = fields[col_index]
    val = fields[col_agg]
    query = aggregated_data[key]
    if query.nil?
      aggregated_data[key] = [val]
    else
      query << val
    end
  end
  aggregated_data.each do |k, value|
  	aggregated_data_arr << [k, value.join(sep)]
  end
  return aggregated_data_arr
end


# desaggregate_column_data.rb
def desaggregate_column(input_table, col_index, sep)
  desaggregated_data = []
    
  input_table.each do |fields|
    aggregated_fields = fields[col_index]
    aggregated_fields.split(sep).each do |field|
      record = fields[0..(col_index - 1)] + [field] + fields[(col_index + 1)..fields.length]
      #record = fields[0..(options[:col_index] + 1)] + [field] + fields[(options[:col_index] + 1)..fields.length]
      desaggregated_data << record
    end
  end

  return desaggregated_data
end


# create_metric_table.rb
def index_metrics(input_data, attributes)
	n_attrib = attributes.length
	indexed_metrics = {}
	metric_names = []
	input_data.each do |entry|
		sample_id = entry.shift
		sample_attributes = entry[0..n_attrib - 1]
		metric_name, metric = entry[n_attrib..n_attrib + 1]
		metric_names << metric_name if !metric_names.include?(metric_name)
		query = indexed_metrics[sample_id]
		if query.nil?
			indexed_metrics[sample_id] = {metric_name => metric}
			attributes.each_with_index do |attrib, i|
				indexed_metrics[sample_id][attrib] = sample_attributes[i] 
			end
		else
			query[metric_name] = metric
		end
	end
	return metric_names, indexed_metrics
end

def create_table(indexed_metrics, samples_tag, attributes, metric_names)
	allTags = attributes + metric_names
	table_output = []
	corrupted_records = []
	indexed_metrics.each do |sample_name, sample_data|
		record = [sample_name]
	 	allTags.each do |tag|
			record << sample_data[tag]
	 	end
	 	if record.count(nil) > 0
	 		warn("Record #{sample_name} is corrupted:\n#{record.inspect}")
	 		corrupted_records << record
	 	else
	 		table_output << record
	 	end
	end
	allTags.unshift(samples_tag)
	table_output.unshift(allTags) # Add header
	corrupted_records.unshift(allTags) # Add header
	return table_output, corrupted_records
end


#intersect_columns.rb
def load_records(input_file, cols, full)
	records = {}
	full_row_of_records = {}
	input_file.each do |fields|
		field = cols.map { |c| fields[c]}
		records[field] = true
		full_row_of_records[field] = fields if full
	end
	return records.keys, full_row_of_records
end


# merge_tabular.rb
def load_files(files_path)
	files = {}
	files_path.each do |file_name|
		file = []
		input_table = load_input_data(file_name)
		input_table.each do |fields|
			fields.map{|field|
				if field == ""
					'-'
				else
					field
				end
			}
			next if fields.count('-') == fields.length #skip blank records
			file << fields
		end
		files[file_name] = file
	end
	return files
end


def merge_files(files)
	parent_table = {}
	parent_table_arr = []
	table_length = 0
	files.each do |file_names, file|
		local_length = 0
		file.each do |fields|
			
			id = fields.shift 
			local_length = fields.length
			if !parent_table.has_key?(id)
				parent_table[id] = Array.new(table_length,'-')
			elsif parent_table[id].length < table_length
				parent_table[id].concat(Array.new(table_length-parent_table[id].length,'-'))
			end
			parent_table[id].concat(fields)
			
		end
		table_length += local_length
		
		parent_table.each do |id, fields|
			diference = table_length - fields.length
			fields.concat(Array.new(diference,'-')) if diference > 0
			parent_table_arr << [id, fields]
		end
			
	end
	return parent_table_arr
end


# standard_name_replacer.rb
def name_replaces(tabular_input, sep, cols_to_replace, indexed_file_index)
	translated_fields = []
	untranslated_fields = []
	tabular_input.each do |fields|
		cols_to_replace.each do |col|
			replaced_field = indexed_file_index[fields[col]]
			if !replaced_field.nil?
				fields[col] = replaced_field 
				translated_fields << fields
			else 
				untranslated_fields << fields
			end
		end
	end
	return translated_fields, untranslated_fields
end


# column_filter
def merge_and_filter_tables(input_files, options)
        header = []
        filtered_table = []
        options[:cols_to_show] = (0..input_files.first[0].length - 1).to_a if options[:cols_to_show].nil?
        input_files.each do |filename, file|
			if options[:header].nil?
				if header.empty? 
                    header = file.shift
				else
        	        file.shift
				end 
			end
        	filtered_table = filtered_table.concat(filter_columns(file, options)) 
        end	
        filtered_table = filtered_table.uniq if options[:uniq]
		if !header.empty?
	        header = shift_by_array_indexes(header, options[:cols_to_show])
	        filtered_table.unshift(header)
		end
        return filtered_table
end

def parse_column_indices(sep, col_string)
    cols = col_string.split(sep).map{|col| col.to_i- 1}
    return cols
end

def build_pattern(col_filter, keywords)
    pattern = {}
    if !col_filter.nil? && !keywords.nil?
        keys_per_col = keywords.split('%')
        abort('Number of keywords not equal to number of filtering columns') if keys_per_col.length != col_filter.length
        col_filter.each_with_index do |col, i|
            pattern[col] = keys_per_col[i].split('&')
        end
    end
    return pattern
end

def expanded_match(string, pattern, match_mode)
    is_match = false
    is_match = true if string.include?(pattern) && match_mode == 'i'
    is_match = true if string == pattern && match_mode == 'c'
    return is_match
end

def filter(line, all_patterns, search_mode, match_mode, reverse = false)
    filter = false
    all_patterns.each do |col, patterns|
        is_match = false
        patterns.each do |pattern|
            is_match = expanded_match(line[col], pattern, match_mode)
        	break if is_match     
        end
        if is_match && search_mode == 's'
            filter = false
            break
        elsif !is_match && search_mode == 'c'
            filter = true
            break
        elsif !is_match
            filter = true
        end
    end
    if reverse
        filter = !filter
    end
    return filter
end

def filter_columns(input_table, options)
	pattern = build_pattern(options[:col_filter], options[:keywords])
	filtered_table = []
	input_table.each do |line|
        if pattern.nil? || !filter(line, pattern, options[:search_mode], options[:match_mode], options[:reverse])
        	filtered_table << shift_by_array_indexes(line, options[:cols_to_show]) 
        end
	end
	return filtered_table
end

def shift_by_array_indexes(arr_sub, indexes)
	subsetted_arr = indexes.map{ |idx| arr_sub[idx]}
    return subsetted_arr
end

# table_linker.rb
def link_table(indexed_linker, tabular_file, drop_line, sep)
	linked_table = []
	tabular_file.each do |fields|
		id = fields.first
		info_id = indexed_linker[id]
		if !info_id.nil?
			linked_table << fields.push(info_id)
		else
			linked_table << fields if !drop_line
		end
	end
	return linked_table
end

# tag_table.rb
def load_and_parse_tags(tags, sep)
	parsed_tags = []
	tags.map do |tag| 
		if File.exist?(tag)
			parsed_tags << load_input_data(tag, sep)
			break
		else
			parsed_tags << tag.split(sep)
		end
	end
	return parsed_tags.flatten
end

def tag_file(input_file, tags, header)
	taged_file = []
	empty_header = Array.new(tags.length, "") if header
	input_file.each_with_index do |fields, n_row|
		if n_row == 0 && header
			taged_file << empty_header.dup.concat(fields)
			next
		end
		taged_file << tags.dup.concat(fields)
	end
	return taged_file
end


def extract_columns(table, columns2extract)
	storage = []
	table.each do |row|
		storage << shift_by_array_indexes(table, columns2extract)
	end
	return storage
end