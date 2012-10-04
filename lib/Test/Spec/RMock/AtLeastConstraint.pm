package Test::Spec::RMock::AtLeastConstraint;

use Moose;
use namespace::autoclean;

has _bound => (is => 'ro');


around BUILDARGS => sub {
    my ($orig, $class, $bound) = @_;
    my $self = $orig->($class, _bound => $bound);
};


sub call {
    my ($self, $times_called) = @_;
    $times_called >= $self->_bound;
}

1;

