use strict;
use utf8;

package PlKast::UI::Widget::ItemContextMenu;
use Qt;
#use Qt::debug qw|verbose calls|;
use Qt::constants;
use Qt::isa qw(Qt::PopupMenu);
use Error qw(:try);
use Qt::attributes qw(theItem actions);
use Qt::slots
	playAction => ['int'];
use Qt::signals;

use PlKast::UI::LoadScreen;

## TODO: Add actions:
# download, transfer, info

sub NEW {
  shift->SUPER::NEW(@_[0..2]);

	this->insertItem(trUtf8("&Play"),
									 this, SLOT "playAction(int)",
									 Qt::KeySequence('p'));
}

sub setItem {
	theItem = shift;
}

sub getItem {
	return theItem;
}

sub playAction {
	my $loader = PlKast::UI::LoadScreen(this);

	try {
		this->theItem->getFeed->play($loader);
	} catch Error::Simple with {
		my $err = shift;
		Qt::MessageBox->critical($main::main, "PlKast: Error", "Failed to play: ".$err->stringify);
	} otherwise {
		my $err = shift;
		Qt::MessageBox->critical($main::main, "PlKast: Error", "Failed to play: ".$err->stringify);
	} finally {

	};
}

1;
