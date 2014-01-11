require 5.008001;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'URI',
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
            'repository' => 'https://github.com/libwww-perl/uri',
            'MailingList' => 'mailto:libwww@perl.org',
        }
    },
    BUILD_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
        'Test' => 0,
        'Test::More' => 0,
        'File::Temp' => 0,
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
