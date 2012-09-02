use strict;
use utf8;


package PlKast::UI::LoadScreen;
use Qt;
use PlKast::UI::LoadScreen::Impl;
use Qt::isa qw(PlKast::UI::LoadScreen::Impl);
use Qt::attributes qw();

sub NEW
{
    shift->SUPER::NEW(@_[0..3]);
}

1;
