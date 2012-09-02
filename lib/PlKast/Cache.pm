package PlKast::Cache;
use strict;
use warnings;
use base 'PlKast';

use Error qw{:try};
use Fcntl qw{:DEFAULT};
use XML::TreePP;

our $VERSION=0.01;

use constant DATA_GROUP_NAME => "cache";

sub new {
  my ($class, %opts) = @_;

  my $self = $class->SUPER::new(%opts);

  $self->{parser} = XML::TreePP->new();
  $self->{parser}->set(force_array=>['item']);
  $self->{handle} = {plkast=>{-version=>$VERSION,cache=>{item=>[]}}};
  $self->{loaded} = 0;
  $self->{changed} = 0;

  $self->_load();

  return $self;
}

sub DESTROY {
  shift->_save();
}

sub fname {
  return shift->_get_data_file_name(DATA_GROUP_NAME);
}

sub _load {
  my ($self) = @_;

  if ($self->{loaded}) {
    return 1;
  }

  if (-r ($self->fname)) {
    try {
      $self->{handle} = $self->{parser}->parsefile($self->fname);
    } otherwise {
      my $err = shift;
      warn("Failed to parse the XML file '".$self->fname."': ".$err->stringify);
      $self->{handle} = {};
    };
  }
  $self->{handle}->{plkast}->{cache}->{item} ||= [];

  $self->{loaded} = 1;
	$self->_missing_fixer && $self->_save;

  return 1;
}

sub _save {
  my ($self) = @_;

  if (defined($self->{parser}) && defined($self->{handle})) {
    $self->{parser}->writefile($self->fname, $self->{handle});
    $self->{changed} = 0;
  }

  return 1;
}

sub _missing_fixer {
	my ($self) = @_;

	my $count = 0;
	# Maybe do checksums here?  Nah, I don't care right now.

	for my $one (@{$self->{handle}->{plkast}->{cache}->{item}}) {
		if (!(-r $one->{-file})) {
			$self->remove_item($one->{-feedid});
			$count += 1;
		}
	}

	return $count;
}

sub lookup_single_item {
	return (shift->lookup_item(@_))[0];
}

sub lookup_item {
  my ($self, %opts) = @_;

	$self->_missing_fixer;
  if (!defined($opts{file}) && !defined($opts{url}) && !defined($opts{feedid})) {
    throw Error::Simple("Not enough data to lookup a feed with.  I need a feed ID, file, or URL.");
  }

  my $findkey = undef;
  my $findvalue = undef;

  # This lets us set a preferred list of lookup fields.  ID beats URL which beats title.
  for my $key (qw/file feedid url/) {
    if (defined($opts{$key})) {
      $findkey = "-$key";
      $findvalue = $opts{$key};
      last;
    }
  }

  my @results = ();
  for my $one (@{$self->{handle}->{plkast}->{cache}->{item}}) {
    if (($opts{invert}||0) > 0) {
      if ($one->{$findkey} ne $findvalue) {
				push(@results, $one);
      }
    } else {
      if ($one->{$findkey} eq $findvalue) {
				push(@results, $one);
      }
    }
  }

  return @results;
}

sub add_item {
  my ($self, %opts) = @_;

  if (!defined($opts{url}) || !defined($opts{file}) || !defined($opts{feedid})) {
    throw Error::Simple("Not enough data passed to add_feed.  Expected at least a URL, file, and feed ID.");
  }

  if (scalar($self->lookup_item(feedid=>$opts{feedid}))) {
		$self->remove_item($opts{feedid});
  }

  my $element = {
								 -feedid=>$opts{feedid},
								 -file=>$opts{file},
								 -url=>$opts{url},
						 };

  push(@{$self->{handle}->{plkast}->{cache}->{item}}, $element);
	$self->{changed} = 1;

  return 1;
}

sub remove_item {
  my ($self, $id) = @_;

  my @list = $self->lookup_item(feedid=>$id,invert=>1);

  $self->{handle}->{plkast}->{cache}->{item} = \@list;
	$self->{changed} = 1;

  return 1;
}

1;
