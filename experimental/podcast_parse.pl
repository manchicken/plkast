#!/usr/bin/perl
use XML::TreePP;
use Data::Dumper;

my $tpp = XML::TreePP->new(force_array=>[qw(item)]);
my $handle = $tpp->parsehttp(GET=>'http://www.1up.com/flat/Podcasts/podcasts.xml');
print Dumper($handle);
