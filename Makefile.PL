use strict;
use warnings;
use ExtUtils::MakeMaker;

my $MMVER = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
	NAME		=> 'sslmate',
	AUTHOR		=> 'SSLMate <sslmate@sslmate.com>',
	VERSION_FROM	=> 'bin/sslmate',
	ABSTRACT	=> 'Buy and manage SSL certificates from the command line',
	EXE_FILES	=> [qw(bin/sslmate)],
	PREREQ_PM => {
		'Getopt::Long'	=> 0,
	},
	LICENSE		=> 'restricted',
	dist		=> { COMPRESS => 'gzip -9nf', SUFFIX => 'gz', },
#	clean		=> { FILES => 'sslmate-*' },
);
