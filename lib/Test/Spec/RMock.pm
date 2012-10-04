package Test::Spec::RMock;

use Moose;
use namespace::autoclean;

use Moose::Exporter;
use Test::Spec::RMock::AnyConstraint;
use Test::Spec::RMock::AtLeastConstraint;
use Test::Spec::RMock::ExactlyConstraint;
use Test::Spec::RMock::MessageExpectation;
use Test::Spec::RMock::MockObject;

Moose::Exporter->setup_import_methods(
    with_meta => [ qw(rmock) ],
);

sub rmock {
    my (undef, $name) = @_;
    Test::Spec::RMock::MockObject->new($name);
}

1;
