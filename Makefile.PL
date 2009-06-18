use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Test::WWW::Mechanize::Driver',
  VERSION_FROM => 'lib/Test/WWW/Mechanize/Driver.pm',
  AUTHOR       => 'Dean Serenevy (dean@serenevy.net)',
  ABSTRACT     => 'Drive Test::WWW::Mechanize Object Using YAML Configuration Files',
  PREREQ_PM    => {  }, # e.g., Module::Name => 1.1
  MAKEFILE_OLD => ".Makefile.old",
  clean        => { FILES => "cover_db MANIFEST.bak" },
);

sub MY::postamble {
  return <<'MAKE_FRAG';
.PHONY: coverage
coverage: clean
	HARNESS_PERL_SWITCHES=-MDevel::Cover=-select,Driver,+ignore,Dean/Util prove -I lib t/*.t
	cover
MAKE_FRAG
}
