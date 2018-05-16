#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use lib '.';
use Replay;

my $file = shift @ARGV;
my $replay = Replay->from_file($file);
print Dumper($replay);
