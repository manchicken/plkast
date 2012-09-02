#!/usr/bin/perl
use Qt;
use Qt::constants qw/IO_WriteOnly/;

$f = Qt::File("example");
$f->open( IO_WriteOnly ); # see 'Constants' below
$s = Qt::TextStream( $f );
$s << "What can I do with " << 12 << " apples?";
$f->close();
