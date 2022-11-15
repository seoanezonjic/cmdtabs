#!/usr/bin/env bash

source ~soft_bio_267/initializes/init_ruby
export PATH=`pwd`/bin:$PATH
test_data=test/data_tests/
out=output_test_scripts 
mkdir $out

#aggregate_column_data


aggregate_column_data.rb -i $test_data/cluster_genes_dis_desagg -x 1 -s "," -a 2 1> $out/cluster_genes_dis_AGG
cat $test_data/cluster_genes_dis_desagg | aggregate_column_data.rb -i '-' -x 1 -s "," -a 2 1> $out/cluster_genes_dis_AGG_stdin


#desaggregate_column_data
desaggregate_column_data.rb -i $test_data/cluster_genes_dis_agg -x 1 1> $out/cluster_genes_dis_DESAGG
cat $test_data/cluster_genes_dis_agg| aggregate_column_data.rb -i '-' -x 2 -s "," -a 1 1> $out/cluster_genes_dis_DESAGG_stdin


#create_metric_table
create_metric_table.rb $test_data/all_metrics sample $out/metric_table -c TEST_file

#merge_tabular
#merge_tabular.rb $test_data/disease_gene $test_data/disease_cluster > $out/merge_disease_cluster_gene

#tag_table
tag_table.rb -i $test_data/cluster_stats -t $test_data/tracker 1> $out/tag_table

# intersect_columns.rb
##default values
intersect_columns.rb -a $test_data/disease_cluster -b $test_data/disease_gene -A 1 -B 1 1> $out/intersect_columns_default
##STDIN a
cat $test_data/disease_cluster | intersect_columns.rb -a'-' -b $test_data/disease_gene -A 1 -B 1 1> $out/intersect_columns_default_stdin_a
##STDIN b
cat $test_data/disease_gene | intersect_columns.rb -a $test_data/disease_cluster -b '-' -A 1 -B 1 1> $out/intersect_columns_default_stdin_b
##STDIN a y b
#cat $test_data/disease_cluster, $test_data/disease_gene | intersect_columns.rb $test_data/disease_gene -a'-' -b '-' -A 1 -B 1 > $out/intersect_columns_default_stdin_a_b
##count = true
intersect_columns.rb -a $test_data/disease_cluster -b $test_data/disease_gene -A 1 -B 1 -c 1> $out/intersect_columns_count
##keep = 'ab'
#intersect_columns.rb -a $test_data/disease_cluster -b $test_data/disease_gene -A 1 -B 1 -k 'ab' > $out/intersect_columns_ab
##full = true
intersect_columns.rb -a $test_data/disease_cluster -b $test_data/disease_gene -A 1 -B 1 --full  1> $out/intersect_columns_full
exit

#table_linker
table_linker.rb -i $test_data/disease_cluster -l $test_data/disease_gene -o $out/linked_table

table_linker.rb -i $test_data/disease_gene -l $test_data/disease_cluster -o $out/linked_table_2

table_linker.rb -i $test_data/disease_cluster -l $test_data/disease_gene -o $out/linked_table_matches --drop


#standard_name_replacer
standard_name_replacer.rb -i $test_data/disease_cluster -I $test_data/disease_gene -o $out/replaced_name -c 1 -f 1 -t 2
