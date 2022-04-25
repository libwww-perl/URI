#!perl -T

use strict;
use warnings;

use URI::file;
use File::Spec;

my @tests =  (
[ "file",          "unix",       "win32",         "mac" ],
#----------------  ------------  ---------------  --------------
[ "file://localhost/foo/bar",
	           "!/foo/bar",  "!\\foo\\bar",   "!foo:bar", ],
[ "file:///foo/bar",
	           "/foo/bar",   "\\foo\\bar",    "!foo:bar", ],
[ "file:/foo/bar", "!/foo/bar",  "!\\foo\\bar",   "foo:bar", ],
[ "foo/bar",       "foo/bar",    "foo\\bar",      ":foo:bar",],
[ "file://foo3445x/bar","!//foo3445x/bar", "!\\\\foo3445x\\bar", "!foo3445x:bar"],
[ "file://a:/",    "!//a:/",     "!A:\\",         undef],
[ "file:///A:/",   "/A:/",       "A:\\",          undef],
[ "file:///",      "/",          "\\",            undef],
[ ".",             ".",          ".",             ":"],
[ "..",            "..",         "..",            "::"],
[ "%2E",           "!.",         "!.",           ":."],
[ "../%2E%2E",     "!../..",     "!..\\..",      "::.."],
);

my @os = @{shift @tests};
shift @os;  # file

# Adding the one at the bottom
my $num = @tests+1;
print "1..$num\n";

my $testno = 1;

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
           print "URI->new('$file', 'file')->file('$os') ne '$expect', but '$f'\n";
           $err++;
       }
       if (defined($t[$i]) && !$loose) {
	   my $u2 = URI::file->new($t[$i], $os);
           unless ($u2->as_string eq $file) {
              print "URI::file->new('$t[$i]', '$os') ne '$file', but '$u2'\n";
              $err++;
           }
       }
       $i++;
   }
   print "not " if $err;
   print "ok $testno\n";
   $testno++;
}

my $file = ' hello world ';
my $u = URI::file->new_abs( $file );
my @dirs = File::Spec->splitdir( $u->file( 'Unix' ) );
print( "not " ) if( $dirs[-1] ne $file );
print( "ok $num\n" );
if( $dirs[-1] ne $file )
{
    printf( "# Failed test 'file with leading and trailing space'\n# at %s line %d.\n", __FILE__, ( __LINE__ - 6 ) );
}

