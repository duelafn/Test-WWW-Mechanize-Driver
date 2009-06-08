use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Test::WWW::Mechanize::Driver',
  VERSION_FROM => 'lib/Test/WWW/Mechanize/Driver.pm',
  AUTHOR       => 'Dean Serenevy (dean@serenevy.net)',
  ABSTRACT     => 'Drive Test::WWW::Mechanize Object Using YAML Configuration Files',
  PREREQ_PM    => {  }, # e.g., Module::Name => 1.1
  MAKEFILE_OLD => ".Makefile.old",
  clean        => { FILES => "cover_db" },
);

sub MY::postamble {
  return <<'MAKE_FRAG';
.PHONY: coverage
coverage:
	cover -delete
	HARNESS_PERL_SWITCHES=-MDevel::Cover=-select,Test::WWW::Mechanize make test
	cover
MAKE_FRAG
}
