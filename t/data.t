use strict;
use warnings;

use Test::More tests => 22;

use URI ();

my $u = URI->new("data:,A%20brief%20note");
ok($u->scheme eq "data" && $u->opaque eq ",A%20brief%20note");

ok($u->media_type eq "text/plain;charset=US-ASCII" &&
   $u->data eq "A brief note");

my $old = $u->data("Får-i-kål er tingen!");
ok($old eq "A brief note" && $u eq "data:,F%E5r-i-k%E5l%20er%20tingen!");

$old = $u->media_type("text/plain;charset=iso-8859-1");
ok($old eq "text/plain;charset=US-ASCII" &&
   $u eq "data:text/plain;charset=iso-8859-1,F%E5r-i-k%E5l%20er%20tingen!");


$u = URI->new("data:image/gif;base64,R0lGODdhMAAwAPAAAAAAAP///ywAAAAAMAAwAAAC8IyPqcvt3wCcDkiLc7C0qwyGHhSWpjQu5yqmCYsapyuvUUlvONmOZtfzgFzByTB10QgxOR0TqBQejhRNzOfkVJ+5YiUqrXF5Y5lKh/DeuNcP5yLWGsEbtLiOSpa/TPg7JpJHxyendzWTBfX0cxOnKPjgBzi4diinWGdkF8kjdfnycQZXZeYGejmJlZeGl9i2icVqaNVailT6F5iJ90m6mvuTS4OK05M0vDk0Q4XUtwvKOzrcd3iq9uisF81M1OIcR7lEewwcLp7tuNNkM3uNna3F2JQFo97Vriy/Xl4/f1cf5VWzXyym7PHhhx4dbgYKAAA7");

is($u->media_type, "image/gif");

if ($ENV{DISPLAY} && $ENV{XV}) {
   open(XV, "| $ENV{XV} -") || die;
   print XV $u->data;
   close(XV);
}
is(length($u->data), 273);

$u = URI->new("data:text/plain;charset=iso-8859-7,%be%fg%be");  # %fg
is($u->data, "\xBE%fg\xBE");

$u = URI->new("data:application/vnd-xxx-query,select_vcount,fcol_from_fieldtable/local");
is($u->data, "select_vcount,fcol_from_fieldtable/local");
$u->data("");
is($u, "data:application/vnd-xxx-query,");

$u->data("a,b"); $u->media_type(undef);
is($u, "data:,a,b");

# Test automatic selection of URI/BASE64 encoding
$u = URI->new("data:");
$u->data("");
is($u, "data:,");

$u->data(">");
ok($u eq "data:,%3E" && $u->data eq ">");

$u->data(">>>>>");
is($u, "data:,%3E%3E%3E%3E%3E");

$u->data(">>>>>>");
is($u, "data:;base64,Pj4+Pj4+");

$u->media_type("text/plain;foo=bar");
is($u, "data:text/plain;foo=bar;base64,Pj4+Pj4+");

$u->media_type("foo");
is($u, "data:foo;base64,Pj4+Pj4+");

$u->data(">" x 3000);
ok($u eq ("data:foo;base64," . ("Pj4+" x 1000)) &&
   $u->data eq (">" x 3000));

$u->media_type(undef);
$u->data(undef);
is($u, "data:,");

$u = URI->new("data:foo");
is($u->media_type("bar,båz"), "foo");

is($u->media_type, "bar,båz");

$old = $u->data("new");
ok($old eq "" && $u eq "data:bar%2Cb%E5z,new");

is(URI->new('data:;base64,%51%6D%70%76%5A%58%4A%75')->data, "Bjoern");
