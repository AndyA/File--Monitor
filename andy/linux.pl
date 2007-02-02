#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use Linux::Inotify2;

$| = 1;


# create a new object
my $inotify = new Linux::Inotify2
    or die "Unable to create new inotify object: $!" ;

# create watch
$inotify->watch ("/home/andy/Works/Perl/File-Monitor/andy", IN_ALL_EVENTS)
    or die "watch creation failed" ;

while () {
    my @events = $inotify->read;
    unless (@events > 0) {
        print "read error: $!";
        last;
    }

    for my $event (@events) {
        for my $attr (qw(name fullname mask cookie)) {
            my $val = $event->$attr();
            my $fmt = $attr eq 'mask' ? '%08x' : '%s';
            printf("%10s : $fmt\n", $attr, $val);
        }
    }
}
