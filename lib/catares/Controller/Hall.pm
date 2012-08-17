package catares::Controller::Hall;
use Moose;
use namespace::autoclean;
use YAML 'Dump';

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

    my $conn = $c->stash->{Connection};
    my $bldg_id = $c->req->params->{building};
    $c->stash->{halls} = $conn->get_building_halls($bldg_id);
    $c->stash->{timeslots} = $conn->get_timeslots();
    $c->stash->{template} = 'hall/fields.tt';
}

sub search :Local {
    my ( $self, $c ) = @_;

    return unless ('POST' eq $c->req->method());

    my $conn = $c->stash->{Connection};
    my %parms = map {
        $_ => $c->req->params->{$_}
    } grep {
        $c->req->params->{$_}
    } qw(hall date timeslot);
    $c->stash->{halls} = $conn->search_halls(%parms);
    $c->stash->{amenities} = $conn->get_amenities();
    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'hall/search-results.tt';
}

sub add :Local {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};

    if ('POST' eq $c->req->method()) {
        
        my %args = map {
            $_ => $c->req->params->{$_}
        } qw(building name descr);

        my $hall;
        
        eval {
          $hall = $conn->create_hall(%args);
        };
        if ($@) {
            $c->log->debug("Unable to create hall: $@");
            return;           
        }

        $c->stash->{template} = 'hall/row.tt';
        $c->stash->{hall} = $hall;
    }
}

sub id : Chained('/') PathPart('hall') CaptureArgs(1) {
    my ( $self, $c, $hall_id ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{hall} = $conn->get_hall($hall_id);
}

sub cost :Chained('id') PathPart('cost') Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my $hall = $c->stash->{hall};
    my $timeslot = $c->req->params->{timeslot};
    my $hts = $conn->get_hall_timeslot(
        hall        => $hall->id,
        timeslot    => $timeslot
    );
    my $cost = $hts->rate;
    foreach my $type (qw(veg nonveg)) {
        my $qty = $c->req->params->{$type};
        if ($qty > 0) {
            my $meal = $conn->get_meal(
                type        => $type,
                timeslot    => $timeslot
            );
            $cost += $meal->rate * $qty;
        }
    }
    $c->res->body($cost);
}

sub edit :Chained('id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    if ('POST' eq $c->req->method()) {
        my %args = map {
            $_ => $c->req->params->{$_}
        } qw(hall name descr);

        my $hall;

        eval {
          $hall = $conn->edit_hall(%args);
        };
        if ($@) {
            $c->log->debug("Unable to create hall: $@");
            return;
        }

        $c->stash->{hall} = $hall;
        $c->stash->{template} = 'hall/row-data.tt';
        return;
    }
    $c->stash->{template} = 'hall/details.tt';
}

sub rates :Chained('id') PathPart('rates') Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my $timeslots = $conn->get_timeslots();
    my $hall = $c->stash->{hall};
    if ('POST' eq $c->req->method()) {
        my $mcount = 0;
        my $ts_rate;
        while (my $ts = $timeslots->next()) {
            next unless
                $ts_rate = $c->req->params->{$ts->name . '_rate'};
            my %parms = (
                timeslot    => $ts->id,
                hall        => $hall->id
            );
            my %search_parms = %parms;
            foreach my $tm (qw(start end)) {
                my $key = sprintf("%s_%s_time", $ts->name, $tm);
                $parms{$tm} = $c->req->params->{$key};
            }
            $parms{rate} = $ts_rate;
            my $htss;
            if ($htss = $conn->get_hall_timeslots(%search_parms) and $htss->count) {
                eval ++$mcount if $conn->edit_hall_timeslot(%parms);
                if ($@) {
                    $c->log->warn("Editing of ".$ts->name." timeslot failed: $@");
                }
            } else {
                eval ++$mcount if $conn->create_hall_timeslot(%parms);
                if ($@) {
                    $c->log->warn("Creation of " . $ts->name . " timeslot failed: $@");
                }
            }
        }
        if ($mcount) {
            $c->stash->{msg} = "$mcount timeslots saved successfully";
            if (4 == $mcount) {
                $conn->activate_hall(hall => $hall->id);
            }
        }
        $timeslots->reset();
    }

    $c->stash->{timeslots} = $timeslots;
    $c->stash->{halltimeslots} = $hall->halltimeslots;
    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'hall/rates.tt';
}

sub delete :Chained('id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;

}

sub book :Local {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my $billing = $c->session->{billing};

    my $hid = $c->req->params->{hall};
    $c->log->debug("Hall $hid selected");
    my %hall_args = map {
        $_ => $c->req->params->{$_}
    } qw(hall timeslot date);
    $hall_args{billing} = $billing if $billing;

    my $hall_bkg = $conn->book_hall(%hall_args);
    my $hallcost = $hall_bkg->halltimeslot->rate;
    $billing = $hall_bkg->billing_id;

    my $pre = "h_${hid}_";
    if ($c->req->params->{$pre . "meal"}) {
        $pre .= "qty_";
        foreach my $type (qw(veg nonveg)) {
            my $qty = $c->req->params->{$pre . $type};
            $c->log->debug("Booking $qty $type meals for hall");
            my $meal_bkg = $conn->book_meal(
                timeslot    => $hall_args{timeslot},
                type        => $type,
                booked_for  => 'Hall',
                booking_id  => $hall_bkg->id,
                count       => $qty,
                days        => 1
            );
            $hallcost += $meal_bkg->cost;
        }
    }

    foreach my $akey (grep { m/^am_\d+$/ } %{$c->req->params} ) {
        my ( $aid ) = $akey =~ m/^am_(\d+)$/;
        my $count = $c->req->params->{$akey};
        my $am_bkg = $conn->book_hall_amenity(
            booking => $hall_bkg->id,
            amenity => $aid,
            count   => $count
        );
        $hallcost += $am_bkg->cost;
    }

    $conn->edit_hall_booking(
        hall_booking    => $hall_bkg,
        amount          => $hallcost
    );

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
