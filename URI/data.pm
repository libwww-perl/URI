package URI::data;  # RFC 2397

require URI;
@ISA=qw(URI);

use strict;

use MIME::Base64 qw(encode_base64 decode_base64);
use URI::Escape  qw(uri_unescape);

sub media_type
{
    my $self = shift;
    my $opaque = $self->opaque_part;
    $opaque =~ /^([^,]*),/;
    my $old = $1;
    my $base64;
    $base64 = $1 if $old =~ s/(;base64)$//i;
    if (@_) {
	my $new = shift;
	$new = "" unless defined $new;
	$base64 = "" unless defined $base64;
	$opaque =~ s/^[^,]*,?/$new$base64,/;
	$self->opaque_part($opaque);
    }
    $old || "text/plain;charset=US-ASCII";
}

sub data
{
    my $self = shift;
    my($enc, $data) = split(",", $self->opaque_part, 2);
    unless (defined $data) {
	$data = "";
	$enc  = "" unless defined $enc;
    }
    my $base64 = ($enc =~ /;base64$/i);
    if (@_) {
	$enc =~ s/;base64$//i if $base64;
	my $new = shift;
	$new = "" unless defined $new;
	my $uric_count = _uric_count($new);
	my $urienc_len = $uric_count + (length($new) - $uric_count) * 3;
	my $base64_len = int((length($new)+2) / 3) * 4;
	$base64_len += 7;  # because of ";base64" marker
	if ($base64_len < $urienc_len || $_[0]) {
	    $enc .= ";base64";
	    $new = encode_base64($new, "");
	}
	$self->opaque_part("$enc,$new");
    }
    return unless defined wantarray;
    return $base64 ? decode_base64($data) : uri_unescape($data);
}

# I could not find a better way to interpolate the tr/// chars from
# a variable.
eval <<EOT; die $@ if $@;
sub _uric_count
{
    \$_[0] =~ tr/$URI::uric//;
}
EOT

1;
