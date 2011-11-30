#!/usr/bin/perl

use catares::Backend;

my $b = catares::Backend->new( {
    connect_info => [ qw(dbi:mysql:catares catares catares) ]
} );

my $c = $b->login(
    name => "admin",
    passcode => "d033e22ae348aeb5660fc2140aec35850c4da997"
#    pass => "admin"
);

die "Login failed\n" unless $c;

my $bldgs = $c->get_buildings();

while (my $bldg = $bldgs->next()) {
    print "Building: " . $bldg->name . "\n";
}

