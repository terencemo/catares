package catares::Controller::Hall;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Hall - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Hall in Hall.');
}

sub fields :Local {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'hall/fields.tt';
}

sub manage :Chained('/building/id') PathPart('halls') {
    my ( $self, $c ) = @_;

    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'hall/manage.tt';
}

sub id : Chained('/') PathPart('hall') CaptureArgs(1) {
    my ( $self, $c, $hall_id ) = @_;
}

sub edit :Chained('id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{hall} = { name => 'Foo', descr => 'A hall called foo' };
    $c->stash->{template} = 'hall/details.tt';
}

sub rates :Chained('id') PathPart('rates') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'hall/rates.tt';
}

sub delete :Chained('id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;

}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
