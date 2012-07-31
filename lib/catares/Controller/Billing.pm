package catares::Controller::Billing;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Billing - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Billing in Billing.');
}

sub bill :Global {
    my ( $self, $c ) = @_;

    my $bid = $c->session->{billing};
    my $conn = $c->stash->{Connection};
    my $billing = $conn->get_billing($bid);
    foreach my $field (qw(fullname phone address)) {
        $c->stash->{$field} = $c->session->{"billing.$field"};
    } 
    if ('POST' eq $c->req->method()) {
        my $charges = $c->req->params->{charges};
        my $deposit = $c->req->params->{deposit};
        my $total = $c->req->params->{total};
        my $discount = $c->req->params->{discount};

        my $client_id = $c->session->{client_id};
        unless ($client_id) {
            my $args = {
                map {
                    $_  =>  $c->session->{"billing.$_"}
                } qw(fullname phone address)
            };

            my $client = $conn->create_client(%$args);
            $client_id = $client->id;
            $c->session->{client_id} = $client_id;
        }

        $conn->edit_billing($bid, $client_id,
            $charges, $deposit, $total, $discount);
        $c->session->{billing} = undef;
        $c->res->redirect($c->uri_for('/'));
        return;
    }
    $c->stash->{billing} = $billing;
    $c->stash->{roombookings} = $billing->roombookings;
    $c->stash->{process_file} = 'bill.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
