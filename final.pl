#!/usr/bin/env perl

use Data::Dumper;

@lines = `zcat $ARGV[$_]`;

%actors;
$movies;
foreach (@lines) {
   chomp();
   #print "$_\n";
   if($_ =~ /([\w\d \S]*)(\t+)(.+)(\([\d]+(\/[IXV]+)*\))(.*)/) {   
      if($1) { $actor = $1; }
      if(index($6, "(TV)") == -1 && index($6, "(VG)") == -1 && index($6, "(V)") == -1) {
         $name = "$3$4";
         if($name !~ /".+"/) {
            #print "Actor: $actor\nMovie Name: $name $year\n\n";
            push(@{$actors{$actor}}, $name + " " + $year);
            push(@{$movies{$name}}, $actor);
         }
      }
   }
   #<STDIN>;
   #$l++;
}

#print Dumper \%actors;
print Dumper \%movies;

