package catares::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::User in User.');
}

sub id :Chained('/') PathPart('user') CaptureArgs(1) {
    my ( $self, $c, $uid ) = @_;

    $c->stash->{uid} = $uid;
}

sub billings :Chained('id') PathPart('billings') Args(0) {
    my ( $self, $c ) = @_;

    my $uid = $c->stash->{uid};
    my $conn = $c->stash->{Connection};
    $c->stash->{user} = $conn->get_user($uid);
    $c->stash->{billings} = $conn->get_user_billings($uid);
    $c->stash->{template} = 'reports/user-billings.tt';
}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
