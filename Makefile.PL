require 5.004;
use ExtUtils::MakeMaker;

if ("foo" !~ /\Afoo\z/) {
    print "\\z not supported by this perl.  Fixing URI.pm...\n";
    rename( 'URI.pm', 'URI.pm.bak' ) || die;
    open( IN, '<URI.pm.bak' ) || die;
    open( OUT, '>URI.pm' ) || die;
    while( <IN> ) {
        $_ =~ s/\\z/\\Z/g;
        print OUT;
    }
    close( OUT );
    close( IN );
}

WriteMakefile(
    'NAME'	   => 'URI',
    'VERSION_FROM' => 'URI.pm',
    'PREREQ_PM'    => {	
	                 'MIME::Base64' => 2,
		      },
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
