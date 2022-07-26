#!/usr/bin/env bash

source ~soft_bio_267/initializes/init_ruby
export PATH=`pwd`/bin:$PATH
mkdir output_test_scripts

#aggregate_column_data

aggregate_column_data.rb -i test/data_tests/cluster_genes_dis_desagg -x 0 -s "," -a 1 1> output_test_scripts/cluster_genes_dis_AGG
cat test/data_tests/cluster_genes_dis_desagg | aggregate_column_data.rb -i '-' -x 0 -s "," -a 1 1> output_test_scripts/cluster_genes_dis_AGG_stdin


#desaggregate_column_data
desaggregate_column_data.rb -i test/data_tests/cluster_genes_dis_agg -x 1 1> test/output_test_scripts/cluster_genes_dis_DESAGG
cat test/data_tests/cluster_genes_dis_agg| aggregate_column_data.rb -i '-' -x 1 -s "," -a 0 1> output_test_scripts/cluster_genes_dis_DESAGG_stdin



#create_metric_table
create_metric_table.rb test/data_tests/all_metrics sample output_test_scripts/metric_table -c TEST_file

#merge_tabular
#merge_tabular.rb test/data_tests/disease_gene test/data_tests/disease_cluster > output_test_scripts/merge_disease_cluster_gene

#tag_table
tag_table.rb -i test/data_tests/cluster_stats -t test/data_tests/tracker 1> output_test_scripts/tag_table

# intersect_columns.rb
##default values
intersect_columns.rb -a test/data_tests/disease_cluster -b test/data_tests/disease_gene -A 0 -B 0 1> output_test_scripts/intersect_columns_default
##STDIN a
cat test/data_tests/disease_cluster | intersect_columns.rb -a'-' -b test/data_tests/disease_gene -A 0 -B 0 1> output_test_scripts/intersect_columns_default_stdin_a
##STDIN b
cat test/data_tests/disease_gene | intersect_columns.rb -a test/data_tests/disease_cluster -b '-' -A 0 -B 0 1> output_test_scripts/intersect_columns_default_stdin_b
##STDIN a y b
#cat test/data_tests/disease_cluster, test/data_tests/disease_gene | intersect_columns.rb test/data_tests/disease_gene -a'-' -b '-' -A 0 -B 0 > output_test_scripts/intersect_columns_default_stdin_a_b
##count = true
intersect_columns.rb -a test/data_tests/disease_cluster -b test/data_tests/disease_gene -A 0 -B 0 -c true 1> output_test_scripts/intersect_columns_count
##keep = 'ab'
#intersect_columns.rb -a test/data_tests/disease_cluster -b test/data_tests/disease_gene -A 0 -B 0 -k 'ab' > output_test_scripts/intersect_columns_ab
##full = true
intersect_columns.rb -a test/data_tests/disease_cluster -b test/data_tests/disease_gene -A 0 -B 0 --full true 1> output_test_scripts/intersect_columns_full

#table_linker
table_linker.rb -i test/data_tests/disease_cluster -l test/data_tests/disease_gene -o output_test_scripts/linked_table

table_linker.rb -i test/data_tests/disease_gene -l test/data_tests/disease_cluster -o output_test_scripts/linked_table_2

table_linker.rb -i test/data_tests/disease_cluster -l test/data_tests/disease_gene -o output_test_scripts/linked_table_matches --drop true


#standard_name_replacer
standard_name_replacer.rb -i test/data_tests/disease_cluster -I test/data_tests/disease_gene -o output_test_scripts/replaced_name -c 1 -f 1 -t 2
