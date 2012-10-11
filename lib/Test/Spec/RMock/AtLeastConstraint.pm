package Test::Spec::RMock::AtLeastConstraint;

sub new {
    my ($class, $bound) = @_;
    bless { _bound => $bound }, $class;
}

sub call {
    my ($self, $times_called) = @_;
    $times_called >= $self->{_bound};
}

sub error_message {
    my ($self, $mock_name, $name, $times_called) = @_;
    sprintf "Expected '%s' to be called at least once on '%s', but called %d %s.",
        $name, $mock_name, $times_called, ($times_called == 1 ? 'time' : 'times');
}

1;

