package catares::Backend::Connection;
use Moose;
use catares::Schema;

has 'schema' => (
    is => 'ro',
    isa => 'catares::Schema'
);

has 'user' => (
    is => 'ro',
    isa => 'catares::Schema::Users');

has 'username' => (
    is => 'ro',
    isa => 'Str'
);

sub get_buildings {
    my $self = shift;

    $self->schema->resultset('Buildings')->search();
}

sub get_building_halls {
    my $self = shift;
    my $building_id = shift;

    $self->schema->resultset('Halls')->search( {
        building_id => $building_id
    } );
}

sub get_hall_timeslots {
    my $self = shift;
    my %args = @_;

    my $search_args = {
        hall_id => $args{hall_id}
    };
    $search_args->{timeslot_id} = $args{timeslot_id} if $args{timeslot_id};

    $self->schema->resultset('HallTimeSlots')->seach( $search_args );
}

sub get_hall_date_timeslot_bookings {
    my $self = shift;
    my %args = @_;

    $self->schema->resultset('HallBookings')->search( {
        halltimeslot_id => $args{halltimeslot_id},
        date            => $args{date}
    } );
}

sub get_hall_daterange_timeslots_bookings {
    my $self = shift;
    my %args = @_;

    $self->schema->resultset('HallBookings')->search( {
        'halltimeslot.hall_id' => $args{hall_id},
        'halltimeslot.timeslot_id' => $args{timeslots},
        '-and' => [
            date    => {
                '>=' => $args{startdt}
            },
            date    => {
                '<=' => $args{enddt}
            }
        ]
    } );
}

1;
