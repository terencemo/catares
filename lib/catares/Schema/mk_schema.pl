#!/usr/bin/perl

use strict;
use warnings;

my $opt;
do {
    print "Enter class name: ";
    chomp(my $class = <STDIN>);
    my $file = "$class.pm";
    print "Creating file $file\n";
    open(my $fh, ">$file");
    my $cname = "catares::Schema::$class";
    print $fh "package $cname;\n";
    print $fh "use base qw/DBIx::Class/;\n\n";
    print $fh "__PACKAGE__->load_components(qw/PK::Auto Core/);\n";
    my $tname = lc($class);
    print $fh "__PACKAGE__->table('$tname');\n";
    print $fh "__PACKAGE__->add_columns(\n";
    print "Primary key id? ";
    chomp(my $pko = <STDIN>);
    my $pk = 0;
    if ($pko !~ m/^n/i) {
        print $fh "                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        }";
        $pk = 1;
    }
    my $getco = sub {
        print "Add another column? ";
        chomp(my $cho = <STDIN>);
        return $cho;
    };
    my $co = &$getco;
    while ($co !~ m/^n$/i) {
        if ($co =~ m/^y$/i) {
            print "Column name: ";
            chomp($co = <STDIN>);
        }
        print "Data type: ";
        chomp(my $type = <STDIN>);
        print $fh ",
                        $co => {
                            data_type => '$type'";
        if ($type =~ m/^v/) {
            print "Size: ";
            chomp(my $sz = <STDIN>);
            print $fh ",
                            size => $sz\n";
        }
        print $fh "\n                        }";
        $co = &$getco;
    }
    print $fh "\n);\n\n";
    print $fh "__PACKAGE__->set_primary_key('id');" if $pk;
    print $fh "\n\n1;\n";
    close($fh);
    print "Another class? ";
    chomp($opt = <STDIN>);
} while ($opt !~ m/^n/i);
