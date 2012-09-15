package catares::Controller::Quota;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Quota - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 id

=cut

sub id :Chained('/') PathPart('quota') CaptureArgs(1) {
    my ( $self, $c, $qid ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{quota} = $conn->get_quota($qid);
}

sub get :Chained('id') PathPart('get') Args(0) {
    my ( $self, $c ) = @_;

    delete $c->stash->{Connection};
    $c->forward($c->view('JSON'));
    return 0;
}

sub get_quotas :Global {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{quotas} = $conn->get_quotas();
    delete $c->stash->{Connection};
    $c->forward($c->view('JSON'));
    return 0;
}

=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
