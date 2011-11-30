package catares::Controller::Building;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Building - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Building in Building.');
}

sub id : Chained('/') PathPart('building') CaptureArgs(1) {
    my ( $self, $c, $building_id ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{building} = $conn->get_building($building_id);
}

sub halls :Chained('id') PathPart('halls') {
    my ( $self, $c ) = @_;

    my $building = $c->stash->{building};
    $c->stash->{halls} = $building->halls;
    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'building/halls.tt';
}

sub roomclasses :Chained('id') PathPart('roomclasses') {
    my ( $self, $c ) = @_;

    my $building = $c->stash->{building};
    $c->stash->{roomclasses} = $building->roomclasses;
    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'building/roomclasses.tt';
}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
