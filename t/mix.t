print "1..5\n";

# Test mixing of URI and URI::WithBase objects
use URI;
use URI::WithBase;
use URI::URL;

$str = "http://www.sn.no";
$rel = "path/img.gif";

$u  = URI->new($str);
$uw = URI::WithBase->new($str, "http:");
$uu = URI::URL->new($str);

sub Dump
{
   require Data::Dumper;
   print Data::Dumper->Dump([$a, $b, $c, $d], [qw(a b c d)]);
}

$a = URI->new($rel, $u);
$b = URI->new($rel, $uw);
$c = URI->new($rel, $uu);
$d = URI->new($rel, $str);

#Dump();
print "not " unless $a->isa("URI") &&
                    ref($b) eq "URI::WithBase" &&
                    ref($c) eq "URI::URL" &&
                    $d->isa("URI");
print "ok 1\n";

$a = URI::URL->new($rel, $u);
$b = URI::URL->new($rel, $uw);
$c = URI::URL->new($rel, $uu);
$d = URI::URL->new($rel, $str);

$a = URI->new($uu, $u);
$b = URI->new($uu, $uw);
$c = URI->new($uu, $uu);
$d = URI->new($uu, $str);

$a = URI::URL->new($u, $u);
$b = URI::URL->new($u, $uw);
$c = URI::URL->new($u, $uu);
$d = URI::URL->new($u, $str);

