use strict;

package PlKast::Config;
use Qt;
use Qt::isa qw/PlKast/;
use Qt::constants qw/IO_ReadOnly IO_WriteOnly/;
use Qt::attributes qw/handle loaded changed/;
use Qt::slots
	plkastClosing => [];

use Error qw/:try/;
use XML::TreePP;

our $VERSION=0.01;

sub NEW {
	shift->SUPER::NEW(@_);

	handle = {};
	loaded = 0;
	changed = 0;

	try {
		_xml_load();
		changed = 1;
	} catch Error::Simple with {
		my $err = shift;

		warn(__PACKAGE__.": Load failed: ".$err->stringify());
		_set_stubbed_handle();
	} otherwise {
		my $err = shift;

		# BAD error.
		throw $err;
	};
}

sub plkastClosing {
  _xml_save();
}

sub fname {
  return this->_get_rcfile;
}

sub _set_stubbed_handle {
	handle = {plkast=>{}};
}

sub _xml_load {
	my $parser = XML::TreePP->new();
	my $fil = Qt::File(fname);
	$fil->open(IO_ReadOnly) ||
		throw Error::Simple("open failed: ".$!);
	my $stream = Qt::TextStream($fil);

	handle = $parser->parse($stream->read());
	loaded = 1;

	$fil->close();

	return 1;
}

sub _xml_save {
	if (!changed) {
		return 1;
	}

	my $parser = XML::TreePP->new();
	my $fil = Qt::File(fname);
	$fil->open(IO_WriteOnly);
	my $stream = Qt::TextStream($fil);

	$stream<<$parser->write(handle)<<"\n";
	changed = 0;

	$fil->close();

  return 1;
}

sub get_config {
	my ($key) = @_;

	return handle->{plkast}->{$key};
}

sub set_config {
	my ($key, $value) = @_;

	handle->{plkast}->{$key} = $value;
	changed = 1;

	return handle->{plkast}->{$key};
}

# sub new {
#   my ($class, %opts) = @_;

#   my $self = {map { $_ => $opts{$_} } keys(%opts) };
#   bless($self, $class);

#   $self->{parser} = XML::TreePP->new();
#   $self->{handle} = {plkast=>{-version=>$VERSION}};
#   $self->{loaded} = 0;
#   $self->{changed} = 0;

#   $self->_load();
#   $self->{changed} = 1;

#   return $self;
# }

# sub _load {
#   my ($self) = @_;

#   if ($self->{loaded}) {
#     return 1;
#   }

#   if (-r ($self->fname)) {
#     try {
#       $self->{handle} = $self->{parser}->parsefile($self->fname);
#     } otherwise {
#       my $err = shift;
#       warn("Failed to parse the XML file '".$self->fname."': ".$err->stringify);
#       $self->{handle} = {};
#     };
#   }
#   $self->{handle}->{plkast} ||= {};

#   $self->{loaded} = 1;

#   return 1;
# }

# sub _save {
#   my ($self) = @_;

#   if (defined($self->{parser}) && defined($self->{handle})) {
#     $self->{parser}->writefile($self->fname, $self->{handle});
#     $self->{changed} = 0;
#   }

#   return 1;
# }

# sub set_config {
#   my ($self, $key, $value) = @_;

#   $self->{handle}->{plkast}->{$key} = $value;

#   return $self->{handle}->{plkast}->{$key};
# }

# sub get_config {
#   my ($self, $key) = @_;

#   return $self->{handle}->{plkast}->{$key};
# }

1;
