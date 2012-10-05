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
            xit 'should fail when called zero times' => sub {
                my $mock = rmock('foo');
                $mock->should_receive('bar1')->at_least_once;
            };

            it 'should pass when called one time' => sub {
                my $mock = rmock('foo');
                $mock->should_receive('bar2')->at_least_once;
                $mock->bar2;
                pass('');
            };
        };
    };

    describe 'should_not_receive' => sub {
        it 'should pass when the mocked method is never called' => sub {
            my $mock = rmock('foo');
            $mock->should_not_receive('bar3');
            pass('');
        };

        xit 'should fail if the mocked method is called' => sub {
            my $mock = rmock('foo');
            $mock->should_not_receive('bar4');
            $mock->bar4;
        };
    };

    context 'multiple mocks for the same message' => sub {
        it 'should' => sub {
            my $mock = rmock('foo');
            $mock->should_receive('bar5')->with(1);
            $mock->should_receive('bar5')->with(2);
            $mock->bar5(2);
            $mock->bar5(1);
            pass('');
        };

        it 'should' => sub {
            my $mock = rmock('foo');
            $mock->should_receive('bar6');
            $mock->should_receive('bar6');
            $mock->bar6;
            $mock->bar6;
            pass('');
        };

        xit 'should fail' => sub {
            my $mock = rmock('foo');
            $mock->should_receive('bar7');
            $mock->should_receive('bar7');
            $mock->bar7;
            $mock->bar7;
            $mock->bar7;
        };
    };

};

runtests unless caller;

