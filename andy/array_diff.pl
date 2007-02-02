#!/usr/bin/perl

use strict;
use warnings;
use Carp;
use Benchmark;
use Storable qw(freeze);

$| = 1;

srand(1);

sub random_string {
    my $str = '';
    for (1 .. 20) {
        $str .= chr(rand(26) + ord('a'));
    }
    return $str;
}

my (@ar1, @ar2);

for (1 .. 100000) {
    my $rs = random_string();
    push @ar1, $rs;
    push @ar2, $rs;
    unless ($_ % 10) {
        push @ar1, random_string();
        push @ar2, random_string();
    }
}

my ($h1, $h2) = diff_hash2(\@ar1, \@ar2);
my ($l1, $l2) = diff_lex(\@ar1, \@ar2);

die "h1 <> l1" unless same($h1, $l1);
die "h2 <> l2" unless same($h2, $l2);

timethese(10, {
    diff_hash2  => sub { diff_hash2(\@ar1, \@ar2); },
    diff_lex    => sub { diff_lex(\@ar1, \@ar2); }
});

sub same {
    my ($this, $that) = @_;
    my @this = sort @$this;
    my @that = sort @$that;
    return freeze(\@this) eq freeze(\@that);
}

sub diff_hash {
    my ($ar1, $ar2) = @_;

    my %this = map { $_ => 1 } @$ar1;
    my %that = map { $_ => 1 } @$ar2;

    my @in_this = ( );
    my @in_that = ( );

    for (@$ar1) {
        push @in_this, $_ unless $that{$_};
    }
    
    for (@$ar2) {
        push @in_that, $_ unless $this{$_};
    }
    
    return ( \@in_this, \@in_that );
}

sub diff_hash2 {
    my ($this, $that) = @_;

    my %which = map { $_ => 1 } @$this;
    $which{$_} |= 2 for @$that;

    my @diff;
    while (my ($v, $w) = each %which) {
        push @{ $diff[$w-1] }, $v if $w < 3;
    }

    return @diff;
}

sub diff_lex {
    my ($ar1, $ar2) = @_;
    my @this = sort @$ar1;
    my @that = sort @$ar2;

    my @in_this = ( );
    my @in_that = ( );

    while (@this && @that) {
        if ($this[0] lt $that[0]) {
            push @in_this, shift @this;
        } elsif ($that[0] lt $this[0]) {
            push @in_that, shift @that;
        } else {
            shift @this;
            shift @that;
        }
    }
    
    push @in_this, @this;
    push @in_that, @that;
    
    return ( \@in_this, \@in_that );
}
