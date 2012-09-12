package catares::Controller::Booking;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Booking - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Booking in Booking.');
}

sub book :Global {
    my ( $self, $c ) = @_;

    my $bid = $c->session->{billing};
    my $conn = $c->stash->{Connection};
    my $billing = $conn->get_billing($bid);
    my $includes = [ 'wufoo' ];
    if ('POST' eq $c->req->method()) {
        my $cl_id;
        if ($cl_id = $c->req->params->{client_id}) {
            $c->log->debug("Got client");
            $c->session->{client_id} = $cl_id;
        }
        foreach my $field (qw(fullname phone address)) {
            $c->stash->{$field} =
            $c->session->{"billing.$field"} = $c->req->params->{$field};
        }
        $c->stash->{process_file} = 'bill.tt';
    } else {
        foreach my $field (qw(fullname phone address)) {
            $c->stash->{$field} = $c->session->{"billing.$field"};
        }
        $c->stash->{process_file} = 'book.tt';
        push(@$includes, 'lightbox');
    }
    $c->stash->{includes} = $includes;
    $c->stash->{billing} = $billing;
    $c->stash->{roombookings} = $billing->roombookings;
}


=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
