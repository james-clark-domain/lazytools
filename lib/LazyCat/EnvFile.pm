package LazyCat::EnvFile;

use warnings;
use strict;
use v5.16;
use Exporter 'import';
use File::Find;
require File::Basename;

use Try::Tiny;
use File::Slurp;


sub new
{
  my ($class, $filename) = @_;
  my $self = bless {
    filename => $filename,
    lines => [],
  }, $class;
  $self->slurp($filename);
  return $self;
}


sub filename
{
  my ($self) = @_;
  return $self->{filename};
}


sub basename
{
  my ($self) = @_;
  return File::Basename::basename $self->{filename};
}


sub lines
{
  my ($self) = @_;
  $self->{lines};
}


sub keys
{
  my ($self, $coderef) = @_;
  return map { $_->{key} } $self->keyvals($coderef);
}


sub keyvals
{
  my ($self, $given_coderef) = @_;
  my $coderef = $given_coderef // sub { 1 };
  $coderef = sub { shift->{key} eq "$given_coderef" } if ref $coderef ne 'CODE';
  my @results = grep { defined $_->{key} && $coderef->($_) } @{$self->{lines}};
  return @results;
}


sub slurp
{
  my ($self, $filename) = @_;
  my @lines = map { _loadline($_) } read_file($filename, binmode => ':raw', err_mode => 'croak');
  $self->{lines} = \@lines;
}


sub _loadline
{
  my ($line) = @_;
  chomp $line;
  my $ref = { raw => $line };
  $ref->{comment} = 1 if $line =~ /^(#.*|\s*)$/;
  if ($line =~ /^#?(\w+?)=(.*)$/) {
    $ref->{key} = $1;
    $ref->{val} = $2;
  }
  return $ref;
}


1;
