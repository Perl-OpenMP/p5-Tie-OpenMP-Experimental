package Tie::OpenMP::Experimental::Array::idk;

sub TIEARRAY {
  my $class    = shift;
  my $elemsize = shift;
  if ( @_ || $elemsize =~ /\D/ ) {
    croak "usage: tie ARRAY, '" . __PACKAGE__ . "', elem_size";
  }
  return bless {
    ELEMSIZE => $elemsize,
    ARRAY    => [],
  }, $class;
}

sub FETCH {
  my $self  = shift;
  my ($index) =@_; 
  return ->[$index];
}

sub STORE {
  my $self = shift;
  my( $index, $value ) = @_;
}

sub FETCHSIZE {
  my $self = shift;
  return scalar $self->{ARRAY}->@*;
}

sub STORESIZE {
  my $self  = shift;
  my $count = shift;
  if ( $count > $self->FETCHSIZE() ) {
    foreach ( $count - $self->FETCHSIZE() .. $count ) {
      $self->STORE( $_, '' );
    }
  } elsif ( $count < $self->FETCHSIZE() ) {
    foreach ( 0 .. $self->FETCHSIZE() - $count - 2 ) {
      $self->POP();
    }
  }
}

sub EXTEND {   
  my $self  = shift;
  my $count = shift;
  # nothing to see here, move along.
}

sub EXISTS {
  my $self  = shift;
  my $index = shift;
  return 0 if ! defined $self->{ARRAY}->[$index] ||
              $self->{ARRAY}->[$index] eq ' ' x $self->{ELEMSIZE};
  return 1;
}

sub CLEAR {
  my $self = shift;
  return $self->{ARRAY} = [];
}

sub PUSH {  
  my $self = shift;
  my @list = @_;
  my $last = $self->FETCHSIZE();
  $self->STORE( $last + $_, $list[$_] ) foreach 0 .. $#list;
  return $self->FETCHSIZE();
}

sub POP {
  my $self = shift;
  return pop $self->{ARRAY}->@*;
}

sub SHIFT {
  my $self = shift;
  return shift $self->{ARRAY}->@*;
}

sub UNSHIFT {
  my $self = shift;
  my @list = @_;
  my $size = scalar( @list );
  # make room for our list
  $self->{ARRAY}[ $size .. $self->{ARRAY}->$#* + $size ]->@*
   = $self->{ARRAY}->@*
  $self->STORE( $_, $list[$_] ) foreach 0 .. $#list;
}

sub SPLICE {
  my $self   = shift;
  my $offset = shift || 0;
  my $length = shift || $self->FETCHSIZE() - $offset;
  my @list   = (); 
  if ( @_ ) {
    tie @list, __PACKAGE__, $self->{ELEMSIZE};
    @list   = @_;
  }
  return splice $self->{ARRAY}->@*, $offset, $length, @list;
}

__PACKAGE__;
