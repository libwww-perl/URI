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

use Test::More tests => 26;

use URI::Heuristic qw( uf_url uf_urlstr );
if (shift) {
    $URI::Heuristic::DEBUG++;
    open(STDERR, ">&STDOUT");  # redirect STDERR
}

is(uf_urlstr("http://www.sn.no/"), "http://www.sn.no/");

if ($^O eq "MacOS") {
    is(uf_urlstr("etc:passwd"), "file:/etc/passwd");
} else {
    is(uf_urlstr("/etc/passwd"), "file:/etc/passwd");
}

if ($^O eq "MacOS") {
    is(uf_urlstr(":foo.txt"), "file:./foo.txt");
} else {
    is(uf_urlstr("./foo.txt"), "file:./foo.txt");
}

is(uf_urlstr("ftp.aas.no/lwp.tar.gz"), "ftp://ftp.aas.no/lwp.tar.gz");

if($^O eq "MacOS") {
#  its a weird, but valid, MacOS path, so it can't be left alone
    is(uf_urlstr("C:\\CONFIG.SYS"), "file:/C/%5CCONFIG.SYS");
} else {
    is(uf_urlstr("C:\\CONFIG.SYS"), "file:C:\\CONFIG.SYS");
}

{
    local $ENV{LC_ALL} = "";
    local $ENV{LANG} = "";
    local $ENV{HTTP_ACCEPT_LANGUAGE} = "";

    $ENV{LC_ALL} = "en_GB.UTF-8";
    undef $URI::Heuristic::MY_COUNTRY;
    like(uf_urlstr("perl/camel.gif"), qr,^http://www\.perl\.(org|co)\.uk/camel\.gif$,);

    use Net::Domain ();
    $ENV{LC_ALL} = "C";
    { no warnings; *Net::Domain::hostfqdn = sub { return 'vasya.su' } }
    undef $URI::Heuristic::MY_COUNTRY;
    is(uf_urlstr("perl/camel.gif"), "http://www.perl.su/camel.gif");

    $ENV{LC_ALL} = "C";
    { no warnings; *Net::Domain::hostfqdn = sub { return '' } }
    undef $URI::Heuristic::MY_COUNTRY;
    like(uf_urlstr("perl/camel.gif"), qr,^http://www\.perl\.(com|org)/camel\.gif$,);

    $ENV{HTTP_ACCEPT_LANGUAGE} = "en-ca";
    undef $URI::Heuristic::MY_COUNTRY;
    is(uf_urlstr("perl/camel.gif"), "http://www.perl.ca/camel.gif");
}

$URI::Heuristic::MY_COUNTRY = "bv";
like(uf_urlstr("perl/camel.gif"), qr,^http://www\.perl\.(com|org)/camel\.gif$,);

# Backwards compatibility; uk != United Kingdom in ISO 3166
$URI::Heuristic::MY_COUNTRY = "uk";
like(uf_urlstr("perl/camel.gif"), qr,^http://www\.perl\.(org|co)\.uk/camel\.gif$,);

$URI::Heuristic::MY_COUNTRY = "gb";
like(uf_urlstr("perl/camel.gif"), qr,^http://www\.perl\.(org|co)\.uk/camel\.gif$,);

$ENV{URL_GUESS_PATTERN} = "www.ACME.org www.ACME.com";
is(uf_urlstr("perl"), "http://www.perl.org");

{
    local $ENV{URL_GUESS_PATTERN} = "";
    is(uf_urlstr("perl"), "http://perl");

    is(uf_urlstr("http:80"), "http:80");

    is(uf_urlstr("mailto:gisle\@aas.no"), "mailto:gisle\@aas.no");

    is(uf_urlstr("gisle\@aas.no"), "mailto:gisle\@aas.no");

    is(uf_urlstr("Gisle.Aas\@aas.perl.org"), "mailto:Gisle.Aas\@aas.perl.org");

    is(uf_url("gopher.sn.no")->scheme, "gopher");

    is(uf_urlstr("123.3.3.3:8080/foo"), "http://123.3.3.3:8080/foo");

    is(uf_urlstr("123.3.3.3:443/foo"), "https://123.3.3.3:443/foo");

    is(uf_urlstr("123.3.3.3:21/foo"), "ftp://123.3.3.3:21/foo");

    is(uf_url("FTP.example.com")->scheme, "ftp");

    is(uf_url("ftp2.example.com")->scheme, "ftp");

    is(uf_url("ftp")->scheme, "ftp");

    is(uf_url("https.example.com")->scheme, "https");
}
