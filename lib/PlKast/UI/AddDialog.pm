use strict;
use utf8;


package PlKast::UI::AddDialog;
use Qt;
use PlKast::UI::AddDialog::Impl;
use Qt::isa qw(PlKast::UI::AddDialog::Impl);

sub NEW
{
    shift->SUPER::NEW(@_[0..3]);
}

1;
