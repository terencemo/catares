package catares::Controller::Room;
use Moose;
use namespace::autoclean;
use Date::Manip;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Room - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Room in Room.');
}

sub fields :Local {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my $bldg_id = $c->req->params->{building};
    $c->stash->{roomclasses} = $conn->get_building_roomclasses($bldg_id);
    $c->stash->{template} = 'room/fields.tt';
}

sub search :Local {
    my ( $self, $c ) = @_;

    return unless ('POST' eq $c->req->method());

    my $conn = $c->stash->{Connection};
    my %search_args = map {
        $_ => $c->req->params->{$_ . '_date'} . ' ' . $c->req->params->{$_ . '_time'}
    } qw(checkin checkout);
    $search_args{roomclass} = $c->req->params->{roomclass};
    my $err = "";
    my $delta = DateCalc(map {
        ParseDate($c->req->params->{$_})
    } qw(checkin_date checkout_date), \$err);
    my $days = sprintf("%d", Delta_Format($delta, 1, "%dh"));

    $c->stash->{days} = $days;
    $c->stash( {
        map { $_ => $search_args{$_} }
    qw(checkin checkout) } );
    $c->stash->{rooms} = $conn->search_rooms(%search_args);
    $c->stash->{timeslots} = $conn->get_timeslots();
    $c->stash->{amenities} = $conn->get_amenities();
    $c->stash->{quota} = $conn->get_quota($c->req->params->{quota})
        if $c->config->{quotas_enabled};
    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'room/search-results.tt';
}

sub id : Chained('/') PathPart('room') CaptureArgs(1) {
    my ( $self, $c, $room_id ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{room} = $conn->get_room($room_id);
}

sub cost :Chained('id') PathPart('cost') Args(0) {
    my ( $self, $c ) = @_;

    my $room = $c->stash->{room};
    my $conn = $c->stash->{Connection};
    my $roomcost = $room->roomclass->rate;
    my $mtype = $c->req->params->{'type'};
    my $dailymealcost = 0;
    foreach my $key (grep { m/^meal_/ } %{ $c->req->params }) {
        my ( $timeslot ) = $key =~ m/^meal_(\d+)$/;
        $c->log->debug("Key: $key, timeslot: $timeslot");
        my $meal = $conn->get_meal(
            timeslot    => $timeslot,
            type        => $mtype
        );
        $dailymealcost += $meal->rate;
    }
    my $qty = $c->req->params->{'qty'};
    my $dailycost = $roomcost + $qty * $dailymealcost;
    $c->res->body($dailycost);
}

sub book :Chained('/') PathPart('rooms/book') Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my ( $checkin, $checkout ) = map { $c->req->params->{"check$_"} } qw(in out);
    my $days = $c->req->params->{days};
    my $billing = $c->session->{billing};

    foreach my $key (grep { m/^rm_\d+$/ } %{$c->req->params}) {
        my ( $rid ) = $key =~ m/^rm_(\d+)$/;
        $c->log->debug("Room $rid selected");
        my %room_args = (
            checkin     => $checkin,
            checkout    => $checkout,
            room        => $rid,
            days        => $days
        );
        $room_args{billing} = $billing if $billing;

        my $room_bkg = $conn->book_room(%room_args);
        my $roomcost = $room_bkg->room->roomclass->rate * $days;
        $billing = $room_bkg->billing_id;

        my $qty = $c->req->params->{$key . "_qty"};
        my $pref = $c->req->params->{$key . "_pref"};
        my $timeslots = $c->req->params->{$key . "_meal"};
        if ($qty and $timeslots) {
            $timeslots = [ $timeslots ] unless 'ARRAY' eq ref($timeslots);
        }

        foreach my $ts (@$timeslots) {
            my $meal_bkg = $conn->book_meal(
                timeslot    => $ts,
                type        => $pref,
                booked_for  => 'Room',
                booking_id  => $room_bkg->id,
                count       => $qty,
                days        => $days
            );
            $roomcost += $meal_bkg->cost;
        }

        foreach my $akey (grep { m/^am_\d+$/ } %{$c->req->params} ) {
            my ( $aid ) = $akey =~ m/^am_(\d+)$/;
            my $count = $c->req->params->{$akey};
            my $am_bkg = $conn->book_room_amenity(
                booking => $room_bkg->id,
                amenity => $aid,
                count   => $count
            );
            $roomcost += $am_bkg->cost;
        }

        $conn->edit_room_booking(
            room    => $room_bkg,
            amount  => $roomcost
        );
    }

    $c->session->{billing} = $billing if $billing;

    $c->stash->{template} = 'blank.tt';
    if ('bill' eq $c->req->params->{form_action}) {
        $c->stash->{billing} = $conn->get_billing($billing);
        $c->res->redirect($c->uri_for('/book'));
    } else {
        $c->res->redirect($c->uri_for('/'));
    }
}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
