require 5.004;
use ExtUtils::MakeMaker;

if ("foo" !~ /\Afoo\z/) {
    print "\\z not supported by this perl.  Fixing URI.pm...\n";
    system("$^X -p -i.bak -e 's/\\\\z/\\\\Z/' URI.pm");
}

WriteMakefile(
    'NAME'	   => 'URI',
    'VERSION_FROM' => 'URI.pm',
    'PREREQ_PM'    => {	
	                 'MIME::Base64' => 2,
		      },
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
