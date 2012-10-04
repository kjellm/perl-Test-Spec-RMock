package Test::Spec::RMock::MockObject;

use Moose;
use namespace::autoclean;

has _name => (is => 'ro');

has _messages => (
    is       => 'ro',
    default  => sub { {} },
);

around BUILDARGS => sub {
  my ($orig, $class, $name) = @_;
  $orig->($class, _name => $name);
};


sub should_receive {
    my ($self, $message) = @_;
    my $expectation = Test::Spec::RMock::MessageExpectation->new($message);
    $self->_messages->{$message} ||= [];
    push @{$self->_messages->{$message}}, $expectation;

    my $context = Test::Spec->current_context
        || Carp::croak "Test::Spec::RMocks only works in conjunction with Test::Spec";
    $context->on_leave(sub { $self->__teardown });

    $expectation;
}


sub should_not_receive {
    my ($self, $message) = @_;
    $self->should_receive($message)->exactly(0)->times;
}


sub stub {
    my ($self, $method_name, $return_value) = @_;
    $self->should_receive($method_name)->and_return($return_value)->any_number_of_times;
}


sub __teardown {
    my ($self) = @_;
    for my $ms (values %{$self->_messages}) {
        for my $m (@$ms) { 
            $m->check;
        }
    }
}


our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;

    my $method = $AUTOLOAD;
    $method =~ s/.*:://;

    my $expectations = $self->_messages->{$method};

    unless ($expectations) {
        warn "Unmocked method '$method' called on '" . $self->_name . "'";
        return;
    }

    for my $e (@$expectations) {
        return $e->call(@_) if $e->is_conditions_satisfied(@_);
    }

    # Found no expectations that the call satisfied. Need to call the first
    # one to trigger call constraint error
    return $expectations->[0]->call(@_);
}

1;
