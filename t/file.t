use strict;
use warnings;

use Test::More;
use URI::file ();


subtest 'OS related tests (unix, win32, mac)' => sub {

    my @tests = (
        ["file", "unix", "win32", "mac"],

        #----------------  ------------  ---------------  --------------
        ["file://localhost/foo/bar", "!/foo/bar", "!\\foo\\bar", "!foo:bar",],
        ["file:///foo/bar",          "/foo/bar",  "\\foo\\bar",  "!foo:bar",],
        ["file:/foo/bar",            "!/foo/bar", "!\\foo\\bar", "foo:bar",],
        ["foo/bar",                  "foo/bar",   "foo\\bar",    ":foo:bar",],
        [
            "file://foo3445x/bar", "!//foo3445x/bar",
            "!\\\\foo3445x\\bar",  "!foo3445x:bar"
        ],
        ["file://a:/",  "!//a:/", "!A:\\",   undef],
        ["file:///A:/", "/A:/",   "A:\\",    undef],
        ["file:///",    "/",      "\\",      undef],
        [".",           ".",      ".",       ":"],
        ["..",          "..",     "..",      "::"],
        ["%2E",         "!.",     "!.",      ":."],
        ["../%2E%2E",   "!../..", "!..\\..", "::.."],
    );

    my @os = @{shift @tests};
    shift @os;    # file

    for my $t (@tests) {
        my @t    = @$t;
        my $file = shift @t;
        my $u    = URI->new($file, "file");
        my $i    = 0;

        for my $os (@os) {
            my $f      = $u->file($os);
            my $expect = $t[$i];
            $f      = "<undef>" unless defined $f;
            $expect = "<undef>" unless defined $expect;
            my $loose;
            $loose++ if $expect =~ s/^!//;

            is($f, $expect) or diag "URI->new('$file', 'file')->file('$os')";

            if (defined($t[$i]) && !$loose) {
                my $u2 = URI::file->new($t[$i], $os);
                is($u2->as_string, $file)
                    or diag "URI::file->new('$t[$i]', '$os')";
            }

            $i++;
        }
    }

};


SKIP: {
    skip "No pre 5.11 regression tests yet.", 1
        if URI::HAS_RESERVED_SQUARE_BRACKETS;

    subtest "Including Domains" => sub {

        is(
            URI->new('file://example.com/tmp/file.part[1]'),
            'file://example.com/tmp/file.part%5B1%5D'
        );
        is(
            URI->new('file://127.0.0.1/tmp/file.part[2]'),
            'file://127.0.0.1/tmp/file.part%5B2%5D'
        );
        is(
            URI->new('file://localhost/tmp/file.part[3]'),
            'file://localhost/tmp/file.part%5B3%5D'
        );
        is(
            URI->new('file://[1:2:3::beef]/tmp/file.part[4]'),
            'file://[1:2:3::beef]/tmp/file.part%5B4%5D'
        );
        is(
            URI->new('file:///[1:2:3::1ce]/tmp/file.part[5]'),
            'file:///%5B1:2:3::1ce%5D/tmp/file.part%5B5%5D'
        );

    };

}


subtest "Regression Tests" => sub {

  # Regression test for https://github.com/libwww-perl/URI/issues/102
  {
    my $with_hashes = URI::file->new_abs("/tmp/###");
    is($with_hashes, 'file:///tmp/%23%23%23', "issue GH#102");
  }

  # URI 5.11 introduced a bug where URI::file could return the current
  # working directory instead of the path defined.
  # The bug was caused by a wrong quantifier in a regular expression in
  # URI::_fix_uric_escape_for_host_part() which returned an empty string for
  # all URIs that needed escaping ('%xx') but did not have a host part.
  # The empty string in turn caused URI::file->new_abs() to use the current
  # working directory as a default.
  {
    my $file_path   = URI::file->new_abs('/a/path/that/pretty likely/does/not/exist-yie1Ahgh0Ohlahqueirequ0iebu8ip')->file();
    my $current_dir = URI::file->new_abs()->file();

    isnt( $file_path, $current_dir, 'regression test for #102' );
  }

};


done_testing;
