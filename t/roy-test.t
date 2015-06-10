use strict;
use warnings;

use Test qw(plan ok);
plan tests => 102;

use URI;
use File::Spec::Functions qw(catfile);

my $no = 1;

my @prefix;
push(@prefix, "t") if -d "t";

for my $i (1..5) {
   my $file = catfile(@prefix, "roytest$i.html");

   open(FILE, $file) || die "Can't open $file: $!";
   print "# $file\n";
   my $base = undef;
   while (<FILE>) {
       if (/^<BASE href="([^"]+)">/) {
           $base = URI->new($1);
       } elsif (/^<a href="([^"]*)">.*<\/a>\s*=\s*(\S+)/) {
           die "Missing base at line $." unless $base;	    
           my $link = $1;
           my $exp  = $2;
           $exp = $base if $exp =~ /current/;  # special case test 22

	   # rfc2396bis restores the rfc1808 behaviour
	   if ($no == 7) {
	       $exp = "http://a/b/c/d;p?y";
           }
	   elsif ($no == 48) {	
	       $exp = "http://a/b/c/d;p?y";
	   }

	   ok(URI->new($link)->abs($base), $exp);

           $no++;
       }
   }
   close(FILE);
}
