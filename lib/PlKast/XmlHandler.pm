package PlKast::Config::Parser;
use Qt;
use Qt::isa qw/Qt::XmlDefaultHandler/;
use Qt::attributes qw/tagStack handle spot/;
use Error qw/:try/;

use constant ELEM_NS=>0;
use constant ELEM_LNAME=>1;
use constant ELEM_QNAME=>2;
use constant ELEM_ATTR=>3;

sub NEW {
	shift->SUPER::NEW();

	tagStack = [];
	handle = shift;

	if (!defined(handle) || ref(handle) ne 'HASH') {
		throw Error::Simple('No handle specified to '.__PACKAGE__.'().');
	}

	spot = handle;
}

sub startElement {
	my @elm = @_;

	push(@{&tagStack}, \@elm);
	
}

1;
