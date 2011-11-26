#!/usr/bin/perl

use Term::ReadKey;
use Time::HiRes qw(usleep nanosleep);
use IO::Handle qw( );

STDOUT->autoflush(1);

($width) = GetTerminalSize();
die "You must have at least 10 characters" unless $width >= 10;

@letters = ('a'..'z');
$lines_number = 3;
$line_length = $width;
%hit_range = ("start", ($line_length)/4 - 5,
              "end", ($line_length)/4 +5 );
# prepare an array with empty lines
@lines = ();

for ($j=0; $j<$lines_number; $j++) {
  for ($i=0; $i<$line_length; $i++) {
    push @{ $lines[$j] }, " ";
  }
}

# hide cursor
print(`tput civis`);
print(`tput setb 0`);

do {
  
  for ($j=0; $j<$lines_number; $j++) {
    shift($lines[$j]);
    if (int(rand(10)) < 1) {
      push($lines[$j], $letters[int rand @letters]);
    }
    else {
      push($lines[$j], " ");
    }
    for ($i=0; $i<$width; $i++) {
      if ($i == $hit_range{"start"}) {
        print(`tput setb 2`);
        print(`tput bold`);
      }
      if ($i == $hit_range{"end"}) {
        print(`tput setb 0`);
        print(`tput sgr0`);
      }
      print $lines[$j][$i];
      ($width) = GetTerminalSize();
    }
    print("\n");
  }

  for ($j=0; $j<$lines_number; $j++) {
    print(`tput cuu1`);
  }
  
  usleep(70000);
} while (1)


