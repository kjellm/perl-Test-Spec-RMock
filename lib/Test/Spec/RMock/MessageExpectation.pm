package Test::Spec::RMock::MessageExpectation;

use Moose;
use namespace::autoclean;

use Test::More;

has _name => (is => 'ro');

has _return_value => (
    is       => 'rw',
    default  => 1,
    init_arg => undef,
);

has _exception => (
    is       => 'rw',
    default  => undef,
    init_arg => undef,
);

has _number_of_times_called => (
    is       => 'rw',
    default  => 0,
    init_arg => undef,
);

has _call_count_constraint => (
    is       => 'rw',
    default  => sub { $_[0]->_build_call_constraint(1) },
    init_arg => undef,
);

has _arguments => (
    is       => 'rw',
    default  => undef,
    init_arg => undef,
);

around BUILDARGS => sub {
  my ($orig, $class, $name) = @_;

  my $self = $orig->($class, _name => $name);
};


sub call {
    my ($self, @args) = @_;
    $self->_increment_call_counter;
    $self->_check_arguments(@args);
    die $self->_exception if $self->_exception;
    $self->_return_value;
}


sub check {
    my ($self) = @_;
    $self->_check_call_constraint;
}


sub _increment_call_counter {
    my ($self) = @_;
    $self->_number_of_times_called($self->_number_of_times_called + 1);
}


sub _check_arguments {
    my ($self, @args) = @_;
    return 1 unless defined $self->_arguments;
    is(scalar(@args), scalar(@{$self->_arguments}), 'Number of arguments to '.$self->_name.' matches expectation');
    is_deeply(\@args, $self->_arguments);
}


sub _check_call_constraint {
    my ($self) = @_;
    fail sprintf("'%s' failed call count constraint", $self->_name)
        unless $self->_call_count_constraint->($self->_number_of_times_called);
}

sub _build_call_constraint {
    my ($self, $limit) = @_;
    sub { $self->_number_of_times_called == $limit; }
}

###  RECEIVE COUNTS

sub any_number_of_times {
    my ($self) = @_;
    $self->_call_count_constraint(sub {1});
    $self;
}


sub twice {
    my ($self) = @_;
    $self->_call_count_constraint($self->_build_call_constraint(2));
    $self;
}


### RESPONSES

sub and_return {
    my ($self, $value) = @_;
    $self->_return_value($value);
    $self;
}


sub and_raise {
    my ($self, $exception) = @_;
    $self->_exception($exception);
    $self;
}


### ARGUMENT MATCHING

sub with {
    my ($self, @args) = @_;
    $self->_arguments(\@args);
    $self;
}

1;
