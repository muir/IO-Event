#!/usr/bin/perl -I.

use strict;

my $slowest = 4;
my $pause = 0;
my $debug = 0;

my $c = 1;
$| = 1;
my $testcount = 5;

use Carp qw(verbose);
use Sys::Hostname;

my $startingport = 1025;

my $hostname = hostname;
my $addr = join('.',unpack('C4',gethostbyname($hostname)));
print STDERR "host = $hostname addr = $addr.\n" if $debug;

package T;

use IO::Event;
use IO::Socket::INET;
use Carp;

BEGIN {
	eval { require Time::HiRes };
	if ($@) {
		print "1..0 $@";
		exit;
	}
}

# support routine
sub pickport
{
	for (my $i = 0; $i < 1000; $i++) {
		my $s = new IO::Socket::INET (
			Listen => 1,
			LocalPort => $startingport,
		);
		if ($s) {
			$s->close();
			return $startingport++;
		}
		$startingport++;
	}
	die "could not find an open port";
}

# support routine
sub okay
{
        my ($cond, $message) = @_;
        if ($cond) {
		$message =~ s/\n/\\n/g;
                print "ok $c # $message\n";
        } else {
		my($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require) = caller(0);
		print "not ok $c # $filename:$line $message\n";
        }
	if ($c > $testcount) {
		print STDERR "too many test results\n";
		exit(0);
	}
        $c++;
}

# default to oops
sub ie_input
{
	confess "we shoudn't be here";
}

print "1..$testcount\n";

# let's listen on a socket.  We'll expect to receive
# test numbers.  We'll print ok.

my $rp = T::pickport;
my $results = IO::Event::Socket::INET->new(
	Listen => 10,
	Proto => 'tcp',
	LocalPort => $rp,
	LocalAddr => $addr,
	Handler => 'ListenPrintOkay',
	Description => 'Listener',
);

die unless $results;
die unless $results->filehandle;

my $fh = $results->filehandle;
my $fn = $fh->fileno;

my $idle;
my $time = time;
my $waitingfor = $c;
my $ptime;

my (@tests) = (
	1 =>	sub {
			IO::Event::Socket::INET->new (
				Proto => 'tcp',
				PeerPort => $rp,
				PeerAddr => $addr,
				Handler => 'SendOne',
			) or T::okay(0, "create Sendone to $rp: $@");
		},
	1 =>	sub {
			my $rp = T::pickport;
			IO::Event::Socket::INET->new(
				Listen => 1,
				Proto => 'tcp',
				LocalPort => $rp,
				LocalAddr => $addr,
				Handler => 'ListenGetLine',
				Description => 'Listener2',
			) or T::okay(0, "create listener2 at $rp: $@");
			IO::Event::Socket::INET->new (
				Proto => 'tcp',
				PeerPort => $rp,
				PeerAddr => $addr,
				Handler => 'SendOne',
			) or T::okay(0, "create SendOne2 to $rp: $@");
		},
);

my $timer = IO::Event->timer (
	cb => \&runstuff,
	reentrant => 0,
	repeat => 1,
	interval => 1,
#	interval => 0.05,
);

okay($results, "start listening on results socket");

my $r = IO::Event::loop();
okay($r == 7, "loop finshed ($r)");

okay(1, "all done");
exit(0);

my $run1er;
sub runstuff
{
	if ($ptime) {
		return if (time < $ptime + $pause);
	} elsif ($c >= $waitingfor) {
		print STDERR "runstuff: time to start another test\n"
			if $debug;
		# T::okay(1, "runstuff happy");
		$ptime = time;
	} elsif (time - $time > $slowest) {
		print STDERR "runstuff: uh oh: test timed out\n"
			if $debug;
		# let's start the next test anyway...
		T::okay(0, "runstuff timetout");
		$ptime = time;
	} else {
		print STDERR "runstuff: idle\n"
			if $debug && (time > $idle);
		$idle = time;
		return;
	}
	unless (@tests) {
		print STDERR "runstuff: no more tests\n"
			if $debug;
		IO::Event::unloop_all(7);
		return;
	}
	return if $pause && (time < $ptime + $pause);
	undef $ptime;
	my ($count, $test) = splice(@tests, 0, 2);
	$waitingfor = $c + $count;
	$time = time;
	print STDERR "runstuff: starting another test ($c + $count)\n"
		if $debug;
	eval { &$test };
	T::okay(0, "test evaled: $@")
		if $@;
}

package SendOne;

sub ie_connected
{
	my ($self, $s1) = @_;
	$s1->print("$c\n");
}

sub ie_input
{
	my ($self, $s, $br) = @_;
	print $s->getlines();
}

package ListenPrintOkay;

sub ie_connection
{
	my ($self, $s) = @_;
	$s->accept('ReceivePrintOkay');
}

package ReceivePrintOkay;

sub ie_input
{
	my ($self, $s) = @_;
	my $l;
	while (defined ($l = $s->get)) {
		T::okay($l eq $c, "input '$l' != '$c' on results socket");
	}
}

package ListenGetLine;

sub ie_connection
{
	my ($self, $s) = @_;
	$s->accept('ReceiveGetLine');
}

package ReceiveGetLine;

sub ie_input
{
	my ($self, $s) = @_;
	my $l;
	while (defined ($l = $s->getline)) {
		T::okay($l eq "$c\n", "input '$l' != '$c' on results socket");
	}
}

1;
