package Test::Spec::RMock;

use Moose;
use namespace::autoclean;

use Test::Spec::RMock::MessageExpectation;

has _name => (is => 'ro');

has _messages => (
    is       => 'ro',
    default  => sub { {} },
    init_arg => undef,
);


around BUILDARGS => sub {
  my ($orig, $class, $name) = @_;

  $orig->($class, _name => $name);
};


sub should_receive {
    my ($self, $message) = @_;
    my $expectation = Test::Spec::RMock::MessageExpectation->new($message);
    $self->_messages->{$message} = $expectation;

    my $context = Test::Spec->current_context
        || Carp::croak "Test::Spec::RMocks only works in conjunction with Test::Spec";
    $context->on_leave(sub { $self->_teardown });

    $expectation;
}

sub _teardown {
    my ($self) = @_;
    for my $i (values %{$self->_messages}) {
        $i->check;
    }
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;

    my $method = $AUTOLOAD;
    $method =~ s/.*:://;

    my $expectation = $self->_messages->{$method};

    unless ($expectation) {
      die "Unmocked method '$method' called on '" . $self->_name . "'";
      return;
    }

    return $expectation->call(@_);
}

1;
