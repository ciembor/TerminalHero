#!/usr/bin/perl

use Term::ReadKey;
use Term::TermKey qw( FORMAT_VIM KEYMOD_CTRL );
use POE qw(Wheel::TermKey);
use Time::HiRes qw(usleep nanosleep);
use IO::Handle qw( );
use POSIX;

########################################################################

@letters = ('a'..'z');
# game levels
@levels = ("n00b", "user", "root", "hacker", "God", "cheater");
# lines with letters to shoot
@lines = ();

$HEALTH = 32;

# state of the game
%game_stat = (
  "lifes" => 4,
  "health" => $HEALTH,
  "level" => 0,
  "score" => 0
);

# terminal width
($width) = GetTerminalSize();

# range of hit area
%hit_range = (
  "start" => floor(($width) / 4) - 5,
  "end" => floor(($width) / 4) + 5 
);

# states of letters with their colors
%sign_states = (
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
      
    got_key => sub {
      my $key     = $_[ARG0];
      my $termkey = $_[HEAP]{termkey};

      my $test = 0;
      for ($j=0; $j <= $game_stat{"level"}; $j++) {
        for ($i=$hit_range{"start"}; $i<$hit_range{"end"}; $i++) {
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
        
    clear => sub {
      # show cursor
      print(`tput cnorm`);
      # clear screen
      print(`tput ed`);
    },
    
    game_over => sub {
      # show cursor
      print(`tput cnorm`);
      # clear screen
      print(`tput ed`);
      print("\nGame over! You are a" . @levels[$game_stat{"level"}] . ". :)\n\n");
      exit(0);
    },
    
    win => sub {
      # show cursor
      print(`tput cnorm`);
      # clear screen
      print(`tput ed`);
      print("\nOMG... YOU WIN!\n
              You must be... the choosen one. O_O\n\n");
      exit(0);
    },
    
    next_level => sub {
      if ($game_stat{"level"} < 6) {
        # $game_stat{"lifes"} = 4;
        $game_stat{"health"} = $HEALTH;
        $_[KERNEL]->yield("next_life");
      }
      else {
        $_[KERNEL]->yield("win");
      }
    },
    
    next_life => sub {
      if ($game_stat{"lifes"} < 1) {
        $_[KERNEL]->yield("game_over");
      }
      else {
        $game_stat{"health"} = $HEALTH;
        # prepare an array with empty lines
        @lines = ();
        for ($j=0; $j <= $game_stat{"level"}; $j++) {
          for ($i=0; $i<$width; $i++) {
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
      
    play => sub {
      my $output = `tput setb 2`;
         $output .= `tput setf 7`;
         $output .= `tput bold`;
      
      # prepare bar with game state
      my $bar = "    level: " . @levels[$game_stat{"level"}] . "    |    ";
         $bar .= "lifes: " . $game_stat{"lifes"} . "    |    ";
         $bar .= "health: " . $game_stat{"health"} . "    |    ";
         $bar .= "score: " . $game_stat{"score"};
      
      # print 
      for (my $i=length($bar); $i<$width; $i++) {
        $bar .= " ";
      }
      
      $output .= $bar . "\n";
      $output .= `tput setb 0`;
      $output .= `tput sgr0`;

      # for each line with signs
      for ($j=0; $j<$game_stat{"level"}+1; $j++) {
        
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
          
          # print sign
          $output .= $sign_states{$lines[$j][$i]{"state"}};
          $output .= $lines[$j][$i]{"character"};

          ($width) = GetTerminalSize();
        }
        $output .= "\n";
      }
      
      print($output);

      for ($j=0; $j <= $game_stat{"level"} + 1; $j++) {
        print(`tput cuu1`);
      }
      
      # if he's dead
      if ($game_stat{"score"} >= 64 * ($game_stat{"level"} + 1)) {
        $game_stat{"level"}++;
        $_[KERNEL]->yield("next_level");
      }
      else {
        if ($game_stat{"health"} < 1) {
          $game_stat{"lifes"}--;
          $_[KERNEL]->yield("next_life");
        }
        else {
          # display next frame
          $_[KERNEL]->delay(play => 0.1);
        }
      }
    },
    
  }
);
 
########################################################################
 
POE::Kernel->run;
