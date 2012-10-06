package Test::Spec::RMock::AtLeastConstraint;

sub new {
    my ($class, $bound) = @_;
    bless { _bound => $bound }, $class;
}

sub call {
    my ($self, $times_called) = @_;
    $times_called >= $self->{_bound};
}

1;

