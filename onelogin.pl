#!bin/Perl -l

use strict;

###############################################################################
# Script onelogin.pl for performing operations with fractional/whole numbers
# Allowed operations: + - * /
# Syntax: >onelogin.pl [a_]b/c <operator> [d_]e/f
# where a, b, c, d, e, f are integers.
###############################################################################

my ($first_operand, $second_operand, $operator);

do {
  print "Enter command to execute: ";
  my $command = <STDIN>;
 ($first_operand, $operator, $second_operand) = $command =~ /(\d*_?\d+\/\d+|\d+)\s+(\*|\/|\+|-)\s+(\d*_?\d+\/\d+|\d+)/s;

} while !($first_operand && $second_operand && $operator);

print perform_operation_on_fractions($first_operand, $second_operand, $operator);


########### subroutines ############
sub normalize_fractional_number($){
	my $fractional_num = shift;
	if (index ($fractional_num, '_') != -1){
		my ($sign, $int_part, $nominator, $denominator) = $fractional_num =~/(-)?(\d+)_(\d+)\/(\d+)/s;
		return int($sign . ($int_part*$denominator + $nominator)) . "/$denominator";
	} else {
		return $fractional_num;
	}
}

sub denormalize_fractional_number($){
	my $fractional_num = shift;
	my ($sign, $nominator, $denominator) = $fractional_num =~/(-)?(\d+)\/(\d+)/s;

	if ($nominator < $denominator){
		if ($nominator == 0){
			return 0;
		}	
		return &simplify_fractional_part($fractional_num);
	}
	my $int_part = int($nominator/$denominator);
	if ($nominator - $int_part*$denominator == 0){
		return $sign . $int_part; 
	}
	return $sign . $int_part . '_' . &simplify_fractional_part(int($nominator - $int_part*$denominator) ."/$denominator");
}

sub simplify_fractional_part($){
	my $fractional = shift;
	my ($nomin, $denomin) = split /\//, $fractional;
	my (@arr_nominator, @arr_denominator);
	my ($i, $y, $max_common);

	for ($i=1; $i <= abs($nomin); $i++){
		if ($nomin%$i == 0 && $i > 1){
			push @arr_nominator, $i;
		}
	}
	
	for ($i=1; $i <= abs($denomin); $i++){
		if ($denomin%$i == 0 && $i > 1){
			push @arr_denominator, $i;
		}
	}

	$max_common = -1;
	# finding highest common devider:
	if ($#arr_nominator >= 0 && $#arr_denominator >= 0){
		for ($i = 0; $i <= $#arr_nominator; $i++){
			for ($y = 0; $y <= $#arr_denominator; $y++){
				if ($arr_nominator[$i] == $arr_denominator[$y] && $arr_nominator[$i] > $max_common){
					$max_common = $arr_nominator[$i];
				}
			}
		}

		if ($max_common > -1){
			return $nomin/$max_common . '/' . $denomin/$max_common;
		}
	}
	return $nomin . '/' . $denomin;
}

sub perform_operation_on_fractions($$$){
	my ($operand1, $operand2, $operator) = @_;
	my ($common_denominator,$new_nominator);
	
	if ($operand2 eq '0' && $operator eq '/'){
		die "Illegal division by 0";
	}
	
	# this is case when whole number is passed (e.g. 5):
	if ($operand1 =~ /^-?\d+$/){
		$operand1 .=  '_0/1';
	}
	if ($operand2 =~ /^-?\d+$/){
		$operand2 .= '_0/1';
	}

	my ($sign, $nominator1, $denominator1) = normalize_fractional_number($operand1) =~/(-)?([0-9]+)\/([1-9][0-9]*)/;
	$denominator1 = ($denominator1)? $denominator1 : 1;
	my ($sign2, $nominator2, $denominator2) = normalize_fractional_number($operand2) =~/(-)?([0-9]+)\/([1-9][0-9]*)/;
	$denominator2 = ($denominator2)? $denominator2 : 1;
	
	# filtering out 0s in denominators:
	return "Invalid input." unless ($denominator1 && $denominator2);
	
	$common_denominator = $denominator1*$denominator2;
	
	# I do not use switch statement here as it requires packages Filter::Util::Call and Text::Balanced 
	# to be installed. I like this code to be executable w/o any dependencies 
	if ($operator eq '+'){
		print(int($sign.$nominator1*$denominator2));
		$new_nominator = int($sign.$nominator1*$denominator2) + int($sign2.$nominator2*$denominator1);
		if ($new_nominator != 0){
			return denormalize_fractional_number($new_nominator . "/$common_denominator");
		}
		return 0;
	}
	elsif ($operator eq '-'){
		$new_nominator = int($sign.$nominator1*$denominator2) - int($sign2.$nominator2*$denominator1);
		if ($new_nominator != 0){
			return denormalize_fractional_number($new_nominator . "/$common_denominator");
		}
		return 0;
		}
	elsif ($operator eq '*'){
		$new_nominator = int($sign.$nominator1) * int($sign2.$nominator2);
			return denormalize_fractional_number($new_nominator . "/$common_denominator");
		}
	elsif ($operator eq '/'){
		#print ($sign.$nominator1.'/'.$denominator1, $sign2.$denominator2.'/'.$nominator2); #0/11/0
		return perform_operation_on_fractions($sign.$nominator1.'/'.$denominator1, $sign2.$denominator2.'/'.$nominator2, '*');
		}
	else{
			print("Error: unknown operator $operator provided.");
			exit (-1);
		}
	}

exit(0);

__DATA__
print &perform_operation_on_fractions('1/2', '3_4/5', '+');
print &perform_operation_on_fractions('1/2', '3_4/5', '-');
print &perform_operation_on_fractions('1/2', '3_4/5', '*');
print &perform_operation_on_fractions('1/2', '3_4/5', '/');
print &perform_operation_on_fractions('1001/14', '3_4/5', '+');
print &perform_operation_on_fractions('2147483999_2147455555/12', '1/2', '/'); 
print &perform_operation_on_fractions('1/2', '3_4/5', '&');
# changed order of operands:
print &perform_operation_on_fractions('3_4/5', '1/2', '+');
print &perform_operation_on_fractions('3_4/5', '1/2', '-');
print &perform_operation_on_fractions('3_4/5', '1/2', '*');
print &perform_operation_on_fractions('3_4/5', '1/2', '/');
#large and small numbers
print &perform_operation_on_fractions('3_4/76876876878768767879879', '1/2', '+');
print &perform_operation_on_fractions('79879879898798/5', '1/2', '-');
print &perform_operation_on_fractions('3_4/5', '6876878768779898/2', '*');
print &perform_operation_on_fractions('3_4/5', '1/246546548987', '/');
#boundary cases:
print &perform_operation_on_fractions('2_1/2', '1/2', '+');
print &perform_operation_on_fractions('2/2', '2/2', '-');
print &perform_operation_on_fractions('3_4/5', '6876878768779898/2', '*');
print &perform_operation_on_fractions('3_4/5', '1/246546548987', '/');
#negative fractions:
print &perform_operation_on_fractions('-2_1/2', '-1/2', '+');
print &perform_operation_on_fractions('2/2', '-2/2', '-');
print &perform_operation_on_fractions('3_4/5', '-6876878768779898/2', '*');
print &perform_operation_on_fractions('-3_4/5', '-1/246546548987', '/');
# whole numbers:
print &perform_operation_on_fractions('5', '10', '+');
print &perform_operation_on_fractions('5', '-10', '/');
print &perform_operation_on_fractions('-5', '-10', '*');
print &perform_operation_on_fractions('-5', '10', '*');
#inavalid input
print &perform_operation_on_fractions('0_4/5', '0/246546548987', '/');
print &perform_operation_on_fractions('0', '0', '/');
print &perform_operation_on_fractions('1', '0', '/');
print &perform_operation_on_fractions('0', '6', '/');