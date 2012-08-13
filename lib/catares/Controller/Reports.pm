package catares::Controller::Reports;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Reports - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{process_file} = 'reports.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

sub days_meals :Local {
    my ( $self, $c ) = @_;

    if (my $date = $c->req->params->{date}) {
        my $conn = $c->stash->{Connection};
        $c->stash->{timeslots} = $conn->get_timeslots();
        $c->stash->{mealcounts} = $conn->get_days_meals($date);
        $c->stash->{roommealcounts} = $conn->get_days_room_meals($date, $c->log);
        $c->stash->{date} = $date;
    }
    $c->stash->{process_file} = 'reports/days-meals.tt';
    $c->stash->{includes} = [ 'wufoo', 'calendar' ];
}

sub hall_bookings :Local {
    my ( $self, $c ) = @_;

    if (my $date = $c->req->params->{date}) {
        my $conn = $c->stash->{Connection};
        $c->stash->{hbs} = $conn->get_hall_bookings($date);        
        $c->stash->{date} = $date;
    }
    $c->stash->{process_file} = 'reports/hall-bookings.tt';
    $c->stash->{includes} = [ 'wufoo', 'calendar' ];
}

sub room_bookings :Local {
    my ( $self, $c ) = @_;

    if (my $date = $c->req->params->{date}) {
        my $conn = $c->stash->{Connection};
        $c->stash->{rbs} = $conn->get_room_bookings($date);
        $c->stash->{date} = $date;
    }
    $c->stash->{process_file} = 'reports/room-bookings.tt';
    $c->stash->{includes} = [ 'wufoo', 'calendar' ];
}

sub all_bookings :Local {
    my ( $self, $c ) = @_;
    $c->stash->{process_file} = 'reports/all-bookings.tt';
    $c->stash->{includes} = [ 'wufoo', 'calendar' ];
}

sub daily_hall_bookings :Local {
    my ( $self, $c ) = @_;

    my $date = $c->req->params->{date};
    my $conn = $c->stash->{Connection};
    $c->stash->{hbs} = $conn->get_hall_bookings($date);
    $c->stash->{template} = 'reports/daily-hall-bookings.tt';
}

sub daily_room_bookings :Local {
    my ( $self, $c ) = @_;

    my $date = $c->req->params->{date};
    my $conn = $c->stash->{Connection};
    $c->stash->{rbs} = $conn->get_room_bookings($date);
    $c->stash->{template} = 'reports/daily-room-bookings.tt';
}

sub collections :Local {
    my ( $self, $c ) = @_;

#    if (my $uid = $c->req->params->{uid}) {
#        $c->stash->{billings} = $conn->get_user_billings($uid);
#        $c->stash->{date} = $date;
#    }
    my $conn = $c->stash->{Connection};
    $c->stash->{users} = $conn->get_booking_users();        
    $c->stash->{process_file} = 'reports/collections.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
