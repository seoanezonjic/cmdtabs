#!/usr/bin/env ruby

#####################################################################
## METHODS
######################################################################
def index_metrics(input_data, samples_tag, attributes)
	indexed_metrics = {}
	metric_names = []
	n_attrib = attributes.length
	input_data.each do |entry|
		samples_tag = entry.shift
		sample_attributes = entry[0..n_attrib - 1]
		metric = entry[n_attrib..n_attrib + 1]
		metric_name = metric.shift
		metric = metric.shift
		metric_names << metric_name if !metric_names.include?(metric_name)
		query = indexed_metrics[samples_tag]
		if query.nil?
			indexed_metrics[samples_tag] = {metric_name => metric}
			attributes.each_with_index do |attrib, i|
				indexed_metrics[samples_tag][attrib] = sample_attributes[i] 
			end
		else
			query[metric_name] = metric
		end
	end
	return metric_names, indexed_metrics
end



def create_table (indexed_metrics, samples_tag, attributes, metric_names)
	table_output = []
	allTags = attributes.concat(metric_names)

	header = allTags.dup
	header.unshift(samples_tag)
	table_output << header
	indexed_metrics.each do |sample_name, sample_data|
		formatted_line = [sample_name]
	 	allTags.each do |tag|
			formatted_line << sample_data[tag]
	 	end
	 	table_output << formatted_line
	end
	return table_output
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
metric_names, indexed_metrics = index_metrics(metric_file, samples_tag, attributes)
table_output = create_table(indexed_metrics, samples_tag, attributes, metric_names)
save_table(table_output, ARGV[2])