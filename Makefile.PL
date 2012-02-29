
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile being created.
WriteMakefile(
	'NAME'		=> 'IO::Event',
	'DISTNAME'	=> 'IO-Event',
	'VERSION_FROM'	=> 'lib/IO/Event.pm',
	'EXE_FILES'	=> ['rinetd.pl'],
	($] >= 5.005 ?
	    ('ABSTRACT' => 'Tied Filehandles for Nonblocking IO with Object Callbacks',
	     'AUTHOR'	=> 'David Muir Sharnoff <muir@idiom.com>') : ()),
	'dist'		=> {COMPRESS=>'gzip', SUFFIX=>'gz'},
	'PREREQ_PM'	=> {
		'IO::Handle' => 0,
		'Time::HiRes' => 0,
		'Test::Simple' => 0,

		'Getopt::Long' => 0,
		'File::Slurp' => 0,
		'File::Flock' => 0,
		'Net::Netmask' => 0,
		'Daemon::Generic' => 0,
		'List::MoreUtils' => 0,
	},
	'BUILD_REQUIRES' => {
		'Event' => 0,
		'AnyEvent' => 0,
		'diagnostics' => 0,
	}
);

package MY;

sub postamble {
    <<"END_OF_POSTAMBLE";

pm_to_blib: README

README: lib/IO/Event.pod
\tpod2text lib/IO/Event.pod >README

END_OF_POSTAMBLE
}
