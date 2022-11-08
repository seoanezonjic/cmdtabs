#!/usr/bin/env ruby

require 'xsv'
require File.join(File.dirname(__FILE__), 'test_helper.rb')

class Tests < MiniTest::Test

	def test_shift_by_array_indexes
		line = ["HGNC:21197", "483_ref", "1039_ref", "1071_ref"]
		cols_to_show = [0]
		test_result = shift_by_array_indexes(line, cols_to_show)
		expected_result = ["HGNC:21197"]
		assert_equal expected_result, test_result
	end

	def test_expanded_match_i
		string = "Hello world"
		pattern = "Hello"
		match_test = expanded_match(string, pattern, "i")
		expected_result = true
		assert_equal expected_result, match_test
	end

	def test_expanded_match_c
		string = "Hello world"
		pattern = "Hello"
		match_test = expanded_match(string, pattern, "c")
		expected_result = false
		assert_equal expected_result, match_test
	end

	def test_extract_columns
		x = Xsv.open(File.join(DATA_TEST_PATH, 'cluster_genes.xlsx'))
		sheet = x.sheets[0]
		test_result = extract_columns(sheet, [0, 2])
		expected_result =[['HGNC:21197', '1039_ref'], ['HGNC:21143', '4705_ref']]
		assert_equal expected_result, test_result
	end

end