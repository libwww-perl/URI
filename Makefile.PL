require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   => 'URI',
    'VERSION_FROM' => 'URI.pm',
    'PREREQ_PM'    => {	
	                 'URI::Escape' => 0,
		      },
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
