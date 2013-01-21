require 5.000;

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile
  (
    NAME      => 'TerminalHero',
    ($[ >= 5.000) ?
    (AUTHOR   => 'Maciej Ciemborowicz (pub@ciemborowicz.pl)',
      ABSTRACT => 'Linux society\'s response to Activision\'s Guitar Hero. :)') : (),
    VERSION   => '1.0',
    PREREQ_PM => { 
                   'Term::ReadKey' => 0, 
                   'Term::TermKey' => 0,
                   'POE' => 0,
                   'POE::Wheel::TermKey' => 0
                 },
    EXE_FILES => [ 'terminalhero' ],
  );
  
