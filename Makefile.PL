use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Test::WWW::Mechanize::Driver',
  VERSION_FROM => 'lib/Test/WWW/Mechanize/Driver.pm',
  AUTHOR       => 'Dean Serenevy (dean@serenevy.net)',
  ABSTRACT     => 'Drive Test::WWW::Mechanize Object Using YAML Configuration Files',
  PREREQ_PM    => {  }, # e.g., Module::Name => 1.1
);
