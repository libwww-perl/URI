use strict;
use warnings;

use Test::More;

use URI::file;
$URI::file::DEFAULT_AUTHORITY = undef;

my @tests =  (
[ "file",          "unix",       "win32",         "mac" ],
#----------------  ------------  ---------------  --------------
[ "file://localhost/foo/bar",
	           "!/foo/bar",  "!\\foo\\bar",   "!foo:bar", ],
[ "file:///foo/bar",
	           "!/foo/bar",  "!\\foo\\bar",   "!foo:bar", ],
[ "file:/foo/bar", "/foo/bar",   "\\foo\\bar",    "foo:bar", ],
[ "foo/bar",       "foo/bar",    "foo\\bar",      ":foo:bar",],
[ "file://foo3445x/bar","!//foo3445x/bar", "\\\\foo3445x\\bar",  "!foo3445x:bar"],
[ "file://a:/",    "!//a:/",     "!A:\\",          undef],
[ "file:/",        "/",          "\\",             undef],
[ "file://A:relative/", "!//A:relative/", "A:",    undef],
[ ".",             ".",          ".",              ":"],
[ "..",            "..",         "..",             "::"],
[ "%2E",           "!.",          "!.",            ":."],
[ "../%2E%2E",     "!../..",      "!..\\..",       "::.."],
);
if ($^O eq "MacOS") {
my @extratests = (
[ "../..",        "../..",         "..\\..",           ":::"],
[ "../../",       "../../",        "..\\..\\",         "!:::"],
[ "file:./foo.bar", "!./foo.bar",    "!.\\foo.bar",       "!:foo.bar"],
[ "file:/%2Ffoo/bar", undef,      undef,           "/foo:bar"],
[ "file:/.%2Ffoo/bar", undef,      undef,           "./foo:bar"],
[ "file:/fee/.%2Ffoo%2Fbar", undef,      undef,           "fee:./foo/bar"],
[ "file:/.%2Ffoo%2Fbar/", undef,      undef,           "./foo/bar:"],
[ "file:/.%2Ffoo%2Fbar", undef,      undef,           "!./foo/bar:"],
[ "file:/%2E%2E/foo",   "!/../foo",   "!\\..\\foo" , "..:foo"],
[ "file:/bar/%2E/foo", "!/bar/./foo",  "!\\bar\\.\\foo", "bar:.:foo"],
[ "file:/foo/../bar",  "/foo/../bar",  "\\foo\\..\\bar", "foo::bar"],
[ "file:/a/b/../../c/d",  "/a/b/../../c/d",  "\\a\\b\\..\\..\\c\\d", "a:b:::c:d"],
);
  push(@tests,@extratests);
}

my @os = @{shift @tests};
shift @os;  # file

plan tests => scalar @tests;

for my $t (@tests) {
   my @t = @$t;
   my $file = shift @t;
   my $err;

   my $u = URI->new($file, "file");
   my $i = 0;
   for my $os (@os) {
       my $f = $u->file($os);
       my $expect = $t[$i];
       $f = "<undef>" unless defined $f;
       $expect = "<undef>" unless defined $expect;
       my $loose;
       $loose++ if $expect =~ s/^!//;
       if ($expect ne $f) {
           diag "URI->new('$file', 'file')->file('$os') ne $expect, but $f";
           $err++;
       }
       if (defined($t[$i]) && !$loose) {
	   my $u2 = URI::file->new($t[$i], $os);
           unless ($u2->as_string eq $file) {
              diag "URI::file->new('$t[$i]', '$os') ne $file, but $u2";
              $err++;
           }
       }
       $i++;
   }
   ok !$err;
}
