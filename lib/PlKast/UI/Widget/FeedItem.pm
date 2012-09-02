use strict;

package PlKast::UI::Widget::FeedItem;
use Qt;
use Qt::isa qw(Qt::ListViewItem);
use Qt::attributes qw(feedData rssFeed);

use PlKast::Hardcodes;
use PlKast::RssFeed;

sub NEW {
  shift->SUPER::NEW(@_[0..3]);
}

sub setFeed {
  feedData = shift;
}

sub getFeed {
  return feedData;
}

sub my_width {
	my $x = this->listView->columnWidth(shift);

	print STDERR $x."\n";
	return $x;
}

sub my_alignment {
	my $x = this->listView->columnAlignment(shift);
	print STDERR $x."\n";
	return $x;
}

sub populate {
	my (@cols) = @_;

	hilight(0);
	for (my $x = 0; defined($cols[$x]); $x += 1) {
		setText($x+1, $cols[$x]);
	}

	return 1;
}

sub hilight {
	my $image = shift(@_)?PlKast::Hardcodes::GOTIT_PIXMAP:PlKast::Hardcodes::MISSING_PIXMAP;
	my $pixmap = PlKast::Hardcodes::PIXMAP_PATH."/$image";
	my $pobj = Qt::Pixmap($pixmap);
	setPixmap(0,$pobj);

	return 1;
}

1;
