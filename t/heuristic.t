use strict;
use warnings;

BEGIN {
    # mock up a gethostbyname that always works :-)
    *CORE::GLOBAL::gethostbyname = sub {
	my $name = shift;
	#print "# gethostbyname [$name]\n";
	die if wantarray;
	return 1 if $name =~ /^www\.perl\.(com|org|ca|su)\.$/;
	return 1 if $name eq "www.perl.co.uk\.";
	return 0;
    };
}

print "1..26\n";

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

    print "not " unless uf_urlstr("123.3.3.3:443/foo") eq "https://123.3.3.3:443/foo";
    print "ok 21\n";

    print "not " unless uf_urlstr("123.3.3.3:21/foo") eq "ftp://123.3.3.3:21/foo";
    print "ok 22\n";

    print "not " unless uf_url("FTP.example.com")->scheme eq "ftp";
    print "ok 23\n";

    print "not " unless uf_url("ftp2.example.com")->scheme eq "ftp";
    print "ok 24\n";

    print "not " unless uf_url("ftp")->scheme eq "ftp";
    print "ok 25\n";

    print "not " unless uf_url("https.example.com")->scheme eq "https";
    print "ok 26\n";
}
