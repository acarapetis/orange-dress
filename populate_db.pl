#!/usr/bin/perl

use strict;
use warnings;
#use Data::Dumper;
use lib '.';
use Replay ':enums';
use Getopt::Long;
use DBI;

my $db   = 'orangedress';
my $user = 'orangedress';
my $pw   = 'orangedress';

GetOptions (
    'db=s' => \$db,
    'user=s' => \$user,
    'password=s' => \$pw,
);

my $dbh = DBI->connect("dbi:mysql:database=$db;host=localhost", $user, $pw, {
        AutoCommit => 1, RaiseError => 1, PrintError => 1,
});

my $sth = $dbh->prepare('REPLACE INTO game (id, spy, spy_display, sniper, sniper_display, result, winner, map, time) VALUES (?,?,?,?,?,?,?,?,from_unixtime(?))');
while (my $file = <>) {
    chomp $file;
    my $replay = eval { Replay->from_file($file) };
    if ($@) {
        print "Error processing $file: $@\n";
        next;
    }
    my @row = (
        $replay->{GameID},
        $replay->{SpyName},
        $replay->{SpyDisplayName},
        $replay->{SniperName},
        $replay->{SniperDisplayName},
        $replay->{Result} + 1,
        $replay->result_winner(),
        $replay->{MapHash},
        $replay->{StartTime},
    );
    $sth->execute(@row);
}

