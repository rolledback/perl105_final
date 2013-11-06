#!/usr/bin/env perl

use Data::Dumper;
use strict;
$| = 1;

my %actors;
my %movies;

my %cache;
my @queue;
my %path;
my %films;
my %visitedActors;
my %visitedMovies;

my $totalTime;
my $actor;
my $line = 0;
my $oldPercent = -1;
my $curPercent = 0;

my @lines;
foreach my $arg (@ARGV) {
   push(@lines, `zcat $arg`);
}

print "Parsing files...\n";
my $startTime = time();
my $totalLines = scalar @lines;

foreach (@lines) {
   $line++;
   $curPercent = int($line / $totalLines * 100);
   if($curPercent != $oldPercent) {
      $oldPercent = $curPercent;
      $totalTime = (time() - $startTime);
      percentagePrint($totalTime, $curPercent);
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

my $numActors = keys %actors; 
my $numMovies = keys %movies;
my $rate = int($numActors / $totalTime);
#print "\nDone, total of $numActors actors in $numMovies movies parsed in $totalTime seconds, at a rate of $rate actors/second.\n\n";

foreach $actor (keys %actors) {
   graphSearch($actor, 0);
}

print "\nActor/Actress? ";
while(<STDIN>) {
   chomp;
   takeInput($_); 
   print "Actor/Actress? ";  
}

sub takeInput() {
   my $name = shift;
   if (!$name) { die };
   if(exists $actors{$name}) {
      graphSearch($name, 1), "\n";
   }
   else {
      my $match = 1;
      my @keywords = split(' ', $name);
      my @matches;
      foreach my $actor (keys %actors) {
         foreach my $keyword (@keywords) {
            $keyword = lc $keyword;
            if(lc $actor !~ /\b$keyword,?\b/i) {
               $match = 0;
               last;
            }
         }
         if($match == 1) { push(@matches, $actor); }
         $match  = 1;
      }
      if(scalar @matches == 0) { print "No matches found.\n"; }
      elsif(scalar @matches == 1) { graphSearch($matches[0], 1), "\n"; }
      else { 
         print "Did you mean:\n"; 
         foreach $match (@matches) { print "$match\n"; }
      }
   }     
}

sub mapPrint {
   my $initial = shift;
   my $p = shift;
   my $baconNum = -1;
   while(defined $initial) {
      if($p == 1) { print "$initial\n"; }
      if(exists $films{$initial}{$path{$initial}}) {
         if($p == 1) { print "\t$films{$initial}{$path{$initial}}\n"; }
      }
      $initial = $path{$initial};
      $baconNum++;
   }
   return $baconNum
}

sub graphSearch {
   my $target = shift;   
   my $currentActor;
   my $p = shift;

   if(exists $cache{$target}) { return mapPrint($target, $p); }
   
   push(@queue, "Bacon, Kevin");
   $visitedActors{"Bacon, Kevin"} = 1;

   while(scalar @queue != 0) {
      $currentActor = pop(@queue);
      if($currentActor eq $target) { return mapPrint($currentActor, $p); }
      else { 
         my $filmList = $actors{$currentActor};
         foreach my $film (keys %{$filmList}) {
            if(!exists $visitedMovies{$film}) {
               my $actorList = $movies{$film};
               $visitedMovies{$film} = 1;
               foreach my $actor (keys %{$actorList}) {
                  if(!exists $visitedActors{$actor}) {
                     unshift(@queue, $actor);
                     $cache{$actor} = 1;
                     $visitedActors{$actor} = 1;
                     $path{$actor} = $currentActor;
                     $films{$actor}{$currentActor} = $film;
                  }
               }
            }
         }
      }
   }
   if($p == 1) { print "No connection found.\n"; }
   return -1;
}

sub percentagePrint {
   my $time = shift;
   my $percent = shift;
   my $truePercent = $percent;
   if($percent > 50 && $percent < 80) { $percent = 100 - $percent; }
   print "\r[";
   if($percent != 1) { for (0..(($percent / 2) - 1)) { print "*"; } }
   for (($percent / 2)..49) { print "-"; }
   print "]";
   if($truePercent > 70 && $truePercent < 80) { print " Just kidding!    "; }   
   else { print " $percent% ($time seconds)   "; }
}
