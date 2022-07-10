#!perl -T

use strict;
use warnings;

use Test::More;
use URI::file;


subtest 'OS related tests (unix, win32, mac)' => sub {

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
  shift @os;                    # file

  for my $t (@tests) {
    my @t    = @$t;
    my $file = shift @t;
    my $u    = URI->new($file, "file");
    my $i    = 0;

    for my $os (@os) {
      my $f      = $u->file($os);
      my $expect = $t[$i];
      $f         = "<undef>" unless defined $f;
      $expect    = "<undef>" unless defined $expect;
      my $loose;
      $loose++ if $expect =~ s/^!//;

      is($f, $expect)  or  diag "URI->new('$file', 'file')->file('$os')";

      if (defined($t[$i]) && !$loose) {
        my $u2 = URI::file->new($t[$i], $os);
        is($u2->as_string, $file)  or  diag "URI::file->new('$t[$i]', '$os')";
      }

      $i++;
    }
  }

  done_testing
};


subtest "Regression Tests" => sub {
  #-- Regression test for https://github.com/libwww-perl/URI/issues/102
  my $with_hashes = URI::file->new_abs("/tmp/###");
  is( $with_hashes,  'file:///tmp/%23%23%23', "issue GH#102");

  done_testing;
};


done_testing;
