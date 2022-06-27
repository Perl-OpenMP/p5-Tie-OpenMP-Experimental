#!/usr/bin/env perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib qq{$Bin/../lib};

use Tie::OpenMP::Experimental::Scalar::ArrayReduceSum;
use OpenMP::Environment qw//;

my $oe = OpenMP::Environment->new;
my $array_sum;
foreach my $num_threads (qw/1 2 4 8 15/) {
  my @giant_list = (1 .. $num_threads * 1000);
  tie $array_sum, 'Tie::OpenMP::Experimental::Scalar::ArrayReduceSum', \@giant_list;

  $oe->omp_num_threads($num_threads);
  printf qq{%02d threads -> summation result = $array_sum ...\n}, $num_threads;
}

require Data::Dumper;
print Data::Dumper::Dumper($array_sum);
