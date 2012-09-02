package PlKast::RssFeed::Item;
use Qt;
use Qt::isa qw/PlKast/;
use Qt::attributes qw/
title link description
date guid author
enclosure duration explicit
keywords image/;

use Digest::MD5 qw(md5_hex);

use PlKast::Cache;
use PlKast::Player;

#use threads;

#use File::Temp qw(tempfile);
# sub title {return shift->_get_or_set('title',@_);};

# sub link {return shift->_get_or_set('link',@_);};

# sub description {return shift->_get_or_set('description',@_);};

# sub date {return shift->_get_or_set('date',@_);};

# sub guid {return shift->_get_or_set('guid',@_);};

# sub author {return shift->_get_or_set('author',@_);};

# # sub category {return shift->_get_or_set('category',@_);}; #don't care about this yet

# sub enclosure {return shift->_get_or_set('enclosure',@_);};

# sub duration {return shift->_get_or_set('duration',@_);};

# sub explicit {return shift->_get_or_set('explicit',@_);};

# sub keywords {return shift->_get_or_set('keywords',@_);}

# sub image {return shift->_get_or_set('image',@_);};

sub feed_item_id($) {
  my ($self) = @_;

  return md5_hex(this->enclosure->{-url}.this->date.this->author);
}

sub from_hashref {
  my ($item) = @_;

  my @required_keys = qw{title enclosure itunes:author itunes:duration pubDate};
  for my $key (@required_keys) {
    if (!defined($item->{$key})) {
      throw Error::Simple("Missing required key '$key'!");
    }
  }

  my %keymap = (
								title => sub { this->title = shift },
								link => sub { this->link = shift },
								description => sub { this->description = shift },
								pubDate => sub { this->date = shift },
								guid => sub { this->guid = shift },
								'itunes:author' => sub { this->author = shift },
								enclosure => sub { this->enclosure = shift},
								'itunes:duration' => sub { this->duration = shift },
								'itunes:keywords' => sub { this->keywords = shift },
								'itunes:explicit' => sub { this->explicit = shift },
								'itunes:image' => sub { this->image = shift },
						);

  for my $key (keys(%keymap)) {
    my $method = $keymap{$key};
    my $value = defined($item->{$key})?$item->{$key}:undef;
    $method->($value);
  }

  return 1;
}

sub download {
	my $cache = PlKast::Cache();

	if (scalar($cache->lookup_item(feedid=>this->feed_item_id)) > 0) {
		return 1;
	}

  my $url = this->enclosure->{-url} ||
    throw Error::Simple('No URL specified in the item');

	my $suffix = (split(m/\./, $url))[-1];

	## Use Qt's HTTP stuff.
#   my $ua = LWP::UserAgent->new;
#   $ua->agent(PlKast::RssFeed::USER_AGENT);
#   my $req = HTTP::Request->new(GET=>$url);
#   my $res = $ua->request($req);

#   if (!$res->is_success) {
# 		throw Error::Simple("Failed to download file '$url': ".$res->status_line);
#   }

# 	my ($fh, $filename) = tempfile('plkast_cacheXXXXX',
# 																 SUFFIX=>".$suffix",
# 																 DIR=>$main::config->get_config('downloadCachePath'),
# 																 CLEANUP=>0);
# 	print $fh $res->content;
# 	close($fh);

#	$cache->add_item(file=>$filename,url=>$url,feedid=>$self->feed_item_id);

	return 1;
}

sub play {
	my ($self) = @_;

	$self->download();

	my $cache = PlKast::Cache->new();
	my @citems = $cache->lookup_item(feedid=>$self->feed_item_id);
	my $player = PlKast::Player->new(name=>$main::config->get_config('usePlayer'),
																	 command=>$main::config->get_config('playerCommand'));
	for my $cache_item (@citems) {
		$player->play($cache_item->{-file});
	}
}

1;
