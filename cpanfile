on 'configure' => sub {
    requires "ExtUtils::MakeMaker" => "0";
    suggests "JSON::PP" => "2.27300";
};

on 'develop' => sub {
    requires "Test::CPAN::Changes" => "0.19";
    recommends 'Business::ISBN' => 0;
    recommends "Storable" => "0";
};

on 'runtime' => sub {
    requires "Carp" => "0";
    requires "Cwd" => "0";
    requires "Data::Dumper" => "0";
    requires "Encode" => "0";
    requires "Exporter" => "5.57";
    requires "MIME::Base64" => "2";
    requires "Net::Domain" => "0";
    requires "Scalar::Util" => "0";
    requires "constant" => "0";
    requires "integer" => "0";
    requires "overload" => "0";
    requires "parent" => "0";
    requires "perl" => "5.008001";
    requires "strict" => "0";
    requires "warnings" => "0";
    requires "utf8" => '0';
};

on 'test' => sub {
    requires "File::Spec::Functions" => "0";
    requires "File::Temp" => "0";
    requires "Test" => "0";
    requires "Test::More" => "0.96";
    requires "Test::Needs" => '0';
    requires "utf8" => "0";
};
