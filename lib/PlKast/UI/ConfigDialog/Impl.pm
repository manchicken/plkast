# Form implementation generated from reading ui file 'ui/configdialog.ui'
#
# Created: Tue Oct 24 23:07:56 2006
#      by: The PerlQt User Interface Compiler (puic)
#
# WARNING! All changes made in this file will be lost!


use strict;
use utf8;


package PlKast::UI::ConfigDialog::Impl;
use Qt;
use Qt::isa qw(Qt::Dialog);
use Qt::slots
    okClicked => [];
use Qt::signals
    configAccepted => [];
use Qt::attributes qw(
    listBox
    feedTabs
    Widget2
    textLabel1
    downloadCachePath
    TabPage
    commandEdit
    commandLabel
    textLabel2
    builtinPlayersList
    commandExplained
    buttonHelp
    buttonOk
    buttonCancel
);



sub NEW
{
    shift->SUPER::NEW(@_[0..3]);

    if ( name() eq "unnamed" )
    {
        setName("configDialog" );
    }
    setSizeGripEnabled(1 );

    my $configDialogLayout = Qt::GridLayout(this, 1, 1, 11, 6, '$configDialogLayout');

    listBox = Qt::ListBox(this, "listBox");
    listBox->setSizePolicy( Qt::SizePolicy(0, 7, 0, 0, listBox->sizePolicy()->hasHeightForWidth()) );

    $configDialogLayout->addWidget(listBox, 0, 0);

    feedTabs = Qt::TabWidget(this, "feedTabs");

    Widget2 = Qt::Widget(feedTabs, "Widget2");
    my $Widget2Layout = Qt::GridLayout(Widget2, 1, 1, 11, 6, '$Widget2Layout');

    textLabel1 = Qt::Label(Widget2, "textLabel1");

    $Widget2Layout->addWidget(textLabel1, 0, 0);

    downloadCachePath = Qt::LineEdit(Widget2, "downloadCachePath");

    $Widget2Layout->addWidget(downloadCachePath, 0, 1);
    feedTabs->insertTab( Widget2, "" );

    TabPage = Qt::Widget(feedTabs, "TabPage");
    my $TabPageLayout = Qt::GridLayout(TabPage, 1, 1, 11, 6, '$TabPageLayout');

    commandEdit = Qt::LineEdit(TabPage, "commandEdit");

    $TabPageLayout->addWidget(commandEdit, 1, 1);

    commandLabel = Qt::Label(TabPage, "commandLabel");
    commandLabel->setAlignment( int(&Qt::Label::AlignVCenter | &Qt::Label::AlignRight) );

    $TabPageLayout->addWidget(commandLabel, 1, 0);

    textLabel2 = Qt::Label(TabPage, "textLabel2");
    textLabel2->setAlignment( int(&Qt::Label::AlignVCenter | &Qt::Label::AlignRight) );

    $TabPageLayout->addWidget(textLabel2, 0, 0);

    builtinPlayersList = Qt::ComboBox(0, TabPage, "builtinPlayersList");

    $TabPageLayout->addWidget(builtinPlayersList, 0, 1);

    commandExplained = Qt::Label(TabPage, "commandExplained");
    commandExplained->setAlignment( int(&Qt::Label::AlignTop | &Qt::Label::AlignHCenter) );

    $TabPageLayout->addMultiCellWidget(commandExplained, 2, 2, 0, 1);
    feedTabs->insertTab( TabPage, "" );

    $configDialogLayout->addWidget(feedTabs, 0, 1);

    my $Layout1 = Qt::HBoxLayout(undef, 0, 6, '$Layout1');

    buttonHelp = Qt::PushButton(this, "buttonHelp");
    buttonHelp->setAutoDefault( 1 );
    $Layout1->addWidget(buttonHelp);
    my $spacer = Qt::SpacerItem(20, 20, &Qt::SizePolicy::Expanding, &Qt::SizePolicy::Minimum);
    $Layout1->addItem($spacer);

    buttonOk = Qt::PushButton(this, "buttonOk");
    buttonOk->setAutoDefault( 1 );
    buttonOk->setDefault( 1 );
    $Layout1->addWidget(buttonOk);

    buttonCancel = Qt::PushButton(this, "buttonCancel");
    buttonCancel->setAutoDefault( 1 );
    $Layout1->addWidget(buttonCancel);

    $configDialogLayout->addMultiCellLayout($Layout1, 1, 1, 0, 1);
    languageChange();
    my $resize = Qt::Size(597, 364);
    $resize = $resize->expandedTo(minimumSizeHint());
    resize( $resize );
    clearWState( &Qt::WState_Polished );

    Qt::Object::connect(buttonOk, SIGNAL "clicked()", this, SLOT "okClicked()");
    Qt::Object::connect(buttonCancel, SIGNAL "clicked()", this, SLOT "reject()");
    Qt::Object::connect(this, SIGNAL "configAccepted()", this, SLOT "accept()");
}


#  Sets the strings of the subwidgets using the current
#  language.

sub languageChange
{
    setCaption(trUtf8("PlKast Configuration") );
    listBox->clear();
    listBox->insertItem( trUtf8("PlKast") );
    textLabel1->setText( trUtf8("Download Cache Path:") );
    feedTabs->changeTab( Widget2, trUtf8("Downloading") );
    commandLabel->setText( trUtf8("Command:") );
    textLabel2->setText( trUtf8("Supported Players:") );
    commandExplained->setText( trUtf8("Use %s in the place of where the file name should be placed.\n" .
    "If omitted, the file will be appended to the end of the command.\n" .
    "(e.g. amarok %s)") );
    feedTabs->changeTab( TabPage, trUtf8("Audio") );
    buttonHelp->setText( trUtf8("&Help") );
    buttonHelp->setAccel( Qt::KeySequence( trUtf8("F1") ) );
    buttonOk->setText( trUtf8("&OK") );
    buttonOk->setAccel( Qt::KeySequence( "" ) );
    buttonCancel->setText( trUtf8("&Cancel") );
    buttonCancel->setAccel( Qt::KeySequence( "" ) );
}


sub okClicked
{
    print "PlKast::UI::ConfigDialog::Impl->okClicked(): Not implemented yet.\n";
}

1;
