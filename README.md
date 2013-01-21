# Terminal Hero
__Linux society's response to Microsoft's Guitar Hero. :)__

## Installation
This game is written in Perl language, so it depends on __perl__ interpreter.
It also needs __libtermkey__ and some extra Perl __modules__:

* Term::ReadKey
* Term::TermKey
* POE
* POE::Wheel::TermKey

If you don't know how to install Perl __modules__, look at [How to install CPAN modules](http://www.cpan.org/modules/INSTALL.html).
If you have problems with installation of __Term::TermKey__, make sure that __libtermkey__ is available in your operating system. If not - [Installing Term::TermKey returns error](http://stackoverflow.com/questions/8287071/installing-termtermkey-returns-error) should help you.

To install Terminal Hero type in your shell:

    perl Makefile.PL
    make
    make install

In ArchLinux you can use existing PKGBUILD for this game from AUR:

    yaourt -S terminalhero-git

The binary will be installed in:

    /usr/bin/vendor_perl

You might have to relogin or update your PATH variable by hand.

## Help

    Usage: terminalhero [options]

    Options:
    -e, --easy       turn on easy mode
    -h, --help       display this help

    Shortcuts:
    Ctrl+D or Esc    exit

    Rules:
    Press keys with letters which are in the green area.
    Your score will increase if you do it well and decrease 
    if you press wrong key. You can also lose health points 
    and lifes if the letters turns red. 

    Levels:
    You will reach new levels every 64 points.
    Each level is a new line, so it is going harder.

Now go and play! :)
