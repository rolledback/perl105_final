#!/usr/bin/env perl

use Data::Dumper;
use POSIX 'ceil';

%actors;
$movies;
$totalActors = 123524;
$startTime = time();

print "\nProgress:\n";

foreach $arg (@ARGV) {
   @lines = `zcat $arg`;
   $percent = 0;
   foreach (@lines) {
      chomp();
      if($_ =~ /([\w\d \S]*)(\t+)(.+)(\([\d]+(\/[IXV]+)*\))(.*)/) {   
         if($1) { 
            $actor = $1;
            $numDone = keys %actors;
            if($numDone % 15 == 0) {
               $runTime = time() - $startTime;
               $percent = ceil(($numDone / $totalActors) * 10);
               print "\r";
               for $i (0..($percent / 2)) { print "*"; }
               print " $percent% ($runTime seconds)";       
            }
         }
         if(index($6, "(TV)") == -1 && index($6, "(VG)") == -1 && index($6, "(V)") == -1) {
            $name = "$3$4";
            if($name !~ /".+"/) {
               push(@{$actors{$actor}}, $name);
               push(@{$movies{$name}}, $actor);
            }
         }
      }
   }
}
print "\n";

$numActors = keys %actors;
$numMovies = keys %movies;
$rate = ceil($numActors / $runTime);
print "\nA total of $numActors actors in $numMovies movies parsed in $runTime seconds, at a rate of $rate actors/second.\n";
 
#print Dumper \%actors;
#print Dumper \%movies;clear
