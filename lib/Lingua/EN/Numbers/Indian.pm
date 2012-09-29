package Lingua::EN::Numbers::Indian;

use warnings;
use base 'Lingua::EN::Numbers';

require Exporter;
@ISA = qw(Exporter);

use strict;
BEGIN { *DEBUG = sub () {0} unless defined &DEBUG } # setup a DEBUG constant
use vars qw( @EXPORT @EXPORT_OK $VERSION );
$VERSION = '1.04';
@EXPORT    = ();
@EXPORT_OK = qw( num2en );

sub num2en {
    my $n = shift;

    my $dec;
    ( $dec = $n ) =~ s/[^.]*//;
    $dec ||= 0;
    $n = int($n);
    if ($n >= 1e+7) {
        my $y = int($n / 1e+7);
        my $x = $n % 1e+7 + $dec;
        my $sx = $x ? ", " . num2en($x) : "";
        return Lingua::EN::Numbers::num2en($y) . " crore$sx";
    } elsif ($n >= 1e+5) {
        my $y = int($n / 1e+5);
        my $x = $n % 1e+5 + $dec;
        my $sx = $x ? ", " . Lingua::EN::Numbers::num2en($x) : "";
        return Lingua::EN::Numbers::num2en($y) . " lakh$sx";
    } else {
        return Lingua::EN::Numbers::num2en($n + $dec);
    }
}

1;
