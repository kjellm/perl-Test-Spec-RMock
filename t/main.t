use Test::Spec;

BEGIN { use_ok 'Test::Spec::RMock' };

describe 'Test::Spec::RMock' => sub {

    it "should report calls to unmocked methods" => sub {
        my $mock = rmock('foo')->__cancel;
        $mock->bar;
        $mock->__check;
        is($mock->__check, "Unmocked method 'bar' called on 'foo'");
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
            my @results = ();
            push @results, $mock->bar for 1..3;
            is_deeply(\@results, [1, 1, 1]);
        }
    };

    context 'call constraints' => sub {
        describe 'at_least_once()' => sub {
            it 'should fail when called zero times' => sub {
                my $mock = rmock('foo')->__cancel;
                $mock->should_receive('bar1')->at_least_once;
                is($mock->__check, "Call constraint failed");
            };

            it 'should pass when called one time' => sub {
                my $mock = rmock('foo');
                $mock->should_receive('bar2')->at_least_once->and_return(1);
                is($mock->bar2, 1);
            };

            it 'should pass when called more than one time' => sub {
                my $mock = rmock('foo');
                $mock->should_receive('bar2')->at_least_once->and_return(1);
                my @results = ();
                push @results, $mock->bar2 for 1..4;
                is_deeply(\@results, [1, 1, 1, 1]);
            };
        };
    };

    describe 'should_not_receive' => sub {
        it 'should pass when the mocked method is never called' => sub {
            my $mock = rmock('foo');
            $mock->should_not_receive('bar3');
            is($mock->__check, '');
        };

        it 'should fail if the mocked method is called' => sub {
            my $mock = rmock('foo')->__cancel;
            $mock->should_not_receive('bar4');
            $mock->bar4;
            is($mock->__check, 'Call constraint failed');
        };
    };

    context 'multiple mocks for the same message' => sub {
        it 'should check the next matching expectation when the first fails' => sub {
            my $mock = rmock('foo');
            $mock->should_receive('bar6');
            $mock->should_receive('bar6');
            $mock->bar6;
            $mock->bar6;
            is($mock->__check, '');
        };

        it 'should pass when different argument matching is required' => sub {
            my $mock = rmock('foo');
            $mock->should_receive('bar5')->with(1);
            $mock->should_receive('bar5')->with(2);
            $mock->bar5(2);
            $mock->bar5(1);
            is($mock->__check, '');
        };

        it 'should fail when the combined call constraints are exhausted' => sub {
            my $mock = rmock('foo')->__cancel;
            $mock->should_receive('bar7');
            $mock->should_receive('bar7');
            $mock->bar7;
            $mock->bar7;
            $mock->bar7;
            is($mock->__check, 'Call constraint failed');
        };
    };

};

runtests unless caller;

