#!C:\perl -w

use strict;
##############################################################
# script for testing correctness in symmetrical matrices w/o using 
# matrix library Math::MatrixReal
##############################################################

my $arr_str = [[1, 2, 3 ],  [1, 3, 2],  [2, 3, 1 ]];  #[3, 1, 2]

&test_str_arr($arr_str);
exit(0);

sub test_str_arr($){
	my $arr_ref = shift;
	my @arr = @$arr_ref;
	my ($arr_refer, $i);
	my @temp_arr;
	#print join '-', @arr;
	
	for ($i =0; $i <= $#arr; $i++){
		my @column = ();
		
		foreach (@arr){
			$arr_refer = $_;
			@temp_arr = @$arr_refer;
			if !check_for_duplicates(\@temp_arr){
				print "duplicate found\n";
				last;
			}
			push @column, $temp_arr[$i]; 
		}
		print "duplicate found" unless check_for_duplicates(\@column);
	}
}

sub check_for_duplicates($){
	my %hashd;
	my $arr_ref = shift;
	my @atmp = @$arr_ref;
	foreach (@atmp){
		$hashd{$_}++;
	} 
	return keys %hashd == $#atmp + 1;  
}

