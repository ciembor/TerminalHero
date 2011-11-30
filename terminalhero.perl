#!/usr/bin/perl

use strict;
use warnings;

use Term::ReadKey;
use Term::TermKey;
use POE;
use POE::Wheel::TermKey;
use IO::Handle;
use POSIX;

########################################################################

# display help
if ($#ARGV >= 0) {
  
  if ($#ARGV > 1) {
    print "To many options. \n"
  }
  else {
    if (($ARGV[0] ne "--help") and ($ARGV[0] ne "-h")) {
      print "Unknown argument " . $ARGV[0] . ".\n";
    }
  }
  
  print "\nTerminal Hero\n";
  print "Linux society's response to Microsoft's Guitar Hero. :)\n\n";
  print "Usage: terminalhero.perl [options]\n\n";
  print "Options:\n";
  print "-h, --help\tdisplay this help\n\n";
  print "Rules:\n";
  print "Press keys with letters which are in the green area.\n";
  print "Your score will increase if you do it well and decrease \n";
  print "if you press wrong key. You can also lose health points \n";
  print "and lifes if the letters turns red. \n\n";
  print "Levels:\n";
  print "You will reach new levels every 64 points.\n";
  print "Each level is a new line, so it is going harder.\n\n";
  print "Now go and play! :)\n\n";
  
  exit;
}

########################################################################

my @letters = ('a'..'z');
# game levels
my @levels = ("n00b", "user", "root", "hacker", "God", "cheater");
# lines with letters to shoot
my @lines = ();

my $HEALTH = 32;

# state of the game
my %game_stat = (
  "lifes" => 4,
  "health" => $HEALTH,
  "level" => 0,
  "score" => 0
);

# terminal width
my ($width) = GetTerminalSize();

# range of hit area
my %hit_range = (
  "start" => floor(($width) / 4) - 5,
  "end" => floor(($width) / 4) + 5 
);

# states of letters with their colors
my %sign_states = (
  "normal" => `tput setf 7`,
  "shooted" => `tput setf 2`,
  "missed" => `tput setf 4`
);

########################################################################

POE::Session->create(
  inline_states => {
     
    _start => sub {
         
      STDOUT->autoflush(1);
      # hide cursor
      print(`tput civis`);
      
      $_[KERNEL]->yield("next_life");
      
      $_[HEAP]{termkey} = POE::Wheel::TermKey->new(
        InputEvent => 'got_key',
      );
      
    },
    
    # user pressed a key, he want to hit a letter ######################
    got_key => sub {
      my $key     = $_[ARG0];
      my $termkey = $_[HEAP]{termkey};

      my $test = 0;
      for (my $j=0; $j <= $game_stat{"level"}; $j++) {
        for (my $i=$hit_range{"start"}; $i<$hit_range{"end"}; $i++) {
          if ( $lines[$j][$i]{"character"} eq $termkey->format_key( $key, FORMAT_VIM ) ) {
            if ("normal" eq $lines[$j][$i]{"state"}) {
              $game_stat{"score"}++;
            }
            $lines[$j][$i]{"state"} = "shooted";
            $test = 1;
          }
        }
      }
      
      if ($test == 0
          && $game_stat{"score"} > 64 * ($game_stat{"level"})) {
        $game_stat{"score"}--;
      }
 
      # Gotta exit somehow.
      delete $_[HEAP]{termkey} if $key->type_is_unicode and
                                   $key->utf8 eq "C" and
                                   $key->modifiers & KEYMOD_CTRL;
      },
    
    # game over, clear the screen and write a message ##################
    game_over => sub {
      print(`tput sgr0`);
      # show cursor
      print(`tput cnorm`);
      # clear screen
      print(`tput ed`);
      print("\nGame over! You are a " . @levels[$game_stat{"level"}] . ". ;)\n\n");
      exit(0);
    },
    
    # win, clear the screen and write a message ########################
    win => sub {
      print(`tput sgr0`);
      # show cursor
      print(`tput cnorm`);
      # clear screen
      print(`tput ed`);
      print("\nOMG... YOU WIN! You must be... the choosen one. O_O\n\n");
      exit(0);
    },
    
    # let's start a new level ##########################################
    next_level => sub {
      if ($game_stat{"level"} < scalar(@levels)) {
        # $game_stat{"lifes"} = 4;
        $game_stat{"health"} = $HEALTH;
        $_[KERNEL]->yield("next_life");
      }
      else {
        $_[KERNEL]->yield("win");
      }
    },
    
    # let's start a new life, with new letters #########################
    next_life => sub {
      if ($game_stat{"lifes"} < 1) {
        $_[KERNEL]->yield("game_over");
      }
      else {
        $game_stat{"health"} = $HEALTH;
        # prepare an array with empty lines
        @lines = ();
        for (my $j=0; $j <= $game_stat{"level"}; $j++) {
          for (my $i=0; $i<$width; $i++) {
            my %sign = (
              "character" => " ",
              "state" => "empty"
            );
            push @{ $lines[$j] }, \%sign;
          }
        }
        $_[KERNEL]->yield("play");
      }
    },
    
    # this is the main loop (recursion) ################################
    play => sub {
      my $output = `tput setb 7`;
         $output .= `tput setf 0`;
      
      # prepare bar with th game's state
      my $bar = "    whoami: " . @levels[$game_stat{"level"}] . "    |    ";
         $bar .= "lifes: " . $game_stat{"lifes"} . "    |    ";
         $bar .= "health: " . $game_stat{"health"} . "    |    ";
         $bar .= "score: " . $game_stat{"score"};
      
      # print rest of a bar
      for (my $i=length($bar); $i<$width; $i++) {
        $bar .= " ";
      }
      
      $output .= $bar . "\n";
      $output .= `tput setb 0`;
      $output .= `tput sgr0`;

      # for each line with signs
      for (my $j=0; $j<$game_stat{"level"}+1; $j++) {
        
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
        for (my $i=0; $i<$width; $i++) {
          
          # check for missed signs
          if ($i < $hit_range{"start"} 
              && ($lines[$j][$i]{"state"} eq "normal") 
              && ($lines[$j][$i]{"character"} ne " ") ) {
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
          
          # print color escape code
          if ($sign_states{$lines[$j][$i]{"state"}}) {
            $output .= $sign_states{$lines[$j][$i]{"state"}};
          }
          # print the letter
          $output .= $lines[$j][$i]{"character"};

          ($width) = GetTerminalSize();
        }
        $output .= "\n";
      }
      
      # print the frame
      print($output);

      # go up to reprint lines
      for (my $j=0; $j <= $game_stat{"level"} + 1; $j++) {
        print(`tput cuu1`);
      }
      
      # if he's good enought;)
      if ($game_stat{"score"} >= 64 * ($game_stat{"level"} + 1)) {
        $game_stat{"level"}++;
        $_[KERNEL]->yield("next_level");
      }
      else {
        # if he's dead
        if ($game_stat{"health"} < 1) {
          $game_stat{"lifes"}--;
          $_[KERNEL]->yield("next_life");
        }
        else {
          # display next frame
          $_[KERNEL]->delay(play => 0.05);
        }
      }
    },
    
  }
);
 
########################################################################
 
POE::Kernel->run;
