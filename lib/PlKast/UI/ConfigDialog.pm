use strict;
use utf8;


package PlKast::UI::ConfigDialog;
use Qt;
use PlKast::UI::ConfigDialog::Impl;
use Qt::isa qw(PlKast::UI::ConfigDialog::Impl);
use Qt::attributes qw(players lastBuiltinIndex currentCommand lastId);
use Qt::slots
	builtinChanged => ['int'];

use PlKast::Player;

sub NEW
{
	shift->SUPER::NEW(@_[0..3]);
	this->downloadCachePath->setText($main::config->get_config('downloadCachePath'));

	lastId = 0;

	players = \%PlKast::Player::builtins;
	my $pls = players;

	builtinPlayersList->insertItem(trUtf8("Custom Command..."));

	for my $key (sort { lc($a) cmp lc($b) } keys(%$pls)) {
		lastBuiltinIndex = this->builtinPlayersList->count;
		players->{$key}->{id} = lastBuiltinIndex;
		builtinPlayersList->insertItem(trUtf8(players->{$key}->{name}),
																	 players->{$key}->{id});
		if (players->{$key}->{default}) {
			builtinPlayersList->setCurrentItem(players->{$key}->{id});
			builtinChanged(players->{$key}->{id});
		}
	}

	my $s_id = $main::config->get_config('usePlayerId');
	my $s_name = $main::config->get_config('usePlayer');
	if (defined($s_id) && defined($s_name) &&
			getPlayerById($s_id)->{name} eq $s_name) {
		builtinPlayersList->setCurrentItem($s_id);
		builtinChanged($s_id);
		print STDERR "SWITCHING TO PLAYER $s_id:$s_name\n";
	} else {
		print STDERR "NOT MOVING!\n";
	}

	Qt::Object::connect(builtinPlayersList, SIGNAL "activated(int)",
											this, SLOT "builtinChanged(int)");
}

sub currentPlayer {
	return getPlayerById(builtinPlayersList->currentItem);
}

sub getPlayerById {
	my ($id) = @_;

	if ($id > 0) {
		my $pls = players;
		for my $plr (keys (%$pls)) {
			if ($pls->{$plr}->{id} == $id) {
				return $pls->{$plr};
			}
		}
	} else {
		return PlKast::Player(undef, 'cfgDialog-Player',
													name=>builtinPlayersList->currentText,
													command=>commandEdit->text);
	}
}

sub okClicked {
	if (!(-d this->downloadCachePath->text)) {
		Qt::MessageBox->warning(this, "PlKast: Error", "The path '".this->downloadCachePath->text."' doesn't exist.");
	} else {
		emit configAccepted();
	}
}

sub builtinChanged {
	my $changed_to = shift;

	if (lastId == 0) {
		currentCommand = commandEdit->text;
	}

	if ($changed_to > 0) {
		commandLabel->setEnabled(0);
		commandEdit->setEnabled(0);
		commandExplained->setEnabled(0);
		commandEdit->setText(currentPlayer->{command});
	} else {
		commandLabel->setEnabled(1);
		commandEdit->setEnabled(1);
		commandExplained->setEnabled(1);
		if ($main::config->get_config('usePlayerId') > 0 || lastId > 0) {
			commandEdit->setText(currentCommand || $main::config->get_config('playerCommand') || "");
		}
	}

	lastId = $changed_to;
}

1;
