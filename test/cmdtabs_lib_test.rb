#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'test_helper.rb')


class Tests < MiniTest::Test
	
	def test_aggregate_column
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'cluster_genes_dis_desagg'))
		aggrgated_test = aggregate_column(input_table, 0, 1, ", ") 
		expected_result = [['HGNC:21197', '483_ref, 1039_ref, 1071_ref'], ['HGNC:21143', '211_ref, 4705_ref']]
		assert_equal expected_result, aggrgated_test
	end

	def test_desaggregate_column
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg'))
		desaggregated_test = desaggregate_column(input_table, 1, ',')
		expected_result = [['HGNC:21197', '483_ref'], ['HGNC:21197', '1039_ref'], ['HGNC:21197', '1071_ref'], ['HGNC:21143', '211_ref'], ['HGNC:21143', '4705_ref']]
		assert_equal expected_result, desaggregated_test
	end

	def test_create_table
		metric_file = load_input_data(File.join(DATA_TEST_PATH, 'all_metrics'))
		attributes = []
		samples_tag = 'sample'
		metric_names, indexed_metrics = index_metrics(metric_file, attributes)
		create_table_test = create_table(indexed_metrics, samples_tag, attributes, metric_names)
		expected_result = [[["sample", "initial_total_sequences", "initial_read_max_length", "initial_read_min_length", "initial_%gc"], 
			["CTL_1_cell", "11437331.0", "76.0", "35.0", "45.0"], ["CTL_1_exo", "10668412.0", "76.0", "35.0", "48.0"]], [["sample", "initial_total_sequences", "initial_read_max_length", "initial_read_min_length", "initial_%gc"]]]
		assert_equal expected_result, create_table_test
	end

	def test_name_replacer
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'disease_cluster'))
		input_index = load_input_data(File.join(DATA_TEST_PATH, 'disease_gene'))
		indexed_index = index_array(input_index)
		name_replaces_test = name_replaces(input_table, "\t", [0], indexed_index, remove_uns=true)
		expected_result = [['HGNC:16873', '19_ref'], ["HGNC:21197", "36_ref"], ["HGNC:21197", "53_ref"], ["HGNC:21144", "53_ref"], ['HGNC:3527', '54_ref'], ["HGNC:21144", "66_ref"], ['HGNC:21176', '1189_ref']], 
			[["MONDO:0007172", "22_ref"], ["MONDO:0014823", "25_ref"], ["MONDO:0009833", "53_ref"], 
			["MONDO:0009594", "54_ref"], ["MONDO:0012176", "62_ref"]]
		assert_equal expected_result, name_replaces_test
	end

	def test_link_table
		input_linker = load_input_data(File.join(DATA_TEST_PATH, 'disease_cluster'))
		indexed_linker = index_array(input_linker)
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'disease_gene'), "\t", 2)
		linked_test = link_table(indexed_linker, input_table, false, "\t")
		expected_result = [["MONDO:0010193", "HGNC:3527", "54_ref"], ["MONDO:0008995", "HGNC:16873", "19_ref"], 
			["MONDO:0012866", "HGNC:21197"], ["MONDO:0017999", "HGNC:21197", "53_ref"], ["MONDO:0011142", "HGNC:21144", "66_ref"], 
			["MONDO:0013969", "HGNC:21176", "1189_ref"], ["MONDO:0018053", "HGNC:21157"]]
		assert_equal expected_result, linked_test
	end

	def test_link_table_drop
		input_linker = load_input_data(File.join(DATA_TEST_PATH, 'disease_cluster'))
		indexed_linker = index_array(input_linker)
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'disease_gene'), "\t", 2)
		linked_test = link_table(indexed_linker, input_table, true, "\t")
		expected_result = [["MONDO:0010193", "HGNC:3527", "54_ref"], ["MONDO:0008995", "HGNC:16873", "19_ref"], 
			["MONDO:0017999", "HGNC:21197", "53_ref"], ["MONDO:0011142", "HGNC:21144", "66_ref"], 
			["MONDO:0013969", "HGNC:21176", "1189_ref"]]
		assert_equal expected_result, linked_test
	end

	def test_tag_file
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg'))
		tags = load_and_parse_tags([File.join(DATA_TEST_PATH, 'tracker')], "\t")
		taged_test = tag_file(input_table, tags, false)
		expected_result = [['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm', 'HGNC:21197', '483_ref,1039_ref,1071_ref'], 
			['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm', 'HGNC:21143', '211_ref,4705_ref']]
		assert_equal expected_result, taged_test
	end

	def test_tag_file_header
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg'))
		tags = load_and_parse_tags([File.join(DATA_TEST_PATH, 'tracker')], "\t")
		taged_test = tag_file(input_table, tags, true)
		expected_result = [['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm', 'HGNC:21143', '211_ref,4705_ref']]
		assert_equal expected_result, taged_test
	end

	def test_filter_s_i
		line = ["HGNC:21197", "483_ref", "1039_ref", "1071_ref"]
		col_filter = [0, 1, 2, 3]
		keywords = "HGNC&ref%ref%ref%ref"
		patterns =  build_pattern(col_filter, keywords)
		filter_test = filter(line, patterns, "s", "i")
		expected_result = false
		assert_equal  expected_result, filter_test
	end

	def test_filter_s_i_true
		line = ["HGNC:21197", "483_ref", "1039_ref", "1071_ref"]
		col_filter = [0, 1, 2, 3]
		keywords = "HGNC&ref%ref%ref%ref"
		patterns =  build_pattern(col_filter, keywords)
		filter_test = filter(line, patterns, "s", "i", true)
		expected_result = true
		assert_equal  expected_result, filter_test
	end

	def test_filter_c_i
		line = ["HGNC:21197", "483_ref", "1039_ref", "1071_ref"]
		col_filter = [0, 1, 2, 3]
		keywords = "ref%ref%ref%ref"
		patterns =  build_pattern(col_filter, keywords)
		filter_test = filter(line, patterns, "c", "i")
		expected_result = true
		assert_equal  expected_result, filter_test
	end

	def test_filter_c_c
		line = ["HGNC:21197", "483_ref", "1039_ref", "1071_ref"]
		col_filter = [0, 1, 2, 3]
		keywords = "HGNC&ref%ref%ref%ref"
		patterns =  build_pattern(col_filter, keywords)
		filter_test = filter(line, patterns, "c", "c")
		expected_result = true
		assert_equal  expected_result, filter_test
	end	

	def test_filter_columns
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'cluster_genes_dis_desagg'))
		options = {:col_filter => [0], :keywords => "21197", :search_mode => "s", :match_mode => "i", :reverse => false, :cols_to_show => [0, 1]}
		filter_columns_test = filter_columns(input_table, options)
		expected_result = [["HGNC:21197", "483_ref"], ["HGNC:21197", "1039_ref"], ["HGNC:21197", "1071_ref"]]
		assert_equal expected_result, filter_columns_test
	end

	def test_merge_and_filter_tables
		options = {:header => nil, :col_filter => [0], :keywords => "0008995&0017999&0013969&0009594", 
			:search_mode => "s", :match_mode => "i", :reverse => false, :cols_to_show => [0, 1]}
		input_tables = load_several_files([File.join(DATA_TEST_PATH, 'disease_cluster'), File.join(DATA_TEST_PATH, 'disease_gene')])
		test_result = merge_and_filter_tables(input_tables, options)
		expected_result = [["MONDO:0008995", "19_ref"], ["MONDO:0017999", "36_ref"], ["MONDO:0017999", "53_ref"], ["MONDO:0009594", "54_ref"], 
		["MONDO:0013969", "1189_ref"], ["MONDO:0008995", "HGNC:16873"], ["MONDO:0017999", "HGNC:21197"], ["MONDO:0013969", "HGNC:21176"]]
		assert_equal expected_result, test_result
	end
end

