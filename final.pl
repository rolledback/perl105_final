#!/usr/bin/env perl
$| = 1;

my %actors;
my %movies;
my %valueCache;

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
print "\nDone, total of $numActors actors in $numMovies movies parsed in $totalTime seconds, at a rate of $rate actors/second.\n";

graphSeach("Chaplin, Charles"), "\n";

sub graphSeach {
   my $target = shift;
   my %visitedActors;
   my %visitedMovies;
   my @queue;
   my %actorPath;

   push(@queue, "Bacon, Kevin");
   $visitedActors{"Bacon, Kevin"} = 1;

   while(scalar @queue != 0) {
      $currentActor = pop(@queue);
      if($currentActor eq $target) {
         $parent = $actorPath{$currentActor};
         print "$target\n";
         while(defined $parent) {
            print "$parent\n";
            $parent = $actorPath{$parent};
         }
         return $currentActor;
      }
      else { 
         my $filmList = $actors{$currentActor};
         foreach my $film (keys %{$filmList}) {
            if(!exists $visitedMovies{$film}) {
               $actorList = $movies{$film};
               $visitedMovies{$film} = 1;
               foreach my $actor (keys %{$actorList}) {
                  if(!exists $visitedActors{$actor}) {
                     unshift(@queue, $actor);
                     $visitedActors{$actor} = 1;
                     $actorPath{$actor} = $currentActor;
                  }
               }
            }
         }
      }
   }
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
