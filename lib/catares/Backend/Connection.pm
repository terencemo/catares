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

sub create_meal {
    my $self = shift;
    my %args = @_;

    my $parms = { map { $_ => $args{$_} } qw(type rate) };
    die("type should be veg or nonveg")
        unless ($parms->{type} =~ m/^(?:non|)veg$/);
    $parms->{timeslot_id} = $args{timeslot}
        or die("timeslot required for meal");
    $self->schema->resultset('Meals')->create($parms)
        or die("Unable to create meal: $@");
}

sub get_meal {
    my $self = shift;
    my %args = @_;

    die("type should be veg or nonveg")
        unless ($args{type} =~ m/^(non|)veg$/);
    my $rs = $self->schema->resultset('Meals')->search( {
        timeslot_id => $args{timeslot},
        type        => $args{type}
    } );

    return $rs->first if $rs;
}

sub get_meals {
    my $self = shift;

    $self->schema->resultset('Meals')->search();
}

sub edit_meal {
    my $self = shift;
    my %args = @_;

    my $parms = { map { $_ => $args{$_} } qw(type rate) };
    die("type should be veg or nonveg")
        unless ($parms->{type} =~ m/^(?:non|)veg$/);
    $parms->{timeslot_id} = $args{timeslot}
        or die("timeslot required for meal");
    $self->schema->resultset('Meals')->update($parms)
        or die("Unable to edit meal: $@");
}

sub delete_meal {
    my $self = shift;
    my %args = @_;

    if ($args{type} and $args{timeslot}) {
        die("type should be veg or nonveg")
            unless ($args{type} =~ m/^(non|)veg$/);
        my $rs = $self->schema->resultset('Meals')->search( {
            timeslot_id => $args{timeslot},
            type        => $args{type}
        } );
        my $meal = $rs->first or
            die ("Can't find meal ts:".$args{timeslot}.", type:".$args{type});
        eval $meal->delete;
        if ($@) {
            die ("Unable to delete meal: $@");
        }
    }
}

sub create_amenity {
    my $self = shift;
    my %args = @_;

    my $parms = { map {
        $_ => $args{$_}
    } qw(name rate for_hall for_room) };

    $self->schema->resultset('Amenities')->create($parms)
        or die("Could not create amenity: $@");
}

sub get_amenity {
    my ( $self, $aid ) = @_;

    $self->schema->resultset('Amenities')->find($aid);
}

sub get_amenities {
    my $self = shift;

    $self->schema->resultset('Amenities')->search();
}

sub edit_amenity {
    my $self = shift;
    my %args = @_;

    my $aid = delete $args{id} or die("amenity id required for edit");
    my $amenity = $self->get_amenity($aid);
    my $parms = { map {
        $_ => $args{$_}
    } grep { $args{$_ } } qw(name rate for_hall for_room) };
    $amenity->update($parms);
}

sub delete_amenity {
    my ( $self, $aid ) = @_;

    die("Need amenity id to delete") unless $aid;
    my $amenity = $self->schema->resultset('Amenities')->find($aid)
        or die("Couldn't find amenity with id $aid");
    $amenity->delete;
}

1;
