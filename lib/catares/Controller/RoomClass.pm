package catares::Controller::RoomClass;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::RoomClass - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::RoomClass in RoomClass.');
}

sub manage :Chained('/building/id') PathPart('roomclasses') {
    my ( $self, $c ) = @_;

    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'building/roomclasses.tt';
}

sub id : Chained('/') PathPart('roomclass') CaptureArgs(1) {
    my ( $self, $c, $rc_id ) = @_;

    $c->stash->{rc} = {
        name => 'Foo',
        descr => 'A room called foo'
    };
}

sub edit :Chained('id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'roomclass/details.tt';
}

sub delete :Chained('id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;

}

sub rooms :Chained('id') PathPart('rooms') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'roomclass/rooms.tt';
}

=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
