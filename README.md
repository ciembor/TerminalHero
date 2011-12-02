# Terminal Hero
__Linux society's response to Microsoft's Guitar Hero. :)__

## Installation
This game is written in Perl language, so it depends on __perl__ interpreter.
It also needs some extra Perl __modules__:

* POE
* POE::Wheel::TermKey
* Term::ReadKey
* Term::TermKey
 
If you have problems with installation of Term::TermKey, make sure that __libtermkey__ is available in your operating system. If not - [Installing Term::TermKey returns error](http://stackoverflow.com/questions/8287071/installing-termtermkey-returns-error) should help you.

## Help

    Usage: terminalhero.perl [options]

    Options:
    -h, --help		   display this help

    Shortcuts:
    Ctrl+D or Esc		 exit

    Rules:
    Press keys with letters which are in the green area.
    Your score will increase if you do it well and decrease 
    if you press wrong key. You can also lose health points 
    and lifes if the letters turns red. 

    Levels:
    You will reach new levels every 64 points.
    Each level is a new line, so it is going harder.

Now go and play! :)
