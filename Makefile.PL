use strict;
use warnings;
use ExtUtils::MakeMaker;

my $developer = -f '.gitignore';
ExtUtils::MakeMaker->VERSION(6.98) if $developer;

my %WriteMakefileArgs = (
    NAME                => 'URI',
    VERSION_FROM        => 'lib/URI.pm',
    ABSTRACT_FROM       => 'lib/URI.pm',
    AUTHOR              => 'Gisle Aas <gisle@activestate.com>',
    LICENSE             => 'perl_5',

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
            x_IRC => 'irc://irc.perl.org/#lwp',
        },
        x_authority => 'cpan:GAAS',
        x_contributors => [ # manually added, from git shortlog -e -s -n
            'Gisle Aas <gisle@aas.no>',
            'Karen Etheridge <ether@cpan.org>',
            "Ville Skytt\xe4 <ville.skytta\@iki.fi>",
            'Mark Stosberg <mark@stosberg.com>',
            'Michael G. Schwern <schwern@pobox.com>',
            'Olaf Alders <olaf@wundersolutions.com>',
            'Slaven Rezic <slaven@rezic.de>',
            'Matt Lawrence <matthewlawrence@venda.com>',
            'Peter Rabbitson <ribasushi@cpan.org>',
            'Piotr Roszatycki <piotr.roszatycki@gmail.com>',
            'Salvatore Bonaccorso <carnil@launchpad.net>',
            'Tatsuhiko Miyagawa <miyagawa@bulknews.net>',
            "Torsten F\xf6rtsch <torsten.foertsch\@gmx.net>",
            'Adam Herzog <adam@adamherzog.com>',
            'gerard <gerard@tty.nl>',
            'Alex Kapranoff <kapranoff@gmail.com>',
            'Brendan Byrd <Perl@ResonatorSoft.org>',
            'David Schmidt <davewood@gmx.at>',
            'Jan Dubois <jand@activestate.com>',
            'John Miller <john@rimmkaufman.com>',
            'Kenichi Ishigaki <ishigaki@cpan.org>',
            'Kent Fredric <kentfredric@gmail.com>',
            'Masahiro Honma <hiratara@cpan.org>',
        ],
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
                    'Scalar::Util'  => '0',
                    'perl'          => '5.006',  # only 5.8+ is guaranteed; patches requested for 5.6 fixes
                },
                recommends => {
                    'Business::ISBN' => '0',
                },
            },
            test => {
                requires => {
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

die 'attention developer: you need to do a sane meta merge here!'
    if keys %{$WriteMakefileArgs{BUILD_REQUIRES}};

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

# pod2text is in https://metacpan.org/release/podlators
system("pod2text $WriteMakefileArgs{VERSION_FROM} > README")
    if $developer
        and (not -e 'README' or (stat('README'))[9] < (stat($WriteMakefileArgs{VERSION_FROM}))[9]);
