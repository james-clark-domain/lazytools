package LazyCat::PrettyColours;

use warnings;
use strict;
use v5.16;
use Exporter 'import';
use Term::ANSIColor;

our @EXPORT_OK = qw/note notepart notekv banner/;
our %EXPORT_TAGS = ( all => [@EXPORT_OK] );


sub _coloured
{
  my ($text, $colour) = @_;
  return $text unless -t STDERR;
  return colored($text, $colour);
}


sub note
{
  my ($text, $colour) = @_;
  $colour //= 'cyan';
  say STDERR _coloured($text, $colour);
}


sub notepart
{
  my ($text, $colour) = @_;
  $colour //= 'cyan';
  print STDERR _coloured($text, $colour);
}


sub notekv
{
  my ($key, $value, $colour) = @_;
  $colour //= 'cyan';
  say STDERR _coloured("$key: ", "bold $colour") . _coloured($value, $colour);
}


sub banner
{
  my ($text, $colour) = @_;
  $colour //= 'bold yellow';
  say STDERR "";
  say STDERR _coloured("=" x (length($text)+2), $colour);
  say STDERR _coloured(" $text ", $colour);
  say STDERR _coloured("=" x (length($text)+2), $colour);
}


1;
