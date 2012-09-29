package catares::Controller::Billing;
use Moose;
use Lingua::EN::Numbers::Indian 'num2en';
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
        my $total = $c->req->params->{paid};
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

        my $paymode = $c->req->params->{paymode} || 'cash';
        if ('cheque' eq $paymode) {
            my %args = map {
                $_ => $c->req->params->{$_}
            } qw(bank branch cheque_no);
            $args{date} = $c->req->params->{cheque_date};
            $args{billing_id} = $billing->id;
            my $cheque = $conn->create_cheque(%args);
        }

        $conn->edit_billing($bid, $client_id,
            $charges, $deposit, $total, $discount, $paymode);
        $c->session->{billing} = undef;
        $c->res->redirect($c->uri_for('/billing', $billing->id, 'show'));
        return;
    }
    $c->stash->{billing} = $billing;
    $c->stash->{roombookings} = $billing->roombookings;
    $c->stash->{process_file} = 'bill.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

sub history :Local {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{billings} = $conn->get_billings();

    $c->stash->{process_file} = 'billing/history.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

sub id :Chained('/') PathPart('billing') CaptureArgs(1) {
    my ( $self, $c, $bill_id ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{billing} = $conn->get_billing($bill_id);
}

sub show :Chained('id') PathPart('show') Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my $roles = $c->stash->{roles};
    my $billing = $c->stash->{billing};
    if (!grep { $_ eq 'Manager' } @$roles and $billing->booked_by != $conn->user->id) {
        $c->stash->{process_file} = 'access-violation.tt';
    } else {
        $c->stash->{process_file} = 'billing/show.tt';
    }
    $c->stash->{words} = uc(num2en($billing->total));
    $c->stash->{includes} = [ 'wufoo' ];
}

sub billings :Global {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{billings} = $conn->get_all_billings();
    $c->stash->{process_file} = 'billing/all.tt';
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
