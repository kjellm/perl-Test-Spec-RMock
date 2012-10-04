use Test::Spec;

use_ok 'Test::Spec::RMock';

describe 'Test::Spec::RMock' => sub {

    it "should stuff" => sub {
        my $foo = Test::Spec::RMock->new('foo');
        $foo->should_receive('bar');
        $foo->baz
    };

};

runtests unless caller;

