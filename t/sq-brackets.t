use strict;
use warnings;

use Test::More;

BEGIN {
  $ENV{URI_HAS_RESERVED_SQUARE_BRACKETS} = 0;
}

use URI ();

sub show {
  diag explain("self: ", shift);
}


#-- test bugfix of https://github.com/libwww-perl/URI/issues/99


is( URI::HAS_RESERVED_SQUARE_BRACKETS, 0, "constant indicates NOT to treat square brackets as reserved characters" );

{
  my $u = URI->new("http://[::1]/path_with_square_[brackets]?par=value[1]");
  is( $u->canonical,
      "http://[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D",
      "sqb in path and request"
    ) or show $u;
}


{
  my $u = URI->new("http://[::1]/path_with_square_[brackets]?par=value[1]#fragment[2]");
  is( $u->canonical,
      "http://[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D#fragment%5B2%5D",
      "sqb in path and request and fragment"
    ) or show $u;
}


{
  my $u = URI->new("http://root[user]@[::1]/path_with_square_[brackets]?par=value[1]#fragment[2]");
  is( $u->canonical,
      "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D#fragment%5B2%5D",
      "sqb in userinfo, host, path, request and fragment"
    ) or show $u;
}


{
  my $u = URI->new("http://root[user]@[::1]/path_with_square_[brackets]?par=value[1]&par[2]=value[2]#fragment[2]");
  is( $u->canonical,
      "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D&par%5B2%5D=value%5B2%5D#fragment%5B2%5D",
      "sqb in userinfo, host, path, request and fragment"
    ) or show $u;

  is( $u->scheme()                , "http",           "scheme");
  is( $u->userinfo()              , "root%5Buser%5D", "userinfo");
  is( $u->host()                  , "::1",            "host");
  is( $u->ihost()                 , "::1",            "ihost");
  is( $u->port()                  , "80",             "port");
  is( $u->default_port()          , "80",             "default_port");
  is( $u->host_port()             , "[::1]:80",       "host_port");
  is( $u->secure()                , "0",              "is_secure" );
  is( $u->path()                  , "/path_with_square_%5Bbrackets%5D", "path");
  is( $u->opaque()                , "//root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D&par%5B2%5D=value%5B2%5D", "opaque");
  is( $u->fragment()              , "fragment%5B2%5D", "fragment");
  is( $u->query()                 , "par=value%5B1%5D&par%5B2%5D=value%5B2%5D", "query");
  is( $u->as_string()             , "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D&par%5B2%5D=value%5B2%5D#fragment%5B2%5D", "as_string");
  is( $u->has_recognized_scheme() , "1", "has_recognized_scheme");
  is( $u->as_iri()                , "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D&par%5B2%5D=value%5B2%5D#fragment%5B2%5D", "as_iri"); #TODO: utf8

  is( $u->abs( "/BASEDIR")->as_string() , "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D&par%5B2%5D=value%5B2%5D#fragment%5B2%5D", "abs (no change)");
  is( $u->rel("../BASEDIR")             , "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D?par=value%5B1%5D&par%5B2%5D=value%5B2%5D#fragment%5B2%5D", "rel");

  is( $u->authority()                   , "root%5Buser%5D@[::1]", "authority" );
  is( $u->path_query()                  , "/path_with_square_%5Bbrackets%5D?par=value%5B1%5D&par%5B2%5D=value%5B2%5D", "path_query");
  is( $u->query_keywords()              , undef, "query_keywords");

  my @segments = $u->path_segments();
  is( join(" | ", @segments), " | path_with_square_[brackets]", "segments");
}


{ #-- form/query related tests
  my $u = URI->new("http://root[user]@[::1]/path_with_square_[brackets]/segment[2]?par=value[1]&par[2]=value[2]#fragment[2]");

  is( $u->query_form(), "4", "scalar: query_form");
  is( join(" | ", $u->query_form()), "par | value[1] | par[2] | value[2]", "list: query_form");

  $u->query_form( {} );
  is( $u->query(), undef, "query removed");
  is( join(" | ", $u->query_form()), "", "list: query_form");
  is( $u->canonical(), "http://root%5Buser%5D@[::1]/path_with_square_%5Bbrackets%5D/segment%5B2%5D#fragment%5B2%5D", "query removed: canonical");

  $u->query_form( key1 => 'val1', key2 => 'val[2]' );
  is( $u->query(), "key1=val1&key2=val%5B2%5D", "query");
}


{ #-- path segments
  my $u = URI->new("http://root[user]@[::1]/path_with_square_[brackets]/segment[2]?par=value[1]#fragment[2]");
  my @segments = $u->path_segments();
  is( join(" | ", @segments), " | path_with_square_[brackets] | segment[2]", "segments");
}


{ #-- rel
  my $u = URI->new("http://root[user]@[::1]/oldbase/next/path_with_square_[brackets]/segment[2]?par=value[1]#fragment[2]");
  #TODO: is userinfo@ optional?
  is( $u->rel("http://root%5Buser%5D@[::1]/oldbase/next/")->canonical(),
      "path_with_square_%5Bbrackets%5D/segment%5B2%5D?par=value%5B1%5D#fragment%5B2%5D",
      "rel/canonical"
    );
}


{ #-- various setters
 my $ip6 = 'fedc:ba98:7654:3210:fedc:ba98:7654:3210';
 my $u = URI->new("http://\[" . uc($ip6) . "\]/index.html");
 is ($u->canonical(), "http://[$ip6]/index.html", "basic IPv6 URI");

 $u->scheme("https");
 is ($u->canonical(), "https://[$ip6]/index.html", "basic IPv6 URI");

 $u->userinfo("user[42]"); #-- tolerate unescaped '[', ']'
 is ($u->canonical(), "https://user%5B42%5D@[$ip6]/index.html", "userinfo added (unescaped)");
 is ($u->userinfo(), "user%5B42%5D", "userinfo is escaped");

 $u->userinfo("user%5B77%5D"); #-- already escaped
 is ($u->canonical(), "https://user%5B77%5D@[$ip6]/index.html", "userinfo replaced (escaped)");
 is ($u->userinfo(), "user%5B77%5D", "userinfo is escaped");

 $u->userinfo( q(weird.al$!:secret*[1]++) );
 is ($u->canonical(), "https://weird.al\$!:secret*%5B1%5D++@[$ip6]/index.html", "userinfo replaced (escaped2)");
 is ($u->userinfo(),  "weird.al\$!:secret*%5B1%5D++", "userinfo is escaped2");

 $u->userinfo( q(j.doe@example.com:secret) );
 is ($u->canonical(), "https://j.doe%40example.com:secret@[$ip6]/index.html", "userinfo replaced (escaped3)");
 is ($u->userinfo() , "j.doe%40example.com:secret", "userinfo is escaped3");

 $u->host("example.com");
 is ($u->canonical(), "https://j.doe%40example.com:secret\@example.com/index.html", "hostname replaced");

 $u->host("127.0.0.1");
 is ($u->canonical(), "https://j.doe%40example.com:secret\@127.0.0.1/index.html", "hostname replaced");

 for my $host ( qw(example.com 127.0.0.1)) {
   $u->host( $host );
   my $expect = "https://j.doe%40example.com:secret\@$host/index.html";
   is ($u->canonical(), $expect, "host: $host");
   is ($u->host(), $host, "same hosts ($host)");
 }

 for my $host6 ( $ip6, qw(::1) ) {
   $u->host( $host6 );
   my $expect = "https://j.doe%40example.com:secret\@[$host6]/index.html";
   is ($u->canonical(), $expect, "IPv6 host: $host6");
   is ($u->host(), $host6, "same IPv6 hosts ($host6)");
 }

 $u->host($ip6);
 $u->path("/subdir/index[1].html");
 is( $u->canonical(), "https://j.doe%40example.com:secret@[$ip6]/subdir/index%5B1%5D.html", "path replaced");

 $u->fragment("fragment[xyz]");
 is( $u->canonical(), "https://j.doe%40example.com:secret@[$ip6]/subdir/index%5B1%5D.html#fragment%5Bxyz%5D", "fragment added");

 $u->authority("user[doe]@[::1]");
 is( $u->canonical(), "https://user%5Bdoe%5D@[::1]/subdir/index%5B1%5D.html#fragment%5Bxyz%5D", "authority replaced");

 $u->authority("::1");
 is( $u->canonical(), "https://[::1]/subdir/index%5B1%5D.html#fragment%5Bxyz%5D", "authority replaced");

 $u->authority("[::1]:19999");
 is( $u->canonical(), "https://[::1]:19999/subdir/index%5B1%5D.html#fragment%5Bxyz%5D", "authority replaced");

 # $u->authority("::1:18000"); #-- theoretically, we could guess an [::1]:18000 ... but for now it will just be ill formatted.
 # is( $u->canonical(), "https://::1:18000/subdir/index%5B1%5D.html#fragment%5Bxyz%5D", "authority replaced");

 $u->authority("user[abc]\@::1");
 is( $u->canonical(), "https://user%5Babc%5D@[::1]/subdir/index%5B1%5D.html#fragment%5Bxyz%5D", "authority replaced");

 $u->authority("user[xyz]\@example.com\@[::1]:22022");
 is( $u->canonical(), "https://user%5Bxyz%5D%40example.com@[::1]:22022/subdir/index%5B1%5D.html#fragment%5Bxyz%5D", "authority replaced");

}

done_testing;
