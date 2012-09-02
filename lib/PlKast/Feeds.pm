use strict;

package PlKast::Feeds;
use Qt;
use Qt::isa qw/PlKast/;
use Qt::constants qw/IO_ReadOnly IO_WriteOnly/;
use Qt::attributes qw/handle loaded changed feeds/;
use Qt::slots
	plkastClosing => [];

use Error qw{:try};
use XML::TreePP;

our $VERSION=0.01;

use constant DATA_GROUP_NAME => "feeds";

sub NEW {
	shift->SUPER::NEW(@_);

	handle = undef;
	loaded = 0;
	changed = 0;
	feeds = [];

	try {
		_xml_load();
	} catch Error::Simple with {
		my $err = shift;
		warn(__PACKAGE__.": Load failed: ".$err->stringify);
		_set_stubbed_handle();
	} otherwise {
		my $err = shift;

		throw $err;
	};
}

sub plkastClosing {
  _xml_save();
}

sub fname {
  return &_get_data_file_name(DATA_GROUP_NAME);
}

sub _grab_feed_id {
  my (%opts) = @_;

	return crypt($opts{title}.$opts{url}, 'pk');
}

sub _set_stubbed_handle {
	handle = {plkast=>{feeds=>{url=>[]}}};
	use Data::Dumper;

	print "STUBBED HANDLE: ".Dumper(handle);
}

sub _xml_load {
	my $parser = XML::TreePP->new();
	$parser->set(force_array=>['url']);
	my $fil = Qt::File(&fname);
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
	$parser->set(force_array=>['url']);
	my $fil = Qt::File(this->fname);
	$fil->open(IO_WriteOnly);
	my $stream = Qt::TextStream($fil);

	$stream<<$parser->write(this->handle)<<"\n";
	changed = 0;

	$fil->close();

	return 1;
}

sub lookup_feed {
  my (%opts) = @_;

  if (!defined($opts{url}) && !defined($opts{title}) && !defined($opts{id})) {
    throw Error::Simple("Not enough data to lookup a feed with.  I need an ID, title, or URL.");
  }

  my $findkey = undef;
  my $findvalue = undef;

  # This lets us set a preferred list of lookup fields.  ID beats URL which beats title.
  for my $key (qw/id url title/) {
    if (defined($opts{$key})) {
      $findkey = "-$key";
      $findvalue = $opts{$key};
      last;
    }
  }

  my @results = ();
  for my $one (@{this->handle->{plkast}->{feeds}->{url}}) {
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

sub add_feed {
  my (%opts) = @_;

  if (!defined($opts{url}) || !defined($opts{title})) {
    throw Error::Simple("Not enough data passed to add_feed.  Expected at least title and URL.");
  }

  $opts{id} = this->_grab_feed_id(%opts);

  if (scalar(this->lookup_feed(id=>$opts{id}))) {
    throw Error::Simple("Duplicate feed.");
  }

  my $element = {
		 -id=>$opts{id},
		 -title=>$opts{title},
		 -url=>$opts{url},
	     };

  push(@{this->handle->{plkast}->{feeds}->{url}}, $element);
	changed = 1;

  return 1;
}

sub remove_feed {
  my ($id) = @_;

  my @list = this->lookup_feed(id=>$id,invert=>1);

  this->handle->{plkast}->{feeds}->{url} = \@list;
	changed = 1;

  return 1;
}

sub get_all_feeds {
  my (%opts) = @_;

  if (scalar(@{&handle->{plkast}->{feeds}->{url}}) == 0) {
    return [];
  }

  $opts{sort} ||= 'title';

  my @to_return = ();

  @to_return = sort { $a->{"-".$opts{sort}} cmp $b->{"-".$opts{sort}} }
    @{&handle->{plkast}->{feeds}->{url}};

# 	use Data::Dumper;
# 	print Dumper(\@to_return);

  return \@to_return;
}

1;
__END__
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
#   $self->{handle}->{plkast}->{feeds}->{url} ||= [];

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

# sub lookup_feed {
#   my ($self, %opts) = @_;

#   if (!defined($opts{url}) && !defined($opts{title}) && !defined($opts{id})) {
#     throw Error::Simple("Not enough data to lookup a feed with.  I need an ID, title, or URL.");
#   }

#   my $findkey = undef;
#   my $findvalue = undef;

#   # This lets us set a preferred list of lookup fields.  ID beats URL which beats title.
#   for my $key (qw/id url title/) {
#     if (defined($opts{$key})) {
#       $findkey = "-$key";
#       $findvalue = $opts{$key};
#       last;
#     }
#   }

#   my @results = ();
#   for my $one (@{$self->{handle}->{plkast}->{feeds}->{url}}) {
#     if (($opts{invert}||0) > 0) {
#       if ($one->{$findkey} ne $findvalue) {
# 	push(@results, $one);
#       }
#     } else {
#       if ($one->{$findkey} eq $findvalue) {
# 	push(@results, $one);
#       }
#     }
#   }

#   return @results;
# }

# sub add_feed {
#   my ($self, %opts) = @_;

#   if (!defined($opts{url}) || !defined($opts{title})) {
#     throw Error::Simple("Not enough data passed to add_feed.  Expected at least title and URL.");
#   }

#   $opts{id} = $self->_grab_feed_id(%opts);

#   if (scalar($self->lookup_feed(id=>$opts{id}))) {
#     throw Error::Simple("Duplicate feed.");
#   }

#   my $element = {
# 		 -id=>$opts{id},
# 		 -title=>$opts{title},
# 		 -url=>$opts{url},
# 	     };

#   push(@{$self->{handle}->{plkast}->{feeds}->{url}}, $element);

#   return 1;
# }

# sub remove_feed {
#   my ($self, $id) = @_;

#   my @list = $self->lookup_feed(id=>$id,invert=>1);

#   $self->{handle}->{plkast}->{feeds}->{url} = \@list;

#   return 1;
# }

# sub get_all_feeds {
#   my ($self, %opts) = @_;

#   if (scalar(@{$self->{handle}->{plkast}->{feeds}->{url}}) == 0) {
#     return ();
#   }

#   $opts{sort} ||= 'title';

# #   use Data::Dumper;
# #   print STDERR __LINE__.": get_all_feeds: ".Dumper($self->{handle});

#   my @to_return = ();

#   @to_return = sort { $a->{"-".$opts{sort}} cmp $b->{"-".$opts{sort}} }
#     @{$self->{handle}->{plkast}->{feeds}->{url}};

# #  print STDERR __LINE__.": \@to_return: ".Dumper(\@to_return);

#   return @to_return;
# }

1;
