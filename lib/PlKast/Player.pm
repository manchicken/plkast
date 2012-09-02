use strict;

package PlKast::Player;
use Qt;
#use Qt::debug qw/verbose calls/;
use Qt::isa qw/PlKast/;
use Qt::attributes qw/name command/;

use Error qw/:try/;

our $VERSION="0.01";

sub NEW {
	shift->SUPER::NEW(@_);

	name = &opts->{name};
	command = &opts->{command};

  if (!defined(name) || !length(name)) {
    throw Error::Simple("No name specified when creating builtin.");
  } elsif (!defined(command) || !length(command)) {
    throw Error::Simple("No command specified when creaing builtin.");
  }
}

sub play {
  my ($file) = @_;

  my $cmd = this->command;
  if ($cmd =~ m/%s/i) {
    $cmd =~ s/\%s/$file/ig;
    print STDERR "\%s CMD == '$cmd' '$file'\n";
  } else {
    $cmd .= ' '.$file;
    print STDERR "append CMD == '$cmd' '$file'\n";
  }

  # Unless finally makes sense.
  print STDERR "Executing '$cmd'\n";
  if (system($cmd)) {
    throw Error::Simple("Command '$cmd' failed: ($?)$!");
  }

  return 1;
}

package PlKast::Player::Builtin;
%PlKast::Player::Builtin::collection = (
																				amarok=>PlKast::Player->NEW(undef, "amarok_player",
																															 name=>'Amarok',
																															 command=>'amarok %s',
																															 default=>1
																													 ),
																				xmms=>PlKast::Player->NEW(undef, "xmms_player",
																														 name=>'XMMS',
																														 command=>'xmms %s'
																												 ),
																		);

1;
