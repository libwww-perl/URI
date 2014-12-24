package URI::ssh;

use strict;
use warnings;

use parent 'URI::_login';

# ssh://[USER[:PASSWORD][;C-PARAM[,C-PARAM[,...]]]@]HOST[:PORT]/SRC
use URI::Escape qw(uri_unescape);


sub default_port { 22 }

sub secure { 1 }

sub sshinfo
{
    my $self = shift;
    my $old = $self->authority;

    if (@_) {
	my $new = $old;
	$new = "" unless defined $new;
	$new =~ s/.*@//;  # remove old stuff
	my $si = shift;
	if (defined $si) {
	    $si =~ s/@/%40/g;   # protect @
	    $new = "$si\@$new";
	}
	$self->authority($new);
    }
    return undef if !defined($old) || $old !~ /(.*)@/;
    return $1;
}

sub userinfo
{
    my $self = shift;
    my $old = $self->sshinfo;

    if (@_) {
	my $new = $old;
	$new = "" unless defined $new;
	$new =~ s/^[^;]*//;  # remove old stuff
	my $ui = shift;
	if (defined $ui) {
	    $ui =~ s/;/%3B/g;   # protect ;
	    $new = "$ui$new";
	}
        else {
            $new = undef unless length $new;
        }
	$self->sshinfo($new);
    }
    return undef if !defined($old) || $old !~ /^([^;]+)/;
    return $1;
}

sub c_params {
    my $self = shift;
    my $old = $self->sshinfo;
    if (@_) {
        my $new = $old;
        $new = "" unless defined $new;
        $new =~ s/;.*//; # remove old stuff
        my $cp = shift;
        $cp = [] unless defined $cp;
        $cp = [$cp] unless ref $cp;
        if (@$cp) {
            my @cp = @$cp;
            for (@cp) {
                s/%/%25/g;
                s/,/%2C/g;
                s/;/%3B/g;
            }
            $new .= ';' . join(',', @cp);
        }
        else {
            $new = undef unless length $new;
        }
        $self->sshinfo($new);
    }
    return undef if !defined($old) || $old !~ /;(.+)/;
    [map uri_unescape($_), split /,/, $1];
}

1;
