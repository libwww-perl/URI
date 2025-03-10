package URI::smb;

# http://www.ubiqx.org/cifs/Appendix-D.html
# smb://domain;user:password@server/share/path

use strict;
use warnings;

use parent 'URI::_login';

use URI::Escape qw(uri_unescape);

sub default_port { 445 }

sub sharename {
    return (shift->path_segments)[1];
}

sub user {
    my ($user) = _parse_user(shift->SUPER::user());
    $user = uri_unescape($user) if defined $user;
    return $user;
}

sub authdomain {
    my ($user, $domain) = _parse_user(shift->SUPER::user());
    $domain = uri_unescape($domain) if defined $domain;
    return $domain;
}

sub _parse_user {
    my $user = shift or return;
    if ($user =~ m/(?: (?<domain> [^;]* ) [;] )? (?<user> [^;:\/]+ )/xms) {
        return ($+{user}, $+{domain});
    }
    return $user;
}

1;
