#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Tests < MiniTest::Test

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

end