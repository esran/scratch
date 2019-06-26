#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

sub contains
{
    my ($value, @array) = @_;

    for my $val (@array) {
        return 1 if $val eq $value;
    }

    return 0;
}

sub do_test
{
    my ($test, $pairs, $start, $orig_set1, $orig_set2) = @_;
    my @set1 = ();
    my @set2 = ();

    if (defined $start) {
        @set1 = @$orig_set1;
        @set2 = @$orig_set2;
    } else {
        $start = 0;
    }

    for my $i ($start .. scalar @$pairs - 1) {
        my $pair = $pairs->[$i];
        my $a = $pair->{a};
        my $b = $pair->{b};

        # special case for first pairs
        if (@set1 == 0) {
            push @set1, $a;
            push @set2, $b;
        }

        # check if value a is in one of the sets
        if (contains($a, @set1)) {
            if (contains($b, @set1)) {
                # both of this pair are already in set1
                return "fail";
            } elsif (contains($b, @set2)) {
                # this pair is already safely in sets
                next;
            } else {
                # only one of this pair is in a set
                push @set2, $b;
                next;
            }
        } elsif (contains($a, @set2)) {
            if (contains($b, @set2)) {
                # both of this pair are already in set2
                return "fail";
            } elsif (contains($b, @set1)) {
                # this pair is already safely in sets
                next;
            } else {
                # only on of this pair is in a set
                push @set1, $b;
                next;
            }
        }

        # a is in neither set, so check b
        if (contains($b, @set1)) {
            push @set2, $a;
            next;
        }

        if (contains($b, @set2)) {
            push @set1, $a;
            next;

        }

        # neither a or b are in either set so we have two options
        # here.

        # try left/right first
        my @new_set1 = @set1;
        my @new_set2 = @set2;
        push @new_set1, $a;
        push @new_set2, $b;

        last if do_test($test, $pairs, $i+1, \@new_set1, \@new_set2) eq "ok";

        # now try right/left
        @new_set1 = @set1;
        @new_set2 = @set2;
        push @new_set1, $b;
        push @new_set2, $a;

        last if do_test($test, $pairs, $i+1, \@new_set1, \@new_set2) eq "ok";

        # neither solution worked so fail
        return "fail";
    }

    return "ok";
}

my $test_num = -1;
my @pairs = ();

# process input
while(<>) {
    # identify test as it will have #N
    if ($_ =~ /#(\d+)/) {
        $test_num = $1;
        @pairs = ();
        next;
    }

    # a blank line indicates end of test data
    if ($_ =~ /^$/) {
        print "Test $test_num: " . do_test($test_num, \@pairs) . "\n";
        $test_num = -1;
    }

    # each test line is two words with space divider
    my ($a, $b) = split (" ", $_);
    push @pairs, { a => $a, b => $b };
}

# pick up last test
if ($test_num > 0) {
    print "Test $test_num: " . do_test($test_num, \@pairs) . "\n";
}