use strict;
use utf8;

package PlKast::UI::MainForm;
use PlKast::UI::MainForm::Impl;
use Qt;
#use Qt::debug qw|verbose calls|;
use Qt::constants;
use Qt::isa qw(PlKast::UI::MainForm::Impl);

use Qt::attributes qw(feedData);
use Qt::slots
  openMediaFeed => ['QListViewItem*', 'const QPoint&', 'int'],
	downloadFeedItem => ['QListViewItem*', 'const QPoint&', 'int'],
	feedItemMenu => ['QListViewItem*', 'const QPoint&', 'int'],
	populateContentsList => ['QObject*'],
	errorHappened => ['const QString&'],
	plkastClosing => [];
use Qt::signals
	plkastClosing => [];

use Error qw(:try);

# Other dialogs
use PlKast::Feeds;
use PlKast::RssFeed;
use PlKast::Cache;
use PlKast::UI::AddDialog;
use PlKast::UI::ConfigDialog;
use PlKast::UI::LoadScreen;
use PlKast::UI::Widget::MediaFeed;
use PlKast::UI::Widget::FeedItem;
use PlKast::UI::Widget::ItemContextMenu;

sub NEW {
  shift->SUPER::NEW(@_[0..2]);
  &statusBar->message("Ready.");

	_initFeeds();

  refreshList();
}

sub _initFeeds {
  feedData = PlKast::Feeds();
	Qt::Object::connect(this, SIGNAL "plkastClosing()",
											feedData, SLOT "plkastClosing()");
}

sub errorHappened {
	my ($msg) = @_;

	Qt::MessageBox->warning(this, "PlKast: Error", $msg||"Unknown Error");
}

sub fileNew {
  my $self = shift;

  my $add_dlg = PlKast::UI::AddDialog();
  $add_dlg->show();
  if (!$add_dlg->exec()) {
    return;
  }

  try {
    feedData->add_feed(url=>$add_dlg->feedUrl->text, title=>$add_dlg->feedTitle->text);

    refreshList();
  } catch Error::Simple with {
    my $err = shift;
    Qt::MessageBox->warning($self, "$0: Error", "Error: ".$err->stringify);
  } otherwise {
    my $err = shift;
    Qt::MessageBox->warning($self, "$0: Error", "Error: ".$err->stringify);
  };
}

sub refreshList {
  my @list = @{&feedData->get_all_feeds()};

	use Data::Dumper;
	print STDERR Dumper(\@list);

  if (scalar(@list) == 0) {
    return;
  }

  for my $feed (@list) {
    my $litem = PlKast::UI::Widget::MediaFeed(mediaFeedsList,
					      $feed->{-title});
    $litem->setData($feed);
  }

  Qt::Object::connect(mediaFeedsList, SIGNAL "doubleClicked(QListViewItem*, const QPoint&, int)",
		      this, SLOT "openMediaFeed(QListViewItem*, const QPoint&, int)");
}

sub openMediaFeed {
  my ($item, $point, $c) = @_;

  my $feed = $item->getData;
  my $rss = PlKast::RssFeed(this, undef, feed=>$feed);
	Qt::Object::connect($rss, SIGNAL "contentsReady(QObject*)",
											this, SLOT "populateContentsList(QObject*)");
	Qt::Object::connect($rss, SIGNAL "reqFailed(const QString&)",
											this, SLOT "errorHappened(const QString&)");
#	Qt::O
	$rss->fetch();
}

sub populateContentsList {
	my ($rss) = @_;

  my $contents = $rss->get_contents;

  for my $content (@{$contents->{contents}}) {
    my $citem = PlKast::UI::Widget::FeedItem(feedContentsList);
		$citem->populate($content->title,
										 $content->author,
										 $content->date,
										 $content->duration);
		$citem->setFeed($content);
		if (PlKast::Cache()->lookup_single_item(feedid=>$content->feed_item_id)) {
			$citem->hilight(1);
		}
  }

	# Set up for the double-click.
	Qt::Object::connect(feedContentsList, SIGNAL "doubleClicked(QListViewItem*, const QPoint&, int)",
											this, SLOT "downloadFeedItem(QListViewItem*, const QPoint&, int)");

	# Set up for context-menu.
	Qt::Object::connect(feedContentsList, SIGNAL "contextMenuRequested(QListViewItem*, const QPoint&, int)",
											this, SLOT "feedItemMenu(QListViewItem*, const QPoint&, int)");
}

sub downloadFeedItem {
	my ($item, $point, $c) = @_;

	my $loader = PlKast::UI::LoadScreen(this);

	my $feed = $item->getFeed;
	$feed->download();
	$item->hilight(1);
}

sub fileSettings {
  my $cfg_dlg = PlKast::UI::ConfigDialog();
  $cfg_dlg->show();
  if (!$cfg_dlg->exec()) {
    return;
  }

	my $plr = $cfg_dlg->currentPlayer;
	$main::config->set_config("downloadCachePath",$cfg_dlg->downloadCachePath->text);
	$main::config->set_config('usePlayer', $plr->{name});
	$main::config->set_config('usePlayerId', $plr->{id});
	$main::config->set_config('playerCommand', $plr->{command});
}

sub feedItemMenu {
	my ($item, $point, $c) = @_;

	my $menu = PlKast::UI::Widget::ItemContextMenu(this, "feedItemMenu_ctx");
	$menu->setItem($item);
#	$menu->popup($point);
	$menu->exec($point);
}

sub fileExit {
	this->close;
}

sub helpIndex {
  print "PlKast::UI::MainForm->helpIndex(): (Private) Not implemented yet.\n";
}

sub helpContents {
  print "PlKast::UI::MainForm->helpContents(): (Private) Not implemented yet.\n";
}

sub helpAbout {
  print "PlKast::UI::MainForm->helpAbout(): (Private) Not implemented yet.\n";
}

1;
