# Terminal Hero
__Linux society's response to Guitar Hero. :)__

## Demo
https://vimeo.com/44892910

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

### Homebrew

On macOS you can install Terminal Hero with Homebrew:

    brew tap ciembor/terminalhero https://github.com/ciembor/TerminalHero.git
    brew install terminalhero

The formula uses a pinned GitHub revision and vendors the required CPAN modules inside the Homebrew keg.

For local formula testing from this checkout:

    brew tap ciembor/terminalhero "$PWD"
    brew install --build-from-source ciembor/terminalhero/terminalhero
    brew test ciembor/terminalhero/terminalhero

### APT

On Debian/Ubuntu systems you can install Terminal Hero from the APT repository:

    curl -fsSL https://maciej-ciemborowicz.eu/apt/terminalhero/terminalhero-archive-keyring.gpg | sudo tee /usr/share/keyrings/terminalhero-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/terminalhero-archive-keyring.gpg] https://maciej-ciemborowicz.eu/apt/terminalhero ./" | sudo tee /etc/apt/sources.list.d/terminalhero.list
    sudo apt-get update
    sudo apt-get install terminalhero

The package depends on Ubuntu/Debian Perl packages where they are available and vendors `POE::Wheel::TermKey`, which is not packaged in Ubuntu 24.04.

To build the Debian package and a static APT repository:

    packaging/debian/build-deb
    packaging/apt/build-repo

To publish the generated APT repository to `maciej-ciemborowicz.eu`:

    TERMINALHERO_APT_SIGNING_KEY=<gpg-key-id> packaging/apt/build-repo
    packaging/apt/deploy-server

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
