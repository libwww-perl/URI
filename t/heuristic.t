#!perl -w

if (-f "OFFLINE") {
   print "1..0";
   exit;
}

print "1..20\n";

use URI::Heuristic qw(uf_urlstr uf_url);
if (shift) {
    $URI::Heuristic::DEBUG++;
    open(STDERR, ">&STDOUT");  # redirect STDERR
}

print "not " unless uf_urlstr("http://www.sn.no/") eq "http://www.sn.no/";
print "ok 1\n";

if ($^O eq "MacOS") {
    print "not " unless uf_urlstr("etc:passwd") eq "file:/etc/passwd";
} else {
print "not " unless uf_urlstr("/etc/passwd") eq "file:/etc/passwd";
}
print "ok 2\n";

if ($^O eq "MacOS") {
    print "not " unless uf_urlstr(":foo.txt") eq "file:./foo.txt";
} else {
print "not " unless uf_urlstr("./foo.txt") eq "file:./foo.txt";
}
print "ok 3\n";

print "not " unless uf_urlstr("ftp.aas.no/lwp.tar.gz") eq "ftp://ftp.aas.no/lwp.tar.gz";
print "ok 4\n";

if($^O eq "MacOS") {
#  its a weird, but valid, MacOS path, so it can't be left alone
    print "not " unless uf_urlstr("C:\\CONFIG.SYS") eq "file:/C/%5CCONFIG.SYS";
} else {
print "not " unless uf_urlstr("C:\\CONFIG.SYS") eq "file:C:\\CONFIG.SYS";
}
print "ok 5\n";

if (gethostbyname("www.perl.com") && gethostbyname("www.perl.co.uk") && gethostbyname("www.perl.su") && !gethostbyname("www.perl.bv")) {
    # DNS works, let's run tests 6..12

    {
        local $ENV{LC_ALL} = "";
        local $ENV{LANG} = "";
        local $ENV{HTTP_ACCEPT_LANGUAGE} = "";

        $ENV{LC_ALL} = "en_GB.UTF-8";
        undef $URI::Heuristic::MY_COUNTRY;
        print "not " unless uf_urlstr("perl/camel.gif") =~ m,^http://www\.perl\.(org|co)\.uk/camel\.gif$,;
        print "ok 6\n";

        use Net::Domain;
        $ENV{LC_ALL} = "C";
        { no warnings; *Net::Domain::hostfqdn = sub { return 'vasya.su' } }
        undef $URI::Heuristic::MY_COUNTRY;
        print "not " unless uf_urlstr("perl/camel.gif") =~ m,^http://www\.perl\.su/camel\.gif$,;
        print "ok 7\n";

        $ENV{LC_ALL} = "C";
        { no warnings; *Net::Domain::hostfqdn = sub { return '' } }
        undef $URI::Heuristic::MY_COUNTRY;
        print "not " unless uf_urlstr("perl/camel.gif") =~ m,^http://www\.perl\.(com|org)/camel\.gif$,;
        print "ok 8\n";

        $ENV{HTTP_ACCEPT_LANGUAGE} = "en-ca";
        undef $URI::Heuristic::MY_COUNTRY;
        print "not " unless uf_urlstr("perl/camel.gif") eq "http://www.perl.ca/camel.gif";
        print "ok 9\n";
    }

    $URI::Heuristic::MY_COUNTRY = "bv";
    print "not " unless uf_urlstr("perl/camel.gif") =~ m,^http://www\.perl\.(com|org)/camel\.gif$,;
    print "ok 10\n";

    # Backwards compatibility; uk != United Kingdom in ISO 3166
    $URI::Heuristic::MY_COUNTRY = "uk";
    print "not " unless uf_urlstr("perl/camel.gif") =~ m,^http://www\.perl\.(org|co)\.uk/camel\.gif$,;
    print "ok 11\n";

    $URI::Heuristic::MY_COUNTRY = "gb";
    print "not " unless uf_urlstr("perl/camel.gif") =~ m,^http://www\.perl\.(org|co)\.uk/camel\.gif$,;
    print "ok 12\n";

    $ENV{URL_GUESS_PATTERN} = "www.ACME.org www.ACME.com";
    print "not " unless uf_urlstr("perl") eq "http://www.perl.org";
    print "ok 13\n";

} else {
    # don't make the innocent worry
    print "Skipping test 6-12 because DNS does not work\n";
    for (6..13) { print "ok $_\n"; }

}

{
local $ENV{URL_GUESS_PATTERN} = "";
print "not " unless uf_urlstr("perl") eq "http://perl";
print "ok 14\n";

print "not " unless uf_urlstr("http:80") eq "http:80";
print "ok 15\n";

print "not " unless uf_urlstr("mailto:gisle\@aas.no") eq "mailto:gisle\@aas.no";
print "ok 16\n";

print "not " unless uf_urlstr("gisle\@aas.no") eq "mailto:gisle\@aas.no";
print "ok 17\n";

print "not " unless uf_urlstr("Gisle.Aas\@aas.perl.org") eq "mailto:Gisle.Aas\@aas.perl.org";
print "ok 18\n";

print "not " unless uf_url("gopher.sn.no")->scheme eq "gopher";
print "ok 19\n";

print "not " unless uf_urlstr("123.3.3.3:8080/foo") eq "http://123.3.3.3:8080/foo";
print "ok 20\n";
}

#
#print "not " unless uf_urlstr("some-site") eq "http://www.some-site.com";
#print "ok 15\n";
#
#print "not " unless uf_urlstr("some-site.com") eq "http://some-site.com";
#print "ok 16\n";
#
