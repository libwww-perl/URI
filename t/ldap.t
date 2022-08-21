use strict;
use warnings;

use Test::More tests => 24;

use URI ();

my $uri;

$uri = URI->new("ldap://host/dn=base?cn,sn?sub?objectClass=*");

is($uri->host, "host");

is($uri->dn, "dn=base");

is(join("-",$uri->attributes), "cn-sn");

is($uri->scope, "sub");

is($uri->filter, "objectClass=*");

$uri = URI->new("ldap:");
$uri->dn("o=University of Michigan,c=US");

ok("$uri" eq "ldap:o=University%20of%20Michigan,c=US" &&
    $uri->dn eq "o=University of Michigan,c=US");

$uri->host("ldap.itd.umich.edu");
is($uri->as_string, "ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US");

# check defaults
ok($uri->_scope  eq "" &&
   $uri->scope   eq "base" &&
   $uri->_filter eq "" &&
   $uri->filter  eq "(objectClass=*)");

# attribute
$uri->attributes("postalAddress");
is($uri, "ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US?postalAddress");

# does attribute escapeing work as it should
$uri->attributes($uri->attributes, "foo", ",", "*", "?", "#", "\0");

ok($uri->attributes eq "postalAddress,foo,%2C,*,%3F,%23,%00" &&
   join("-", $uri->attributes) eq "postalAddress-foo-,-*-?-#-\0");
$uri->attributes("");

$uri->scope("sub?#");
ok($uri->query eq "?sub%3F%23" &&
   $uri->scope eq "sub?#");
$uri->scope("");

$uri->filter("f=?,#");
ok($uri->query eq "??f=%3F,%23" &&
   $uri->filter eq "f=?,#");

$uri->filter("(int=\\00\\00\\00\\04)");
is($uri->query, "??(int=%5C00%5C00%5C00%5C04)");


$uri->filter("");

$uri->extensions("!bindname" => "cn=Manager,co=Foo");
my %ext = $uri->extensions;

ok($uri->query eq "???!bindname=cn=Manager%2Cco=Foo" &&
   keys %ext == 1 &&
   $ext{"!bindname"} eq "cn=Manager,co=Foo");

$uri = URI->new("ldap://LDAP-HOST:389/o=University%20of%20Michigan,c=US?postalAddress?base?ObjectClass=*?FOO=Bar,bindname=CN%3DManager%CO%3dFoo");

is($uri->canonical, "ldap://ldap-host/o=University%20of%20Michigan,c=US?postaladdress???foo=Bar,bindname=CN=Manager%CO=Foo");

note $uri;
note $uri->canonical;

ok(!$uri->secure);

$uri = URI->new("ldaps://host/dn=base?cn,sn?sub?objectClass=*");

is($uri->host, "host");
is($uri->port, 636);
is($uri->dn, "dn=base");
ok($uri->secure);

$uri = URI->new("ldapi://%2Ftmp%2Fldap.sock/????x-mod=-w--w----");
is($uri->authority, "%2Ftmp%2Fldap.sock");
is($uri->un_path, "/tmp/ldap.sock");

$uri->un_path("/var/x\@foo:bar/");
is($uri, "ldapi://%2Fvar%2Fx%40foo%3Abar%2F/????x-mod=-w--w----");

%ext = $uri->extensions;
is($ext{"x-mod"}, "-w--w----");

