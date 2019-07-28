#!/usr/bin/perl

use strict;
use warnings;
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

my $dates = $dbh->selectall_arrayref(
    'select DATE(time) as date, count(*) from game group by date'
);
