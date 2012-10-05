package Test::Spec::RMock::MockObject;

use Moose;
use namespace::autoclean;

has __name => (is => 'ro');

has __messages => (
    is       => 'ro',
    default  => sub { {} },
);

has __messages_received => (
    is       => 'ro',
    default  => sub { [] },
);

around BUILDARGS => sub {
  my ($orig, $class, $name) = @_;
  $orig->($class, __name => $name);
};


sub should_receive {
    my ($self, $message) = @_;
    my $expectation = Test::Spec::RMock::MessageExpectation->new($message);
    $self->__register_expectation($message, $expectation);
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


sub __register_expectation {
    my ($self, $message, $expectation) = @_;
    $self->__messages->{$message} ||= [];
    push @{$self->__messages->{$message}}, $expectation;
}


sub __teardown {
    my ($self) = @_;
    for my $ms (values %{$self->__messages}) {
        for my $m (@$ms) { 
            $m->check;
        }
    }
}


our $AUTOLOAD;

sub __find_method_proxy {
    my ($self, $message_name, @args) = @_;
    my $expectations = $self->__messages->{$message_name};
    return unless $expectations;
    for my $e (@$expectations) {
        return $e if $e->is_conditions_satisfied(@args);
    }
    return $expectations->[0];
}

sub __get_message_name {
    my $name = $AUTOLOAD;
    $name =~ s/.*:://;
    $name;
}

sub AUTOLOAD {
    my ($self, @args) = @_;
    my $message_name = $self->__get_message_name;
    push @{$self->__messages_received}, [$message_name, @args];
    my $proxy = $self->__find_method_proxy($message_name, @args);
    unless ($proxy) {
        warn "Unmocked method '$message_name' called on '" . $self->__name . "'";
        return;
    }
    return $proxy->call(@args);
}

1;
