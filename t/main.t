use Test::Spec;

use_ok 'Test::Spec::RMock';

describe 'Test::Spec::RMock' => sub {

    it "should report calls to unmocked methods" => sub {
        my $mock = rmock('foo');
        $mock->bar;
    };

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

    context 'call constraints' => sub {
        describe 'at_least_once()' => sub {
            it 'should fail when called zero times' => sub {
                my $mock = rmock('foo');
                $mock->should_receive('bar')->at_least_once;
            };

            it 'should pass when called one time' => sub {
                my $mock = rmock('foo');
                $mock->should_receive('bar')->at_least_once;
                $mock->bar;
                pass('');
            };
        };
    };

    describe 'should_not_receive' => sub {
        it 'should pass when the mocked method is never called' => sub {
            my $mock = rmock('foo');
            $mock->should_not_receive('bar');
            pass('');
        };

        it 'should fail if the mocked method is called' => sub {
            my $mock = rmock('foo');
            $mock->should_not_receive('bar');
            $mock->bar;
        };
    };

};

runtests unless caller;

