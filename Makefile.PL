require 5.008001;
use ExtUtils::MakeMaker;

if ("foo" !~ /\Afoo\z/) {
    for $file ("URI", "URI/urn") {
	print "\\z not supported by this perl.  Fixing $file.pm...\n";
	rename("$file.pm", "$file.pm.bak") || die;
	open( IN, "<$file.pm.bak" ) || die;
	open( OUT, ">$file.pm" ) || die;
	while( <IN> ) {
	    $_ =~ s/\\z/\\Z/g;
	    print OUT;
	}
	close( OUT ) || die;
	close( IN ) || die;
    }
}

WriteMakefile(
    'NAME'	   => 'URI',
    'VERSION_FROM' => 'URI.pm',
    'ABSTRACT'     => 'Uniform Resource Identifiers (absolute and relative)',
    'AUTHOR'       => 'Gisle Aas <gisle@activestate.com>',
    'LICENSE'      => 'perl',
    'MIN_PERL_VERSION' => 5.008001,
    'PREREQ_PM'    => {	
	'MIME::Base64' => 2,
    },
    'META_MERGE' => {
        'recommends' => {
            'Business::ISBN' => 0,
        },
        'resources' => {
            'repository' => 'http://gitorious.org/projects/perl-uri',
            'MailingList' => 'mailto:libwww@perl.org',
        }
    },
    BUILD_REQUIRES => {
	'ExtUtils::MakeMaker' => 0,
	'Test' => 0,
	'Test::More' => 0,
    },
);


BEGIN {
    # compatibility with older versions of MakeMaker
    my $developer = -f ".gitignore";
    my %mm_req = (
        LICENCE => 6.31,
        META_MERGE => 6.45,
        META_ADD => 6.45,
        MIN_PERL_VERSION => 6.48,
    );
    undef(*WriteMakefile);
    *WriteMakefile = sub {
        my %arg = @_;
        for (keys %mm_req) {
            unless (eval { ExtUtils::MakeMaker->VERSION($mm_req{$_}) }) {
                warn "$_ $@" if $developer;
                delete $arg{$_};
            }
        }
        ExtUtils::MakeMaker::WriteMakefile(%arg);
    };
}
