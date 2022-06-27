#!/usr/bin/env perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib qq{$Bin/../lib};

use Tie::OpenMP::Experimental::Scalar::ArrayReduceSubtract;
use OpenMP::Environment qw//;

my $oe = OpenMP::Environment->new;
foreach my $num_threads (qw/1 2 4 8 15/) {
  my @giant_list = (1 .. $num_threads * 1000);
  tie my $array_sum, 'Tie::OpenMP::Experimental::Scalar::ArrayReduceSubtract', \@giant_list;

  $oe->omp_num_threads($num_threads);
  printf qq{%02d threads -> subtraction result = $array_sum ...\n}, $num_threads;
}
