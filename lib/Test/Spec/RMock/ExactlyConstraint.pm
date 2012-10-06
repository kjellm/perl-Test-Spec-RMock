package Test::Spec::RMock::ExactlyConstraint;

sub new {
    my ($class, $target) = @_;
    bless { _target => $target }, $class;
}

sub call {
    my ($self, $times_called) = @_;
    $times_called == $self->{_target};
}

1;

