#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib qq{$Bin/../lib};

use Tie::Array::OmpSum;
use OpenMP::Environment qw//;

my $oe = OpenMP::Environment->new;
foreach my $num_threads (qw/1 2 4 8 15/) {
  my @giant_list = (1 .. $num_threads * 1000);
  tie my $array_sum, 'Tie::Array::OmpSum', \@giant_list;

  $oe->omp_num_threads($num_threads);
  printf qq{%02d threads -> sum = $array_sum ...\n}, $num_threads;
}
