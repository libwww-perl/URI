package URI::ftp;

require URI::_server;
@ISA=qw(URI::_server);

use strict;
use vars qw($whoami $fqdn);

sub default_port { 21 }

sub path { shift->path_query(@_) }  # XXX

sub _user
{
    my $self = shift;
    my $info = $self->userinfo;
    if (@_) {
	my $new = shift;
	my $pass = defined($info) ? $info : "";
	$pass =~ s/^[^:]*//;

	if (!defined($new) && !length($pass)) {
	    $self->userinfo(undef);
	} else {
	    $new = "" unless defined($new);
	    $new =~ s/%/%25/g;
	    $new =~ s/:/%3A/g;
	    $self->userinfo("$new$pass");
	}
    }
    return unless defined $info;
    $info =~ s/:.*//;
    $info;
}

sub _password
{
    my $self = shift;
    my $info = $self->userinfo;
    if (@_) {
	my $new = shift;
	my $user = defined($info) ? $info : "";
	$user =~ s/:.*//;

	if (!defined($new) && !length($user)) {
	    $self->userinfo(undef);
	} else {
	    $new = "" unless defined($new);
	    $new =~ s/%/%25/g;
	    $self->userinfo("$user:$new");
	}
    }
    return unless defined $info;
    return unless $info =~ s/^[^:]*://;
    $info;
}

sub user
{
    my $self = shift;
    my $user = $self->_user(@_);
    $user = "anonymous" unless defined $user;
    $user;
}

sub password
{
    my $self = shift;
    my $old = $self->_password(@_);
    unless (defined $old) {
	my $user = $self->user;
	if ($user eq 'anonymous' || $user eq 'ftp') {
	    # anonymous ftp login password
	    unless (defined $fqdn) {
		eval {
		    require Net::Domain;
		    $fqdn = Net::Domain::hostfqdn();
		};
		if ($@) {
		    $fqdn = '';
		}
	    }
	    unless (defined $whoami) {
		$whoami = $ENV{USER} || $ENV{LOGNAME} || $ENV{USERNAME};
		unless ($whoami) {
		    if ($^O eq 'MSWin32') { $whoami = Win32::LoginName() }
		    else {
		        $whoami = getlogin || getpwuid($<) || 'unknown';
		    }
		}
	    }
	    $old = "$whoami\@$fqdn";
	}
    }
    $old;
}

1;
