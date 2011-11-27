#!/usr/bin/perl

use Term::ReadKey;
use Time::HiRes qw(usleep nanosleep);
use IO::Handle qw( );
use POSIX;

STDOUT->autoflush(1);

($width) = GetTerminalSize();
die "You must have at least 10 characters" unless $width >= 40;

@letters = ('a'..'z');
@levels = ("n00b", "user", "root", "hacker", "God", "cheater");

%game_stat = (
  "lifes" => 4,
  "health" => 16,
  "level" => 0,
  "score" => 0
);

sub play_level {

  my $line_length = $width;
  
  $game_stat{"lifes"} = 4;
  my $lines_number = $_[0] + 1;
  
  # range of hit area
  %hit_range = (
    "start" => floor(($line_length) / 4) - 5,
    "end" => floor(($line_length) / 4) + 5 
  );
               
  # sign states with color ids
  %sign_states = (
    "normal" => `tput setf 7`,
    "shooted" => `tput setf 2`,
    "missed" => `tput setf 4`
  );

  while ($game_stat{"lifes"} > 0) {
    $game_stat{"health"} = 16;
    # prepare an array with empty lines
    @lines = ();

    for ($j=0; $j<$lines_number; $j++) {
      for ($i=0; $i<$line_length; $i++) {
        my %sign = (
          "character" => " ",
          "state" => "empty"
        );
        push @{ $lines[$j] }, \%sign;
      }
    }
    
    # life loop
    while ($game_stat{"health"} > 0) {
      my $output = `tput setb 2`;
      $output .= `tput setf 7`;
      $output .= `tput bold`;
      
      my $bar = "    level: " . @levels[$game_stat{"level"}] . "    |    ";
      $bar .= "lifes: " . $game_stat{"lifes"} . "    |    ";
      $bar .= "health: " . $game_stat{"health"} . "    |    ";
      $bar .= "score: " . $game_stat{"score"};
      
      for (my $i=length($bar); $i<$width; $i++) {
        $bar .= " ";
      }
      
      $output .= $bar . "\n";
      $output .= `tput setb 0`;
      $output .= `tput sgr0`;
      # for each line with signs
      for ($j=0; $j<$lines_number; $j++) {
        
        # remove first sign
        shift($lines[$j]);
        
        # generate new sign
        my %sign = (
          "character" => " ",
          "state" => "normal"
        );
        if (int(rand(10)) < 1) {
          $sign{"character"} = $letters[int rand @letters];
        }
        push($lines[$j], \%sign);
        
        # iterate over every sign in the line
        for ($i=0; $i<$width; $i++) {
          
          # check for missed signs
          if ($i < $hit_range{"start"} && ($lines[$j][$i]{"state"} eq "normal") && ($lines[$j][$i]{"character"} ne " ") ) {
            $game_stat{"health"}--;
            $lines[$j][$i]{"state"} = "missed";
          }
          
          # set hit area colors
          if ($i eq $hit_range{"start"}) {
            # green background
            $output .= `tput setb 2`;
            # bold font
            $output .= `tput bold`;
          }
          
          # set standard area colors 
          if ($i eq $hit_range{"end"}) {
            # black background
            $output .= `tput setb 0`;
            # standard text
            $output .= `tput sgr0`;
          }
          
          # print sign
          $output .= $sign_states{$lines[$j][$i]{"state"}};
          $output .= $lines[$j][$i]{"character"};

          ($width) = GetTerminalSize();
        }
        $output .= "\n";
      }
      
      print($output);

      for ($j=0; $j<$lines_number + 1; $j++) {
        print(`tput cuu1`);
      }
      
      usleep(50000);
      
    }
    $game_stat{"lifes"}--;
  }
}

# hide cursor
print(`tput civis`);

for (my $i=0; $i<length(@levels); $i++) {
  play_level($i);
}
