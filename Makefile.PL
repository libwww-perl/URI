use strict;
use warnings FATAL => 'all';
require 5.008001;
use ExtUtils::MakeMaker;

my $developer = -f '.gitignore';
ExtUtils::MakeMaker->VERSION(6.98) if $developer;

my %WriteMakefileArgs = (
    NAME                => 'URI',
    VERSION_FROM        => 'URI.pm',
    ABSTRACT_FROM       => 'URI.pm',
    AUTHOR              => 'Gisle Aas <gisle@activestate.com>',
    LICENSE             => 'perl',

    META_MERGE => {
        'meta-spec' => { version => 2 },
        dynamic_config => 0,
        resources => {
            repository => {
                url => 'https://github.com/libwww-perl/uri.git',
                web => 'https://github.com/libwww-perl/uri',
                type => 'git',
            },
            bugtracker => {
                mailto => 'bug-URI@rt.cpan.org',
                web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=URI',
            },
            x_MailingList => 'mailto:libwww@perl.org',
        },
    },

    META_ADD => {
        prereqs => {
            configure => {
                requires => {
                    'ExtUtils::MakeMaker' => '0',
                },
            },
            runtime => {
                requires => {
                    'MIME::Base64'  => '2',
                    'parent'        => '0',
                    'Exporter'      => '5.57',
                    'utf8'          => '0',
                    'perl'          => '5.008001',
                },
                recommends => {
                    'Business::ISBN' => '0',
                },
            },
            test => {
                requires => {
                    'Test' => '0',
                    'Test::More' => '0.96',
                    'File::Temp' => '0',
                },
            },
        },
    },
);

my $eumm_version  = eval $ExtUtils::MakeMaker::VERSION;

for (qw(configure build test runtime)) {
    my $key = $_ eq 'runtime' ? 'PREREQ_PM' : uc $_.'_REQUIRES';
    next unless exists $WriteMakefileArgs{META_ADD}{prereqs}{$_}
             or exists $WriteMakefileArgs{$key};
    my $r = $WriteMakefileArgs{$key} = {
        %{$WriteMakefileArgs{META_ADD}{prereqs}{$_}{requires} || {}},
        %{delete $WriteMakefileArgs{$key} || {}},
    };
    defined $r->{$_} or delete $r->{$_} for keys %$r;
}

# dynamic prereqs get added here.

$WriteMakefileArgs{MIN_PERL_VERSION} = delete $WriteMakefileArgs{PREREQ_PM}{perl} || 0;

$WriteMakefileArgs{BUILD_REQUIRES} = {
    %{$WriteMakefileArgs{BUILD_REQUIRES} || {}},
    %{delete $WriteMakefileArgs{TEST_REQUIRES}}
} if $eumm_version < 6.63_03;

$WriteMakefileArgs{PREREQ_PM} = {
    %{$WriteMakefileArgs{PREREQ_PM}},
    %{delete $WriteMakefileArgs{BUILD_REQUIRES}}
} if $eumm_version < 6.55_01;

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    if $eumm_version < 6.51_03;

delete $WriteMakefileArgs{MIN_PERL_VERSION}
    if $eumm_version < 6.48;

delete @WriteMakefileArgs{qw(META_ADD META_MERGE)}
    if $eumm_version < 6.46;

delete $WriteMakefileArgs{LICENSE}
    if $eumm_version < 6.31;

WriteMakefile(%WriteMakefileArgs);
