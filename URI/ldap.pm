# Copyright (c) 1998 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package URI::ldap;

use strict;

use URI::Escape qw(uri_escape uri_unescape);

use vars qw(@ISA $VERSION);

$VERSION = "1.02";

if (! eval { require URI::_generic } && eval { require URI::URL::_generic }) {
  @ISA = qw(URI::URL::_generic);
  @URI::URL::ldap::ISA = qw(URI::ldap);
}
else {
  require URI::_server;
  @ISA = qw(URI::_server);
}

sub default_port { 389 }

sub _ldap_elem {
  my $self  = shift;
  my $elem  = shift;
  my $query = $self->equery;
  my @bits  = (split(/\?/,defined($query) ? $query : ""),("")x4);
  my $old   = $bits[$elem];

  if (@_) {
    $bits[$elem] = shift;
    $query = join("?",@bits);
    $query =~ s/\?+$//;
    $self->equery($query);
  }

  $old;
}

sub dn {
  my $old = shift->path(@_);
  return unless defined wantarray && defined $old;
  $old =~ s:^/::;
  $old;
}

sub attributes {
  my $self = shift;
  my $old = _ldap_elem($self,0, @_ ? join(",", map { uri_escape($_) } @_) : ());
  return unless defined wantarray && defined $old;
  map { uri_unescape($_) } split(/,/,$old);
}

sub scope {
  my $self = shift;
  my $old = _ldap_elem($self,1, map { uri_escape($_) } @_);
  return unless defined wantarray && defined $old;
  uri_unescape($old);
}

sub filter {
  my $self = shift;
  my $old = _ldap_elem($self,2, map { uri_escape($_) } @_);
  return unless defined wantarray && defined $old;
  uri_unescape($old);
}

sub extensions {
  my $self = shift;
  my @ext = ();
  if (@_) {
    my %ext = @_;
    @ext = (join(",", map { $_ . "=" . uri_escape($ext{$_},";,\\/?:\\@&=+#%") }
			 keys %ext));
  }
  my $old = _ldap_elem($self,3, @ext);
  return unless defined wantarray && defined $old;
  map { uri_unescape($_) } map { /^([^=]+)=(.*)$/ } split(/,/,$old);
}

1;

__END__

=head1 NAME

URI::URL::ldap - LDAP Uniform Resource Locators

=head1 SYNOPSIS

  use URI::URL::ldap;
  
  $url = URI::URL::ldap->new($url_string);
  
  $dn     = $url->dn;
  $filter = $url->filter;
  @attr   = $url->attributes;
  $scope  = $url->scope;
  %extn   = $url->extensions;
  
  $url = URI::URL::ldap->new;
  
  $url->host("ldap.itd.umich.edu");
  $url->dn("o=University of Michigan,c=US");
  $url->attributes(qw(postalAddress));
  $url->scope('sub');
  $url->filter('(cn=Babs Jensen)');
  print $url->as_string,"\n";

=head1 DESCRIPTION

C<URI::URL::ldap> provides an interface to parse an LDAP URL in its
constituent parts and also build a URL as described in
L<RFC-2255|http://www.cis.ohio-state.edu/htbin/rfc/rfc2255.html>

=head1 METHODS

C<URI::URL::ldap> support all methods defined by L<URI::URL>, plus the
following.

Each of the methods can be used to set or get the value in the URL. If arguments
are given then a new value will be set for the given part of the URL.

=over 4

=item dn

Set or get the DN part of the URL

=item attributes

Set or get the list of attribute names which will be returned by the search.

=item scope

Set or get the scope that the search will use. The value can be one of
C<base>, C<one> or C<sub>. If none is given the it will default to C<base>

=item filter

Set or get the filter that the search will use.

=item extensions

Set or get the extensions used for the search. The list passed should be in the
form type1, value1, type2, value2 ... This is also the form of list that
will be returned.

=back

=head1 SEE ALSO

L<RFC-2255|http://www.cis.ohio-state.edu/htbin/rfc/rfc2255.html>

=head1 AUTHOR

Graham Barr E<lt>F<gbarr@pobox.com>E<gt>

=head1 COPYRIGHT

Copyright (c) 1998 Graham Barr. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same
terms as Perl itself.

=cut
