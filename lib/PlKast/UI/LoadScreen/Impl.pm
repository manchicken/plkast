# Form implementation generated from reading ui file 'ui/loadscreen.ui'
#
# Created: Sun Oct 8 20:36:43 2006
#      by: The PerlQt User Interface Compiler (puic)
#
# WARNING! All changes made in this file will be lost!


use strict;
use utf8;


package PlKast::UI::LoadScreen::Impl;
use Qt;
use Qt::isa qw(Qt::Dialog);
use Qt::attributes qw(
    loadingLabel
);



sub NEW
{
    shift->SUPER::NEW(@_[0..3]);

    if ( name() eq "unnamed" )
    {
        setName("LoadScreen" );
    }
    setModal(1 );

    my $LoadScreenLayout = Qt::HBoxLayout(this, 11, 6, '$LoadScreenLayout');

    loadingLabel = Qt::Label(this, "loadingLabel");
    loadingLabel->setAlignment( int(&Qt::Label::AlignCenter) );
    $LoadScreenLayout->addWidget(loadingLabel);
    languageChange();
    my $resize = Qt::Size(193, 50);
    $resize = $resize->expandedTo(minimumSizeHint());
    resize( $resize );
    clearWState( &Qt::WState_Polished );
}


#  Sets the strings of the subwidgets using the current
#  language.

sub languageChange
{
    setCaption(trUtf8("PlKast: Loading") );
    loadingLabel->setText( trUtf8("Loading, please wait...") );
}


1;
