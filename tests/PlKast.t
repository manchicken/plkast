use Test::More qw!no_plan!;

use lib 'lib/';
require_ok('PlKast');

ok($obj = PlKast->new(), "Try newing up.");
cmp_ok($obj->_get_or_set('foo',123), '==', 123, "Try get_or_set.");
