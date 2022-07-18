#!/usr/bin/env ruby

#####################################################################
## METHODS
######################################################################
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

##################################################################################################
## MAIN
##################################################################################################

metric_file = File.readlines(ARGV[0]).map {|line| line = line.chomp.split("\t")}
attributes = ARGV[1].split(',')
samples_tag = attributes.shift
metric_names, indexed_metrics = index_metrics(metric_file, attributes)
table_output, corrupted_records = create_table(indexed_metrics, samples_tag, attributes, metric_names)
save_table(table_output, ARGV[2])
save_table(corrupted_records, ARGV[3]) if !ARGV[3].nil?