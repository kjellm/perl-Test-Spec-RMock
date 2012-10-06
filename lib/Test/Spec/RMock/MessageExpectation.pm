package Test::Spec::RMock::MessageExpectation;

sub new {
    my ($class, $name) = @_;
    my $self = {
        _name                   => $name,
        _return_value           => undef,
        _exception              => undef,
        _number_of_times_called => 0,
        _call_count_constraint  => Test::Spec::RMock::ExactlyConstraint->new(1),
        _arguments              => undef,
    };
    bless $self, $class;
}

sub call {
    my ($self, @args) = @_;
    $self->{_number_of_times_called}++;
    die $self->{_exception} if $self->{_exception};
    $self->{_return_value};
}

sub is_all_conditions_satisfied {
    my ($self, @args) = @_;
    $self->{_call_count_constraint}->call($self->{_number_of_times_called}+1)
        && $self->does_arguments_match(@args);
}

sub does_arguments_match {
    my ($self, @args) = @_;
    return 1 unless defined $self->{_arguments};
    return unless scalar(@args) == scalar(@{$self->{_arguments}});
    for my $i (0..$#{$self->{_arguments}}) {
        return unless $args[$i] eq $self->{_arguments}[$i];
    }
    return 1;
}

sub is_call_constrint_satisfied {
    my ($self) = @_;
    $self->{_call_count_constraint}->call($self->{_number_of_times_called});
}

sub call_contraint_error_message {
    my ($self) = @_;
    "Call constraint failed";
}

sub argument_matching_error_message {
    my ($self) = @_;
    "Argument matching failed";
}

###  RECEIVE COUNTS

sub any_number_of_times {
    my ($self) = @_;
    $self->{_call_count_constraint} = Test::Spec::RMock::AnyConstraint->new;
    $self;
}

sub at_least_once {
    my ($self) = @_;
    $self->{_call_count_constraint} = Test::Spec::RMock::AtLeastConstraint->new(1);
    $self;
}

sub at_least {
    my ($self, $n) = @_;
    $self->{_call_count_constraint} = Test::Spec::RMock::AtLeastConstraint->new($n);
    $self;
}

sub once {
    my ($self) = @_;
    $self->exactly(1);
    $self;
}

sub twice {
    my ($self) = @_;
    $self->exactly(2);
    $self;
}

sub exactly {
    my ($self, $n) = @_;
    $self->{_call_count_constraint} = Test::Spec::RMock::ExactlyConstraint->new($n);
    $self;
}

sub times {
    return @_;
}

### RESPONSES

sub and_return {
    my ($self, $value) = @_;
    $self->{_return_value} = $value;
    $self;
}


sub and_raise {
    my ($self, $exception) = @_;
    $self->{_exception} = $exception;
    $self;
}


### ARGUMENT MATCHING

sub with {
    my ($self, @args) = @_;
    $self->{_arguments} = \@args;
    $self;
}

1;
