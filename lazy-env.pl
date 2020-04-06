#!/usr/bin/env -S perl -CSDA

use strict;
use warnings;
use utf8;
use v5.16;
use warnings FATAL => 'all';
binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';

use FindBin qw/$RealBin/;
use lib "$RealBin/lib";

use Term::ANSIColor;
use Getopt::Long qw/:config pass_through/;
use Try::Tiny;
use List::MoreUtils qw/uniq/;

use LazyCat::PrettyColours qw/note notepart notekv/;
use LazyCat::EnvFile;

use Data::Dumper;


my %OPTS = (
  filename => '.env',
);
GetOptions(\%OPTS, qw/filename=s help!/);


sub help
{
  my ($err) = @_;
  note $err, 'bold red' if $err;
  say STDERR <<EOF;
Usage: $0 <'diff' is the only command right now> .envfile1 .envfile2
  ...
EOF
exit 1;
}


sub main
{
  my ($verb, @terms) = @_;
  $verb //= 'help';
  do_diff(@_) if $verb eq 'diff';
  help("Select a command: diff, diff, or diff.");
}


sub do_diff
{
  my ($verb, @terms) = @_;
  help("Please specify exactly two files to diff.") unless @terms == 2;
  
  my $env1 = LazyCat::EnvFile->new(shift @terms);
  my $env2 = LazyCat::EnvFile->new(shift @terms);
  
  note "--- " . $env1->basename(), 'bold reset';
  note "+++ " . $env2->basename(), 'bold reset';
  my @keys = uniq sort $env1->keys(), $env2->keys();
  
  foreach my $key (@keys) {
    my @kv1 = $env1->keyvals($key);
    my @kv2 = $env2->keyvals($key);
    
    if (@kv1 == 1 && @kv2 == 1) {
      # Happy path, exactly one of each key in each file.
      next if $kv1[0]->{val} eq $kv2[0]->{val};
      say colourise_keyval($kv1[0], '-');
      say colourise_keyval($kv2[0], '+');
      
    } elsif (@kv1 > 0 && @kv2 == 0) {
      # All keys with this name were deleted.
      say colourise_keyval($_, '-') foreach @kv1;

    } elsif (@kv1 == 0 && @kv2 > 0) {
      # All keys with this name were added.
      say colourise_keyval($_, '+') foreach @kv2;

    } elsif (@kv1 == 0 && @kv2 == 0) {
      die "What?!";

    } else {
      # It's a messy mix. (YES ALL THESE PATHS ARE EQUIVALENT RIGHT NOW BUT WE MIGHT GET CLEVER LATER)
      # Remove everything that appears in @kv1 from @kv2:
      my @filtered_kv2 = grep { ! appears_in($_, @kv1) } @kv2;
      # Remove everything that appears in @kv2 from @kv1:
      my @filtered_kv1 = grep { ! appears_in($_, @kv2) } @kv1;

      say colourise_keyval($_, '-') foreach @filtered_kv1;
      say colourise_keyval($_, '+') foreach @filtered_kv2;
    }
  }
  exit 0;
}


sub colourise_keyval
{
  my ($kv, $addremove) = @_;
  my $addremove_colour = $addremove eq '+' ? 'green' : 'red';
  my $s = colored($addremove, "bold $addremove_colour");
  $addremove_colour = 'white' if $kv->{comment};
  my $line = $kv->{raw};
  $line =~ s/(\p{Control})/color('reset') . colored(sprintf("<%X>", ord($1)), "on_$addremove_colour") . color($addremove_colour)/eg;
  $s .= colored($line, $addremove_colour);
}


sub appears_in
{
  my ($kv, @kvlist) = @_;
  return grep { $_->{raw} eq $kv->{raw} } @kvlist;
}


help() if $OPTS{help};
main(@ARGV);

