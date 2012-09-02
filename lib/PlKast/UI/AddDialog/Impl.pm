# Form implementation generated from reading ui file 'ui/adddialog.ui'
#
# Created: Sun Oct 8 16:41:58 2006
#      by: The PerlQt User Interface Compiler (puic)
#
# WARNING! All changes made in this file will be lost!


use strict;
use utf8;


package PlKast::UI::AddDialog::Impl;
use Qt;
use Qt::isa qw(Qt::Dialog);
use Qt::attributes qw(
    textLabel1
    buttonHelp
    buttonOk
    buttonCancel
    textLabel2
    feedUrl
    feedTitle
);



sub NEW
{
    shift->SUPER::NEW(@_[0..3]);

    if ( name() eq "unnamed" )
    {
        setName("AddDialog" );
    }
    setSizeGripEnabled(1 );


    textLabel1 = Qt::Label(this, "textLabel1");
    textLabel1->setGeometry( Qt::Rect(10, 10, 65, 20) );

    my $LayoutWidget = Qt::Widget(this, '$LayoutWidget');
    $LayoutWidget->setGeometry( Qt::Rect(10, 90, 300, 33) );
    my $Layout1 = Qt::HBoxLayout($LayoutWidget, 0, 6, '$Layout1');

    buttonHelp = Qt::PushButton($LayoutWidget, "buttonHelp");
    buttonHelp->setAutoDefault( 1 );
    $Layout1->addWidget(buttonHelp);
    my $spacer = Qt::SpacerItem(20, 20, &Qt::SizePolicy::Expanding, &Qt::SizePolicy::Minimum);
    $Layout1->addItem($spacer);

    buttonOk = Qt::PushButton($LayoutWidget, "buttonOk");
    buttonOk->setAutoDefault( 1 );
    buttonOk->setDefault( 1 );
    $Layout1->addWidget(buttonOk);

    buttonCancel = Qt::PushButton($LayoutWidget, "buttonCancel");
    buttonCancel->setAutoDefault( 1 );
    $Layout1->addWidget(buttonCancel);

    textLabel2 = Qt::Label(this, "textLabel2");
    textLabel2->setGeometry( Qt::Rect(10, 50, 65, 20) );

    feedUrl = Qt::LineEdit(this, "feedUrl");
    feedUrl->setGeometry( Qt::Rect(80, 50, 230, 23) );

    feedTitle = Qt::LineEdit(this, "feedTitle");
    feedTitle->setGeometry( Qt::Rect(80, 10, 230, 23) );
    languageChange();
    my $resize = Qt::Size(320, 133);
    $resize = $resize->expandedTo(minimumSizeHint());
    resize( $resize );
    clearWState( &Qt::WState_Polished );

    Qt::Object::connect(buttonOk, SIGNAL "clicked()", this, SLOT "accept()");
    Qt::Object::connect(buttonCancel, SIGNAL "clicked()", this, SLOT "reject()");

    setTabOrder(feedTitle, feedUrl);
    setTabOrder(feedUrl, buttonOk);
    setTabOrder(buttonOk, buttonCancel);
    setTabOrder(buttonCancel, buttonHelp);
}


#  Sets the strings of the subwidgets using the current
#  language.

sub languageChange
{
    setCaption(trUtf8("Add a Media Feed") );
    textLabel1->setText( trUtf8("Feed Title") );
    buttonHelp->setText( trUtf8("&Help") );
    buttonHelp->setAccel( Qt::KeySequence( trUtf8("F1") ) );
    buttonOk->setText( trUtf8("&OK") );
    buttonOk->setAccel( Qt::KeySequence( "" ) );
    buttonCancel->setText( trUtf8("&Cancel") );
    buttonCancel->setAccel( Qt::KeySequence( "" ) );
    textLabel2->setText( trUtf8("Feed URL") );
}


1;
