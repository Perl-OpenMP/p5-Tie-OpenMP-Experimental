package Tie::OpenMP::Experimental::Scalar::ArrayReduceSum;

use strict;
use warnings;

use Alien::OpenMP qw//;
use Inline (
    C           => q{DATA},
    with        => 'Alien::OpenMP',
);

sub TIESCALAR {
  my $pkg  = shift;
  my $array_ref = shift;
  return bless $array_ref, $pkg;
}

sub STORE {
  my ($self, $value) = @_;
  return;
}

sub FETCH {
  my ($self) = shift;
  my $sum = sum($self);
  return $sum;
}

__PACKAGE__
__DATA__
__C__
#include <stdio.h>
#include <stdlib.h>

// began life as a recipe from Inline::C::Cookbook
SV *sum(SV *array) {
    int numelts, i;
    if ((!SvROK(array))
        || (SvTYPE(SvRV(array)) != SVt_PVAV)
        || ((numelts = av_len((AV *)SvRV(array))) < 0)
    ) {
        return &PL_sv_undef;
    }
    
    /* read %ENV and update according to OMP_NUM_THREADS */
    _ENV_set_num_threads();
    int total = 0;
    #pragma omp parallel shared(total)
    {
      #pragma omp for reduction(+:total)
      for (i = 0; i <= numelts; i++) {
        total += SvIV(*av_fetch((AV *)SvRV(array), i, 0));
      }
    }
    return newSViv(total);
}

//  may provide this and other similar update methods via Inline::C injection
void _ENV_set_num_threads() {
  char *num;
  num = getenv("OMP_NUM_THREADS");
  omp_set_num_threads(atoi(num));
}
