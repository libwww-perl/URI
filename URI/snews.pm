package URI::snews;  # draft-gilman-news-url-01

use strict;
use warnings;

require URI::news;
our @ISA=qw(URI::news);

sub default_port { 563 }

sub secure { 1 }

1;
