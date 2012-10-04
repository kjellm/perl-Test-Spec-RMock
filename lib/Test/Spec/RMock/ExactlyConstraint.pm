package Test::Spec::RMock::ExactlyConstraint;

use Moose;
use namespace::autoclean;

has _target => (is => 'ro');

around BUILDARGS => sub {
    my ($orig, $class, $target) = @_;
    my $self = $orig->($class, _target => $target);
};

sub call {
    my ($self, $times_called) = @_;
    $times_called == $self->_target;
}

1;

