use Test::Spec;

use_ok 'Test::Spec::RMock';

describe 'Test::Spec::RMock' => sub {

    describe 'method stubs' => sub {
        my $mock;
        before each => sub {
            $mock = rmock('foo');
            $mock->stub('bar' => 1);
        };

        it "should take as arguments name and return value" => sub {
            is($mock->bar, 1);
        };

        it "should return the same value each time it is called" => sub {
            is($mock->bar, 1);
            is($mock->bar, 1);
            is($mock->bar, 1);
        }
    };

};

runtests unless caller;

