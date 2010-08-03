use 5.008006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Text::Extract::Stuff',
    VERSION_FROM => 'lib/Text/Extract/Stuff.pm',
    PREREQ_PM    => {
		HTML::SimpleLinkExtor => 1.22,
	    },
    ($] >= 5.005 ?
      (ABSTRACT  => 'lib/Text/Extract/Stuff.pm',
       AUTHOR    => 'Matteo Cantoni <matteo.cantoni@nothink.org>') : ()),
);
