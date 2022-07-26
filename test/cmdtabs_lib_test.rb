#!/usr/bin/env ruby

ROOT_PATH = File.dirname(__FILE__)
DATA_TEST_PATH = File.join(ROOT_PATH, 'data_tests')

require File.join(ROOT_PATH, 'test_helper.rb')

class Tests < MiniTest::Test

	# aggregate_column_data_test
	def test_aggregate_column
		file = File.open(File.join(DATA_TEST_PATH, 'cluster_genes_dis_desagg'))
		expected_result = {'HGNC:21197' => ['483_ref', '1039_ref', '1071_ref'], 'HGNC:21143' => ['211_ref', '4705_ref']}
		assert_equal expected_result, aggregate_column(file, 0, 1)
	end

	# desaggregate_column_data_test
	def test_desaggregate_column
		file = File.open(File.join(DATA_TEST_PATH, 'cluster_genes_dis_agg'))
		expected_result = [['HGNC:21197', '483_ref'], ['HGNC:21197', '1039_ref'], ['HGNC:21197', '1071_ref'], ['HGNC:21143', '211_ref'], ['HGNC:21143', '4705_ref']]
		assert_equal expected_result, desaggregate_column(file, 1, ',')
	end

	# create_metric_table_tests
	def test_index_metrics
		metric_file = File.readlines(File.join(DATA_TEST_PATH, 'all_metrics')).map {|line| line = line.chomp.split("\t")}
		fixCols = 'sample'
		attributes = fixCols.split(',')
		samples_tag = attributes.shift
		expected_result = ['initial_total_sequences', 'initial_read_max_length', 'initial_read_min_length', 'initial_%gc'],
			{'CTL_1_cell' => {'initial_total_sequences' => '11437331.0', 'initial_read_max_length' => '76.0', 
				'initial_read_min_length' => '35.0', 'initial_%gc' => '45.0'}, 'CTL_1_exo' => {'initial_total_sequences' => '10668412.0', 
				'initial_read_max_length' => '76.0', 'initial_read_min_length' => '35.0', 'initial_%gc' => '48.0'}}
		assert_equal expected_result, index_metrics(metric_file, samples_tag, attributes)
	end

	def test_create_table
		metric_file = File.readlines(File.join(DATA_TEST_PATH, 'all_metrics')).map {|line| line = line.chomp.split("\t")}
		fixCols = 'sample'
		attributes = fixCols.split(',')
		samples_tag = attributes.shift
		metric_names, indexed_metrics = index_metrics(metric_file, samples_tag, attributes)
		expected_result = [["sample", "initial_total_sequences", "initial_read_max_length", "initial_read_min_length", "initial_%gc"], 
			["CTL_1_cell", "11437331.0", "76.0", "35.0", "45.0"], ["CTL_1_exo", "10668412.0", "76.0", "35.0", "48.0"]]
		assert_equal expected_result, create_table(indexed_metrics, samples_tag, attributes, metric_names)
	end

	# intersect_columns_tests
	def test_load_records
		path = File.join(DATA_TEST_PATH, 'disease_cluster')
		expected_result = [['MONDO:0008995'], ['MONDO:0007172'], ['MONDO:0014823'], ['MONDO:0017999'], ['MONDO:0011142'],
			['MONDO:0009833'], ['MONDO:0009594'], ['MONDO:0010193'], ['MONDO:0012176'], ['MONDO:0013969']], {}
		assert_equal expected_result, load_records(path, [0], "\t", false)
	end
	def test_load_records_full
		path = File.join(DATA_TEST_PATH, 'disease_cluster')
		expected_result = [['MONDO:0008995'], ['MONDO:0007172'], ['MONDO:0014823'], ['MONDO:0017999'], ['MONDO:0011142'],
			['MONDO:0009833'], ['MONDO:0009594'], ['MONDO:0010193'], ['MONDO:0012176'], ['MONDO:0013969']], 
			{['MONDO:0008995'] => ['MONDO:0008995', '19_ref'], ['MONDO:0007172'] => ['MONDO:0007172', '22_ref'], 
			['MONDO:0014823'] => ['MONDO:0014823', '25_ref'], ['MONDO:0017999'] => ['MONDO:0017999', '53_ref'],
			['MONDO:0011142'] => ['MONDO:0011142', '66_ref'], ['MONDO:0009833'] => ['MONDO:0009833', '53_ref'],
			['MONDO:0009594'] => ['MONDO:0009594', '54_ref'], ['MONDO:0010193'] => ['MONDO:0010193', '54_ref'], 
			['MONDO:0012176'] => ['MONDO:0012176', '62_ref'], ['MONDO:0013969'] => ['MONDO:0013969', '1189_ref']}
		assert_equal expected_result, load_records(path, [0], "\t", true)
	end

	# standard_name_replacer_tests
	def test_load_and_index_file_index
		file = File.join(DATA_TEST_PATH, 'disease_gene')
		expected_result = {'MONDO:0010193' => 'HGNC:3527', 'MONDO:0008995' => 'HGNC:16873', 'MONDO:0012866' => 'HGNC:21197', 'MONDO:0017999' => 'HGNC:21197', 'MONDO:0011142' => 'HGNC:21144', 'MONDO:0013969' => 'HGNC:21176', 'MONDO:0018053' => 'HGNC:21157'}
		assert_equal expected_result, load_and_index_file_index(file, 0, 1)
	end

	def test_name_replacer
		input_file = File.readlines(File.join(DATA_TEST_PATH, 'disease_cluster')).map {|line| line = line.chomp.split("\t")}
		file = File.join(DATA_TEST_PATH, 'disease_gene')
		index = load_and_index_file_index(file, 0, 1)
		expected_result = [['HGNC:16873', '19_ref'], ["HGNC:21197", "36_ref"], ["HGNC:21197", "53_ref"], ["HGNC:21144", "53_ref"], ['HGNC:3527', '54_ref'], ["HGNC:21144", "66_ref"], ['HGNC:21176', '1189_ref']], 
			[["MONDO:0007172", "22_ref"], ["MONDO:0014823", "25_ref"], ["MONDO:0009833", "53_ref"], 
			["MONDO:0009594", "54_ref"], ["MONDO:0012176", "62_ref"]]
		assert_equal expected_result, name_replaces(input_file, "\t", [0], index)
	end

	# table_linker_tests
	def test_load_file_to_hash
		path = File.join(DATA_TEST_PATH, 'disease_cluster')
		expected_result = {'MONDO:0008995' => '19_ref', 'MONDO:0007172' => '22_ref', 'MONDO:0014823' => '25_ref',
			'MONDO:0017999' => '53_ref', 'MONDO:0011142' => '66_ref', 'MONDO:0009833' => '53_ref', 'MONDO:0009594' => '54_ref', 'MONDO:0010193' => '54_ref',
			'MONDO:0012176' => '62_ref', 'MONDO:0013969' => '1189_ref'}
		assert_equal expected_result, index_linker(path)
	end

	def test_link_table
		path = File.join(DATA_TEST_PATH, 'disease_cluster')
		first_file = index_linker(path)
		second_file = File.readlines(File.join(DATA_TEST_PATH, 'disease_gene')).map {|line| line = line.chomp}
		expected_result = ["MONDO:0010193\tHGNC:3527\t54_ref", "MONDO:0008995\tHGNC:16873\t19_ref", 
			"MONDO:0012866\tHGNC:21197", "MONDO:0017999\tHGNC:21197\t53_ref", "MONDO:0011142\tHGNC:21144\t66_ref", 
			"MONDO:0013969\tHGNC:21176\t1189_ref", "MONDO:0018053\tHGNC:21157"]
		assert_equal expected_result, link_table(first_file, second_file, false, "\t")
	end

	# tag_table_tests
	def test_load_and_parse_tags
		tags = File.open(File.join(DATA_TEST_PATH, 'tracker'))
		expected_result = ['MERGED_net_no_raw_cpm', 'MERGED', 'no', 'no', 'cpm']
		assert_equal expected_result, load_and_parse_tags(tags, "\t")
	end
end

