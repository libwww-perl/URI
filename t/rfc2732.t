# Test URIs containing IPv6 addresses

use strict;
use warnings;

use Test::More tests => 19;

use URI;
my $uri = URI->new("http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html");

is $uri->as_string, "http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html";
is $uri->host, "FEDC:BA98:7654:3210:FEDC:BA98:7654:3210";
is $uri->host_port, "[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80";
is $uri->port, "80";

$uri->port(undef);
is $uri->as_string, "http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]/index.html";
is $uri->host_port, "[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80";
$uri->port(80);

$uri->host("host");
is $uri->as_string, "http://host:80/index.html";

$uri->host("FEDC:BA98:7654:3210:FEDC:BA98:7654:3210");
is $uri->as_string, "http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html";
$uri->host_port("[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:88");
is $uri->as_string, "http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:88/index.html";
$uri->host_port("[::1]:80");
is $uri->as_string, "http://[::1]:80/index.html";
$uri->host("::1:80");
is $uri->as_string, "http://[::1:80]:80/index.html";
$uri->host("[::1:80]");
is $uri->as_string, "http://[::1:80]:80/index.html";
$uri->host("[::1]:88");
is $uri->as_string, "http://[::1]:88/index.html";


$uri = URI->new("ftp://ftp:@[3ffe:2a00:100:7031::1]");
is $uri->as_string, "ftp://ftp:@[3ffe:2a00:100:7031::1]";

is $uri->port, "21";
ok !$uri->_port;

is $uri->host("ftp"), "3ffe:2a00:100:7031::1";

is $uri, "ftp://ftp:\@ftp";

$uri = URI->new("http://[::1]");
is $uri->host, "::1";

__END__

      http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html
      http://[1080:0:0:0:8:800:200C:417A]/index.html
      http://[3ffe:2a00:100:7031::1]
      http://[1080::8:800:200C:417A]/foo
      http://[::192.9.5.5]/ipng
      http://[::FFFF:129.144.52.38]:80/index.html
      http://[2010:836B:4179::836B:4179]
