$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "cmdtabs.rb"
require "minitest/autorun"
ROOT_PATH = File.dirname(__FILE__)
DATA_TEST_PATH = File.join(ROOT_PATH, 'data_tests')