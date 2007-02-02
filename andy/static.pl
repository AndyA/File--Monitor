#!/usr/bin/perl
#
#  static
#
#  Created by Andy Armstrong on 2007-01-30.
#  Copyright (c) 2007 Hexten. All rights reserved.

use strict;
use warnings;
use Carp;

$| = 1;

my @STAT_FIELDS = qw(
    dev inode mode num_links uid gid rdev size atime mtime ctime
    blk_size blocks
);

while (my $obj = shift) {
    print "$obj\n";
    my %info;
    @info{@STAT_FIELDS} = stat $obj;
    for (@STAT_FIELDS) {
        my $value = defined $info{$_} ? sprintf("0x%08x (%12d)", $info{$_}, $info{$_})
                                      : '(undefined)';
        printf("%10s : %s\n", $_, $value);
    }
}
