use strict;
use warnings;

package PlKast::RssFeed;
use Qt;
use Qt::debug qw|verbose calls|;
use Qt::isa qw/PlKast/;
use Qt::constants qw/IO_ReadOnly IO_WriteOnly/;
use Qt::attributes qw/handle feed buffFile httpObj buffFileHandle/;
use Qt::slots
	fetchedData => ['const QHttpResponseHeader &'],
	reqDone => ['bool'],
	stateChanged => ['int'];
use Qt::signals
	contentsReady => ['QObject*'],
	reqFailed => ['const QString&'];

use Error qw{:try};
use XML::TreePP;

our $VERSION="0.01";

use constant USER_AGENT => "NotSoSoft plkast/".($VERSION||0)." (RSS/PodCast)";

sub NEW {
	shift->SUPER::NEW(@_);

	feed = &opts->{feed};
	buffFile = $main::config->get_config('downloadCachePath').'/xmlBufferFile.xml';

	httpObj = Qt::Http();
	Qt::Object::connect(httpObj, SIGNAL "stateChanged(int)",
											this, SLOT "stateChanged(int)");
	Qt::Object::connect(httpObj, SIGNAL "done(bool)",
											this, SLOT "reqDone(bool)");

	print STDERR "buffFile is '".buffFile."'\n";
}

sub stateChanged {
	print STDERR "HTTP STATE CHANGED: ".shift(@_)."\n";
}

# TODO: Needs caching somehow.
# TODO: Proxy support?
sub fetch {
	print STDERR "FETCHING!!!!\n";

  if (!feed) {
    throw Error::Simple("No feed specified.");
  } elsif (!ref(feed) || !defined(feed->{-url})) {
    throw Error::Simple("Unknown or unsupported feed provided.");
  }

	buffFileHandle = Qt::File(buffFile);
	buffFileHandle->open(IO_WriteOnly);
	my $url = Qt::Url(feed->{-url});

	httpObj->setHost($url->host);

#	my $req = Qt::HttpRequestHeader("GET", $url->path);

# 	## Let's do this with Qt.
# 	httpObj = Qt::Http(this, "rssfeed_http");

# 	httpObj->request($req, Qt::ByteArray($url->query), buffFileHandle);

	httpObj->get(feed->{-url});
print STDERR "Fetch triggered... waiting now.\n";
  return 1;
}

sub reqDone {
	my ($error) = @_;
	print STDERR "DONE TRIGGERRED\n";
	buffFileHandle->close();
	httpObj = undef;
	buffFileHandle = undef;
}

sub fetchedData {
	print STDERR "DATA CALLBACK\n";
	use bytes;
	my ($op) = @_;

	if ($op->state == &Qt::NetworkProtocol::StWaiting ||
			$op->state == &Qt::NetworkProtocol::StInProgress ||
			$op->state == &Qt::NetworkProtocol::StStopped) {
		return 1;
	} elsif ($op->state == &Qt::NetworkProtocol::StFailed) {
		throw Error::Simple("Failed to fetch data '".$op->url->toString()."': ".$op->protocolDetail);
	}

	my $xml = bytes::chr($op->readAll());
	no bytes;

	my $parser = XML::TreePP->new();
	handle = $parser->parse($xml);

	print STDERR "FIRING contentsReady.\n";
	emit contentsReady(this);

	return 1;
}

sub get_contents {
  my @contents = ();
  my @fails = ();;

  for my $item (@{&handle->{rss}->{channel}->{item}}) {
    try {
      my $obj = PlKast::RssFeed::Item();
      $obj->from_hashref($item);
      push(@contents, $obj);
    } otherwise {
			my $err = shift;
			warn("Error detected: ".$err->stringify);
      push(@fails, $item);
    };
  }

  my $to_return = {contents=>\@contents,fails=>\@fails};

  return $to_return;
}

1;
