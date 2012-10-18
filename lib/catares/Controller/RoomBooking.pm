package catares::Controller::RoomBooking;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::RoomBooking - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::RoomBooking in RoomBooking.');
}

sub edit_checkin :Local {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    if ('POST' eq $c->req->method()) {
        my $newtime = $c->req->params->{checkin_time};
        my $bid = $c->req->params->{billing_id};
        my $billing = $conn->get_billing($bid);
        my $roombookings = $billing->roombookings();
        my $old_checkin = $c->req->params->{checkin_orig};
        while (my $rb = $roombookings->next()) {
#            my $new_checkin;
            if ($rb->checkin eq $old_checkin) {
#                unless ($new_checkin) {
#                    ( $new_checkin = $old_checkin ) =~ s/ .*/ $newtime/ ;
#                }
                $conn->edit_rb_times($rb, $newtime);
            }
        }
    } else {
        $c->stash->{checkin} = $c->req->params->{checkin};
        $c->stash->{billing_id} = $c->req->params->{billing_id};
    }
    $c->stash->{template} = 'room/edit-checkin.tt';
}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
