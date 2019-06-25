#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

my @candidates = ();
my $current_ok = 1;
my $test_num = -1;

while(<>) {
    if ($_ =~ /Test case #(\d+)/) {
        if ($current_ok == 1 and $test_num > 0) {
            print "Test $test_num: OK\n";
        }

        $test_num = $1;
        $current_ok = 1;
        @candidates = ();

        print "Test $test_num...\n";

        next;
    }

    next if $current_ok != 1;

    ($a, $b) = split (" ", $_);

    print "  - values: $a, $b\n";
    # print '  - current candidates: ' . "\n" . Dumper(@candidates);

    # no candidates so simply create a candidate with each value
    if (scalar @candidates == 0) {
        my $new_cand = { s1 => undef, s2 => undef };
        push @{$new_cand->{s1}}, $a;
        push @{$new_cand->{s2}}, $b;
        push @candidates, $new_cand;
        next;
    }

    my $i = 0;
    my @new_candidates = ();
    for my $cand (@candidates) {
        my ($s1, $s2) = (0, 0);

        $s1 = 1 if $a ~~ @{$cand->{s1}};
        $s1 = 2 if $a ~~ @{$cand->{s2}};
        $s2 = 1 if $b ~~ @{$cand->{s1}};
        $s2 = 2 if $b ~~ @{$cand->{s2}};

        print "  - candidate[$i]: $s1, $s2\n";

        # check for possible outcomes
        if ($s1 > 0 and $s1 == $s2) {
            # remove this candidate
            print "  - removing current candidate\n";
            splice @candidates, $i, 1;
            # check for 0 candidates and mark as failed at that point
            if (scalar @candidates == 0) {
                print "Test $test_num: Fail\n";
                $current_ok = 0;
                last;
            }
        } elsif ($s1 > 0 and $s2 == 0) {
            # a is in one of the sets but b isn't
            print "  - matched $a only\n";
            if ($s1 == 1) {
                push @{$cand->{s2}}, $b;
            } else {
                push @{$cand->{s1}}, $b;
            }
        } elsif ($s2 > 0 and $s1 == 0) {
            # b is in one of the sets but a isn't
            print "  - matched $b only\n";
            if ($s2 == 1) {
                push @{$cand->{s2}}, $a;
            } else {
                push @{$cand->{s1}}, $a;
            }
        } else {
            # neither is already matched
            print "  - no match";
            # add to current candidate
            push @{$cand->{s1}}, $a;
            push @{$cand->{s2}}, $b;
            # add a new candidate with a/b reversed into the sets
            my $new_cand = { s1 => undef, s2 => undef };
            push @{$new_cand->{s1}}, @{$new_cand->{s1}};
            push @{$new_cand->{s2}}, @{$new_cand->{s2}};
            push @{$new_cand->{s2}}, $a;
            push @{$new_cand->{s1}}, $b;
            push @new_candidates, $new_cand;
        }

        $i++;
    }

    # add new candidates
    push @candidates, @new_candidates;
}

# pick up if last test was ok
if ($current_ok == 1 and $test_num > 0) {
	print "Test $test_num: OK\n";
}
