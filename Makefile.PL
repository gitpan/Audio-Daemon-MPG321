use 5.008004;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Audio::Daemon::MPG321',
    VERSION_FROM      => 'lib/Audio/Daemon/MPG321.pm',
    PREREQ_PM         => {Audio::Play::MPG321 => 0.003},
    ($] >= 5.005 ?
      (ABSTRACT  => "Audio::Daemon::MPG321",
       AUTHOR         => 'Da-Breegster <scarlino@bellsouth.net>') : ()),
);
