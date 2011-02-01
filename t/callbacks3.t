#!/usr/bin/perl -I.

eval { require AnyEvent::Impl::Perl; require AnyEvent; };
if ($@) {
	print "1..0 # Skip AnyEvent not installed\n";
	exit 0;
}
use IO::Event 'AnyEvent';
use FindBin;
require "$FindBin::Bin/callbacks.tt";

