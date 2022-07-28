#!/usr/bin/env ruby 

# aggregate_column_data.rb
def aggregate_column (input_table, col_index, col_agg)
  input_table
  aggregated_data = {}
  input_table.each do |line|
    fields = line.chomp.split("\t")
    key = fields[col_index]
    val = fields[col_agg]
    query = aggregated_data[key]
    if query.nil?
      aggregated_data[key] = [val]
    else
      query << val
    end
  end
  return aggregated_data
end

def save_aggregated (agg_data, sep)
	agg_data.each do |key, values|
		STDOUT.puts "#{key}\t#{values.join(sep)}"		
	end
	
end

# desaggregate_column_data.rb
def desaggregate_column (input_table, col_index, sep)
  desaggregated_data = []
    
  input_table.each do |line|
    fields = line.chomp.split("\t")
    aggregated_fields = fields[col_index]
    aggregated_fields.split(sep).each do |field|
      record = fields[0..(col_index - 1)] + [field] + fields[(col_index + 1)..fields.length]
      #record = fields[0..(options[:col_index] + 1)] + [field] + fields[(options[:col_index] + 1)..fields.length]
      desaggregated_data << record
    end
  end

  return desaggregated_data
end

def save_desaggregated (desagg_data)
	desagg_data.each do |line|
		STDOUT.puts line.join("\t")
		
	end
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

def create_table (indexed_metrics, samples_tag, attributes, metric_names)
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

def save_table(table_output, output_path)
	File.open(output_path, 'w') do |out_file|
		table_output.each do |line|
			out_file.puts(line.join("\t"))
		end
	end
end

#intersect_columns.rb
def load_records(path_file, cols, sep, full)
	records = {}
	full_row_of_records = {}
	if path_file == '-'
		input_file  = STDIN
	else
		input_file = File.open(path_file)
	end
	input_file.each do |line|
		fields = line.chomp.split(sep)
		field = cols.map { |c| fields[c]}
		records[field = true]
		full_row_of_records[field] = fields if full
	end
	return records.keys, full_row_of_records
end

def print_records(records, sep)
	records.each do |record|
		puts record.join(sep)
	end
end

# merge_tabular.rb
def load_files (files_path)
	files = {}
	
	files_path.each do |file_name|
		file = []
		File.open(file_name).each do |line|
			line.chomp!
			n_fields = line.count("\t")+1
			fields = line.split("\t", n_fields).map{|field|
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


def merge_files (files)
	parent_table = {}
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
		end
			
	end
	return parent_table
end


def print_table_from_hash(parent_table)
	parent_table.each do |id, fields|
		puts id+"\t"+fields.join("\t")
	end
	
end

# standard_name_replacer.rb
def load_and_index_file_index (path_file_index, col_from, col_to)
	indexed_file_index = {}
	File.open(path_file_index).read.each_line do |line|
		line.chomp!
		fields = line.split("\t")
		indexed_file_index[fields[col_from]] = fields[col_to]
	end
	return indexed_file_index
end

def name_replaces (tabular_input, sep, cols_to_replace, indexed_file_index)
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

def save_tabular_with_sep (output_path, sep, tabular_output) 
	File.open(output_path,'w') do |out_file|
		tabular_output.each do |line|
			out_file.puts line.join(sep)
		end
	end
end 

# table_header
def parse_column_indices(sep, col_string)
    cols = col_string.split(sep).map{|col| col.to_i}
    return cols
end

def build_pattern(col_filter, keywords)
    pattern = {}
    if !col_filter.nil? && !keywords.nil?
        keys_per_col = keywords.split('%')
        if keys_per_col.length != col_filter.length
            puts 'Number of keywords not equal to number of filtering columns'
            Process.exit
        end
        col_filter.each_with_index do |col, i|
            pattern[col] = keys_per_col[i].split('&')
        end
    end
    return pattern
end

def match(string, key, match_mode)
    match = false
    if string.nil?
        match = false
    elsif  match_mode == 'i'
        match = string.include?(key)
    elsif match_mode == 'c'
        if string == key
            match = true
        end
    end
    return match
end

def filter(header, pattern, search_mode, match_mode, reverse = false)
    filter = false
    pattern.each do |col,keys|
        match = false
        keys.each do |key|
            if match(header[col], key, match_mode)
                match =true
            end
        end
        if match
            if search_mode == 's'
                filter = false
                break
            end
        elsif !match && search_mode == 'c'
            filter = true
            break
        elsif !match
            filter = true
        end
    end
    if reverse
        filter = !filter
    end
    return filter
end

def check_file(file, names, options, pattern)
    if file == '-'
        input = STDIN
    else
        input = File.open(file)
    end
    relations = relations(options[:column])
	input.read.each_line do |line|
		line.chomp!
		header = line.split(options[:separator])
        if pattern.nil? || !filter(header, pattern, options[:search_mode], options[:match_mode], options[:reverse])
            options[:column].each do |col|
        		if !options[:check_uniq] || !names[relations[col]].include?(header[col]) 
        			names[relations[col]] << header[col]
        		end
            end
        end
	end
	return names
end

def relations(column)
    relations = {}
    column.each_with_index do |col,i|
        relations[col] = i
    end
    return relations
end

def report(names)
    n_col = names.length
    names.first.length.times do |y|
        n_col.times do |x|
		string = "#{names[x][y]}"
		if x < n_col-1
			string << "\t"
		end
            print string
        end
        puts
    end
end

# table_linker.rb
def index_linker (file_linker)
	indexed_linker = {}
	File.open(file_linker,'r').each do |line|
		fields = line.chomp.split("\t",2)
		indexed_linker[fields.first] = fields.last
	end
	return indexed_linker
end

def link_table (indexed_linker, tabular_file, drop_line, sep)
	linked_table = []
	tabular_file.each do |line|
		fields = line.split(sep)
		id = fields.first
		info_id = indexed_linker[id]
		if !info_id.nil?
			linked_table << line+sep+info_id
		else
			linked_table << line if !drop_line
		end
	end
	return linked_table
end

def save_tabular_without_sep (output_path, linked_table)
	File.open(output_path,'w') do |out_file|
		linked_table.each do |line|
			out_file.puts line
		end
	end
end

# tag_table.rb
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

def extract_data_from_sheet(sheet, storage, header, id_col, data_col, data_type)
	sheet.each do |row|
	  #eliminate header
	  #parse hpo
	  next if row.include?(header)
	  id_col = row[id_col - 1]
	  data_col = row[data_col - 1]
	  if data_type == 'enod'
	    #ENOD dataset has spaces within HPO codes (HP: ). They must be parsed.
	    data_col = data_col.gsub('HP: ', 'HP:').split(' ')
	  end
	  data_col.each do |data|
	    storage << [id_col, data]
	  end
	end
end

def write_tab_file(output_path, content)
	File.open(output_path, 'w') do |f|
	  content.each do |row|
	    f.puts "#{row.join("\t")}"
	  end
	end
end