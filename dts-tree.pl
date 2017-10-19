#!/usr/bin/perl

# How to use this script:
# 1. Your linux src goes to $ROOT/linux
# 2. This script goes to $ROOT/scripts
# 3. Run:
#	cd $ROOT/linux
#	find arch/arm/boot/dts/ \( -name '*\.dts' -o -name '*\.dtsi' \)  -printf "%f\n" > ../scripts/list.txt
# 4. Run:
# 	cd $ROOT/scripts
# 	./dts-tree.pl
#
# If your setup is different, adjust the "$path" variable down below.
#
use strict;
use warnings;

# Imagine files A (right) and Z (left) :
# +--------------+  +--------------+
# |#include B    |  |#include A    |
# |#include Y    |  |#include Y    |
# |              |  |              |
# +--------------+  +--------------+
# 
# tree is a hash of arrays where each hash
# is the file name and the array is what it includes. So:
# A => { B, Y }
# Z => { A, Y }
# rtree is the 'reverse' tree. Each hash is a file, and the
# array is what file it is included by. So:
# A => { Z }
# Y => { A, Z }
# and so on...
my %tree = ();
my %rtree = ();

# Recursively print from the rtree given an array of children nodes.
sub print_children_r {
	my $included = $_[0];
	my $depth = $_[1];
	my @children = @{$_[2]};

	print "|    " x ($depth - 1);
	print "|----";
	print "$included\n";
	foreach my $ch ( @children ) {
		print_children_r($ch, $depth + 1, \@{$rtree{$ch}});
	}
}

# Recursively print from the tree given an array of children nodes.
sub print_children_t {
	my $includer = $_[0];
	my $depth = $_[1];
	my @children = @{$_[2]};

	print "|    " x ($depth - 1);
	print "|----";
	print "$includer\n";
	foreach my $ch ( @children ) {
		print_children_t($ch, $depth + 1, \@{$tree{$ch}});
	}
}

open(my $fh, "<list.txt") or die "Could not open list.txt\n";
my $path = "../linux/arch/arm/boot/dts/";

# First generate 'tree' since it's easier. For each file in our list, find out
# what it includes and create an array for its hash.
while (my $thisfile = <$fh>) {
	chomp($thisfile);

	open(my $F, "<$path$thisfile") or die "$path$thisfile problem!\n";
	my @list = <$F>;
	close $F;

	# for files that don't include anything, there should be an empty array
	@{ $tree{$thisfile} } = ();

	my @includes = grep /#include/,@list;
	chomp(@includes);
	
	foreach my $line (@includes) {
		(my $included_file) = ($line =~ /^#include "(.+?)"/);

		if (defined $included_file) {
			# skip '.h' files. we just want dts/dtsi
			if (!($included_file =~ /\.h$/i)) {
				push @{ $tree{$thisfile} }, $included_file;
			}
		}
	}

}

# Generate the rtree from tree
foreach my $included ( keys %tree) {
	foreach my $includer ( @{ $tree{$included} } ) {
		push @{ $rtree{$includer} }, $included;
	}
}

# Walk over the 'tree' which has a hash for every file on our list. If the file
# is a top level file, i.e. doesn't include any files itself, then print that
# file and its children recursively.
print "================INCLUDED TREE ======================\n";
foreach my $included ( keys %tree) {
	if (!@{$tree{$included}}) {
		print_children_r($included, 0, \@{$rtree{$included}});
	}
}

# Now do it for the reverse case.
print "================INCLUDER TREE ======================\n";
foreach my $includer ( keys %rtree) {
	if (!@{$rtree{$includer}}) {
		print_children_t($includer, 0, \@{$tree{$includer}});
	}
}
