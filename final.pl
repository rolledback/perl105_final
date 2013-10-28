#!/usr/bin/env perl

use Data::Dumper;
use POSIX 'ceil';

sub percentagePrint {
   $time = shift;
   $percent = shift;
   $truePercent = $percent;
   if($percent > 47 && $percent < 80) { $percent = 100 - $percent; }
   print "\r[";
   for $i (0..(($percent / 2) - 1)) { print "*"; }
   for $i (($percent / 2)..49) { print "-"; }
   print "]";
   if($truePercent > 70 && $truePercent < 80) { print " Just kidding!     "; }   
   else { print " $percent% ($time seconds)   "; }
}

my %actors;
my $movies;
my $totalTime;
my $actor;


foreach $arg (@ARGV) {
   print "Opening $arg...\n";
   my @lines = `zcat $arg`;
   my $startTime = time();
   print "Done.\nParsing $arg...\n";
   $totalLines = scalar @lines;
   my $line = 0;
   foreach (@lines) {
      if(++$line % 600 == 0) {
         percentagePrint(time() - $startTime, ceil($line / $totalLines * 100));
      }
      chomp();
      if($_ =~ /^(.*?)\t+(.+?\([\d]+(\/[IXV]*)*\))(.*)/) {  
         (my $gActor, my $gMovie, my $gRoman, my $gExtra) = ($1, $2, $3, $4);
         if($gActor !~ /^\s*$/) {
            $actor = $gActor;      
         }
         if(index($gExtra, "(TV)") == -1 && index($gExtra, "(VG)") == -1 && index($gExtra, "(V)") == -1 && index($gExtra, "(archive footage)") == -1) {
            if(index($gMovie, "\"") != 0) {
               $actors{$actor}{$gMovie} = 0;
               $movies{$gMovie}{$actor} = 0;
            }
         }
      }
   }
   $totalTime += (time() - $startTime);
   print "\nDone.\n";
}

$numActors = keys %actors; 
$numMovies = keys %movies;
$rate = ceil($numActors / $totalTime);
print "\nA total of $numActors actors in $numMovies movies parsed in $totalTime seconds, at a rate of $rate actors/second.\n";

#print Dumper \%actors;
#print Dumper \%movies;
