#!/usr/bin/env ruby

ROOT_PATH = File.dirname(__FILE__)
DATA_TEST_PATH = File.join(ROOT_PATH, 'data_tests')

require File.join(ROOT_PATH, 'test_helper.rb')

class Tests < MiniTest::Test

	#load_input_data
	def test_load_input_data
		input_file = File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg')
		load_data_test = load_input_data(input_file)
		expected_result = [['HGNC:21197', '483_ref,1039_ref,1071_ref'], ['HGNC:21143', '211_ref,4705_ref']]
		assert_equal expected_result, load_data_test
	end

	def test_load_input_data_sep
		input_file = File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg')
		load_data_test = load_input_data(input_file, ",")
		expected_result = [["HGNC:21197\t483_ref", "1039_ref", "1071_ref"], ["HGNC:21143\t211_ref", "4705_ref"]]
		assert_equal expected_result, load_data_test
	end

	def test_load_input_data_sep_and_limit
		input_file = File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg')
		load_data_test = load_input_data(input_file, ",", 2)
		expected_result = [["HGNC:21197\t483_ref", "1039_ref,1071_ref"], ["HGNC:21143\t211_ref", "4705_ref"]]
		assert_equal expected_result, load_data_test
	end


	# index_array
	def test_index_array
		input_index = load_input_data(File.join(DATA_TEST_PATH, 'disease_gene'))
		indexed_test = index_array(input_index)
		expected_result = {'MONDO:0010193' => 'HGNC:3527', 'MONDO:0008995' => 'HGNC:16873', 'MONDO:0012866' => 'HGNC:21197', 'MONDO:0017999' => 'HGNC:21197', 'MONDO:0011142' => 'HGNC:21144', 'MONDO:0013969' => 'HGNC:21176', 'MONDO:0018053' => 'HGNC:21157'}
		assert_equal expected_result, indexed_test
	end

	# aggregate_column_data_test
	def test_aggregate_column
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'cluster_genes_dis_desagg'))
		aggrgated_test = aggregate_column(input_table, 0, 1, ", ") 
		expected_result = [['HGNC:21197', '483_ref, 1039_ref, 1071_ref'], ['HGNC:21143', '211_ref, 4705_ref']]
		assert_equal expected_result, aggrgated_test
	end

	# desaggregate_column_data_test
	def test_desaggregate_column
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg'))
		desaggregated_test = desaggregate_column(input_table, 1, ',')
		expected_result = [['HGNC:21197', '483_ref'], ['HGNC:21197', '1039_ref'], ['HGNC:21197', '1071_ref'], ['HGNC:21143', '211_ref'], ['HGNC:21143', '4705_ref']]
		assert_equal expected_result, desaggregated_test
	end

	# create_metric_table_tests
	def test_index_metrics
		metric_file = load_input_data(File.join(DATA_TEST_PATH, 'all_metrics'))
		fixCols = 'sample'
		attributes = fixCols.split(',')
		samples_tag = attributes.shift
		indexed_metrics_test = index_metrics(metric_file, attributes)
		expected_result = ['initial_total_sequences', 'initial_read_max_length', 'initial_read_min_length', 'initial_%gc'],
			{'CTL_1_cell' => {'initial_total_sequences' => '11437331.0', 'initial_read_max_length' => '76.0', 
				'initial_read_min_length' => '35.0', 'initial_%gc' => '45.0'}, 'CTL_1_exo' => {'initial_total_sequences' => '10668412.0', 
				'initial_read_max_length' => '76.0', 'initial_read_min_length' => '35.0', 'initial_%gc' => '48.0'}}
		assert_equal expected_result, indexed_metrics_test
	end

	def test_create_table
		metric_file = load_input_data(File.join(DATA_TEST_PATH, 'all_metrics'))
		fixCols = 'sample'
		attributes = fixCols.split(',')
		samples_tag = attributes.shift
		metric_names, indexed_metrics = index_metrics(metric_file, attributes)
		create_table_test = create_table(indexed_metrics, samples_tag, attributes, metric_names)
		expected_result = [[["sample", "initial_total_sequences", "initial_read_max_length", "initial_read_min_length", "initial_%gc"], 
			["CTL_1_cell", "11437331.0", "76.0", "35.0", "45.0"], ["CTL_1_exo", "10668412.0", "76.0", "35.0", "48.0"]], [["sample", "initial_total_sequences", "initial_read_max_length", "initial_read_min_length", "initial_%gc"]]]
		assert_equal expected_result, create_table_test
	end

	# intersect_columns_tests
	def test_load_records
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'disease_cluster'))
		records_test = load_records(input_table, [0], false)
		expected_result = [['MONDO:0008995'], ['MONDO:0007172'], ['MONDO:0014823'], ['MONDO:0017999'], ['MONDO:0011142'],
			['MONDO:0009833'], ['MONDO:0009594'], ['MONDO:0010193'], ['MONDO:0012176'], ['MONDO:0013969']], {}
		assert_equal expected_result, records_test
	end
	def test_load_records_full
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'disease_cluster'))
		records_full_test = load_records(input_table, [0], true)
		expected_result = [['MONDO:0008995'], ['MONDO:0007172'], ['MONDO:0014823'], ['MONDO:0017999'], ['MONDO:0011142'],
			['MONDO:0009833'], ['MONDO:0009594'], ['MONDO:0010193'], ['MONDO:0012176'], ['MONDO:0013969']], 
			{['MONDO:0008995'] => ['MONDO:0008995', '19_ref'], ['MONDO:0007172'] => ['MONDO:0007172', '22_ref'], 
			['MONDO:0014823'] => ['MONDO:0014823', '25_ref'], ['MONDO:0017999'] => ['MONDO:0017999', '53_ref'],
			['MONDO:0011142'] => ['MONDO:0011142', '66_ref'], ['MONDO:0009833'] => ['MONDO:0009833', '53_ref'],
			['MONDO:0009594'] => ['MONDO:0009594', '54_ref'], ['MONDO:0010193'] => ['MONDO:0010193', '54_ref'], 
			['MONDO:0012176'] => ['MONDO:0012176', '62_ref'], ['MONDO:0013969'] => ['MONDO:0013969', '1189_ref']}
		assert_equal expected_result, records_full_test
	end

	# standard_name_replacer_tests
	def test_name_replacer
		input_table = load_input_data(File.join(DATA_TEST_PATH, 'disease_cluster'))
		input_index = load_input_data(File.join(DATA_TEST_PATH, 'disease_gene'))
		indexed_index = index_array(input_index)
		name_replaces_test = name_replaces(input_table, "\t", [0], indexed_index)
		expected_result = [['HGNC:16873', '19_ref'], ["HGNC:21197", "36_ref"], ["HGNC:21197", "53_ref"], ["HGNC:21144", "53_ref"], ['HGNC:3527', '54_ref'], ["HGNC:21144", "66_ref"], ['HGNC:21176', '1189_ref']], 
			[["MONDO:0007172", "22_ref"], ["MONDO:0014823", "25_ref"], ["MONDO:0009833", "53_ref"], 
			["MONDO:0009594", "54_ref"], ["MONDO:0012176", "62_ref"]]
		assert_equal expected_result, name_replaces_test
	end

	# table_linker_tests
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

	# tag_table_tests
	def test_load_and_parse_tags_stdin
		input_tags = ['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm']
		tag_test = load_and_parse_tags(input_tags, "\t")
		expected_result = ['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm']
		assert_equal expected_result, tag_test
	end

	def test_load_and_parse_tags_file
		input_tags = [File.join(DATA_TEST_PATH, 'tracker')]
		tag_test = load_and_parse_tags(input_tags, "\t")
		expected_result = ['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm']
		assert_equal expected_result, tag_test
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
		expected_result = [['', '', '', '', '', 'HGNC:21197', '483_ref,1039_ref,1071_ref'], 
			['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm', 'HGNC:21143', '211_ref,4705_ref']]
		assert_equal expected_result, taged_test
	end
end

