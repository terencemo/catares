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

sub create_building {
    my $self = shift;
    my %args = @_;

    $self->schema->resultset('Buildings')->create( {
        name => $args{name}
    } );
}

sub get_building {
    my $self = shift;

    $self->schema->resultset('Buildings')->find(shift);
}

sub get_buildings {
    my $self = shift;

    $self->schema->resultset('Buildings')->search();
}

sub create_hall {
    my $self = shift;
    my %args = @_;

    $self->schema->resultset('Halls')->create( {
        building_id => $args{building},
        name        => $args{name},
        descr       => $args{descr}
    } );
}

sub get_hall {
    my ( $self, $hall_id ) = @_;

    $self->schema->resultset('Halls')->find($hall_id);
}

sub get_building_halls {
    my $self = shift;
    my $building_id = shift;

    $self->schema->resultset('Halls')->search( {
        building_id => $building_id
    } );
}

sub edit_hall {
    my $self = shift;
    my %args = @_;

    my $hall_id = $args{hall} or die("Need hall id to edit");
    my $hall = $self->schema->resultset('Halls')->find($hall_id);

    my $parms = { map { $_ => $args{$_} } qw(name descr) };
    $hall->update($parms);
}

sub delete_hall {
    my $self = shift;
    my %args = @_;

    my $hall_id = $args{hall} or die("Need hall id to delete");
    my $hall = $self->schema->resultset('Halls')->find($hall_id)
        or die("Unable to load hall $hall_id. Does it exist?");
    $hall->delete;
}

sub create_hall_timeslot {
    my $self = shift;
    my %args = @_;

    $self->schema->resultset('HallTimeSlots')->create( {
        hall_id     => $args{hall},
        timeslot_id => $args{timeslot},
        start       => $args{start},
        end         => $args{end},
        rate        => $args{rate}
    } );
}

sub get_hall_timeslots {
    my $self = shift;
    my %args = @_;

    my $search_args = {
        hall_id => $args{hall}
    };
    $search_args->{timeslot_id} = $args{timeslot} if $args{timeslot};

    $self->schema->resultset('HallTimeSlots')->search( $search_args );
}

sub edit_hall_timeslot {
    my $self = shift;
    my %args = @_;

    my $halltimeslot = undef;
    if ($args{id}) {
        $halltimeslot = $self->schema->resultset('HallTimeSlots')->find($args{id});
    } elsif ($args{hall} and $args{timeslot}) {
        $halltimeslot = $self->schema->resultset('HallTimeSlots')->search( {
            hall_id     => $args{hall},
            timeslot_id => $args{timeslot}
        } )->first;
    }
    die("Couldn't load hall timeslot. Need valid id or hall+timeslot ids")
        unless $halltimeslot;

    my $parms = { map { $_ => $args{$_} } qw(start end rate) };

    $halltimeslot->update($parms);
}

sub create_roomclass {
    my $self = shift;
    my %args = @_;

    my %parms = map { $_ => $args{$_} } qw(name rate descr);
    $self->schema->resultset('RoomClasses')->create( {
        building_id => $args{building},
        %parms
    } ) or die("Unable to create roomclass");
}

sub get_building_roomclasses {
    my $self = shift;
    my %args = @_;

    my $building_id = $args{building} or die("Building id required");
    my $building = $self->schema->resultset('Building')->find($building_id)
        or die("Unable to load building #$building_id. Does it exist?");
    return $building->roomclasses;
}

sub get_roomclass {
    my ( $self, $rc_id ) = @_;

    die("Need roomclass_id as 2nd argument") unless $rc_id;

    $self->schema->resultset('RoomClasses')->find($rc_id)
        or die("Unable to get roomclass $rc_id. Does it exist?");
}

sub edit_roomclass {
    my $self = shift;
    my %args = @_;

    my $rc_id = $args{rc} or die("Room class id required");

    my $rc = $self->schema->resultset('RoomClasses')->find($rc_id)
        or die("Unable to load room class $rc_id");

    my $parms = { map { $_ => $args{$_} } qw(name rate descr) };
    $rc->update($parms);
}

sub create_room {
    my $self = shift;
    my %args = @_;

    my $rc_id = $args{roomclass} or die("roomclass is required");
    my $num = $args{number} or die("room number is required");
    $self->schema->resultset('Rooms')->create( {
        roomclass_id    => $rc_id,
        number          => $num
    } );
}

sub get_room {
    my $self = shift;
    my $room_id = shift or die("room id is needed as 2nd argument");

    $self->schema->resultset('Rooms')->find($room_id);
}

sub edit_room {
    my $self = shift;
    my %args = @_;

    my $room_id = $args{id} or die("Room id is required");
    my $num = $args{number} or die("Room number is required");

    my $room = $self->schema->resultset('Rooms')->find($room_id)
        or die("No room with id $room_id");
    $room->update( {
        number => $num
    } );
}

sub delete_room {
    my ( $self, $room_id ) = @_;

    my $room = $self->schema->resultset('Rooms')->find($room_id)
        or die("No room with id $room_id");

    $room->delete;
}

sub create_amenity {
    my $self = shift;
    my %args = @_;
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

sub get_timeslots {
    my $self = shift;

    $self->schema->resultset('TimeSlots')->search();
}

1;
