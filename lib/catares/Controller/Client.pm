package catares::Controller::Client;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Client - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Client in Client.');
}

sub search :Local {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    if ('POST' eq $c->req->method()) {
        my $cli_id = $c->req->params->{client};
        my $client = $conn->get_client($cli_id);
        $c->stash->{client} = {
            id  => $cli_id,
            fullname => $client->fullname,
            address => $client->address,
            phone => $client->phone
        };
        delete $c->stash->{Connection};
        $c->forward($c->view('JSON'));
        return 0;
    }
    $c->stash->{clients} = $conn->get_clients();
    $c->stash->{template} = 'client/search.tt';
}

=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
