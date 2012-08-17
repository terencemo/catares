package catares::Backend::Connection;
use POSIX;
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

sub get_roles {
    my $self = shift;

    $self->schema->resultset('Roles')->search( {
        'users.user_id' => $self->user->id
    }, {
        join    => [ 'users' ],
    } );
}

sub get_role_array {
    my $self = shift;

    my $rs = $self->get_roles();
    my $ra = [];
    while (my $role = $rs->next()) {
        push(@$ra, $role->name);
    }
    return $ra;
}

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
        building_id => $building_id,
        active  => 1
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

sub activate_hall {
    my $self = shift;
    my %args = @_;

    my $hall_id = $args{hall} or die("Need hall id to edit");
    my $hall = $self->schema->resultset('Halls')->find($hall_id);

    $hall->update( { active => 1 } );
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

sub get_hall_timeslot {
    my $self = shift;
    my %args = @_;

    my $search_args = {
        hall_id     => $args{hall},
        timeslot_id => $args{timeslot}
    };

    my $hts = $self->schema->resultset('HallTimeSlots')->search( $search_args )
        or die("No matches for timeslot, hall");
    return $hts->first;
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
    my ( $self, $building_id ) = @_;

    die("Building id required") unless $building_id;
    my $building = $self->schema->resultset('Buildings')->find($building_id)
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
    die("timeslot is mandatory") unless $args{timeslot};
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
    $parms->{multiple} = $args{multiple} if $args{multiple};

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
    } grep { defined $args{$_ } } qw(name rate for_hall for_room multiple) };
    $amenity->update($parms);
}

sub delete_amenity {
    my ( $self, $aid ) = @_;

    die("Need amenity id to delete") unless $aid;
    my $amenity = $self->schema->resultset('Amenities')->find($aid)
        or die("Couldn't find amenity with id $aid");
    $amenity->delete;
}

sub search_halls {
    my $self = shift;
    my %args = @_;

    my $search_args = {
        'halltimeslot.timeslot_id'  => $args{timeslot},
        date                        => $args{date}
    };
    my $bkgs = $self->schema->resultset('HallBookings')->search($search_args, {
        join    => [ 'halltimeslot' ],
        select  => [ 'halltimeslot.hall_id' ],
        as      => [ 'hall_id' ],
        group_by    => [ 'halltimeslot.hall_id' ]
    } );

    my $booked_hids = [];
    while (my $bkg = $bkgs->next()) {
        push(@$booked_hids, $bkg->get_column('hall_id'));
    }

    $search_args = {
        id  => { '-not_in'  => $booked_hids }
    };

    if ($args{hall}) {
        $search_args = {
            -and    => [ %$search_args,
                id  => $args{hall}
            ]
        };
    }

    $search_args->{active} = 1;

    $self->schema->resultset('Halls')->search($search_args);
}

sub search_rooms {
    my $self = shift;
    my %args = @_;

    my $bkgs = $self->schema->resultset('RoomBookings')->search( {
        'room.roomclass_id' => $args{roomclass},
        '-or'   => [
            '-and'  => [
                'checkin'  => { '<='   => $args{checkin} },
                'checkout' => { '>'    => $args{checkin} }
            ],
            '-and'  => [
                'checkin'  => { '>='   => $args{checkin} },
                'checkin'  => { '<'    => $args{checkout} }
            ]
        ]
    }, {
        join    => [ 'room' ],
        select  => [ 'room.id' ],
        as      => [ 'rid' ],
        group_by    => [ 'room.id' ]
    } );

    my $booked_rids = [];
    while (my $bkg = $bkgs->next()) {
        push(@$booked_rids, $bkg->get_column('rid'));
    }

    $self->schema->resultset('Rooms')->search( {
        roomclass_id    => $args{roomclass},
        id              => { '-not_in'  => $booked_rids }
    } );
}

sub book_meal {
    my $self = shift;
    my %args = @_;
    
    my $meal = $self->get_meal(
        timeslot    => $args{timeslot},
        type        => $args{type}
    );

    my $parms = { map { $_ => $args{$_} } qw(booked_for booking_id count) };
    my $days = $args{days} || 1;
    $parms->{cost} = $meal->rate * $args{count} * $days;
    $parms->{meal_id} = $meal->id;

    $self->schema->resultset('MealBookings')->create($parms);
}

sub book_hall {
    my $self = shift;
    my %args = @_;

    my $parms = { date    => $args{date} };
    my $hts_id = $args{halltimeslot};
    unless ($hts_id) {
        my $hall = $args{hall} or die("Hall is required");
        my $timeslot = $args{timeslot} or die("Timeslot is required");
        my $hts = $self->get_hall_timeslot(
            hall        => $hall,
            timeslot    => $timeslot
        ) or die("Can't get hall timeslot for hall $hall and timeslot $timeslot");
        $hts_id = $hts->id;
    }
    $parms->{halltimeslot_id} = $hts_id;

    unless ($parms->{billing_id} = $args{billing}) {
        my $billing = $self->schema->resultset('Billings')->create({});
        $parms->{billing_id} = $billing->id;
    }

    $self->schema->resultset('HallBookings')->create($parms);
}

sub book_room {
    my $self = shift;
    my %args = @_;

    my $parms = {
        room_id     => $args{room},
        checkin     => $args{checkin},
        checkout    => $args{checkout},
        days        => $args{days}
    };

    unless ($parms->{billing_id} = $args{billing}) {
        my $billing = $self->schema->resultset('Billings')->create({});
        $parms->{billing_id} = $billing->id;
    }

    my $room_bkg = $self->schema->resultset('RoomBookings')->create($parms);
}

sub edit_hall_booking {
    my $self = shift;
    my %args = @_;

    my $hbkg;
    if ($hbkg = $args{hall_booking}) {
        delete $args{hall_booking};
    } else {
        my $hid = delete $args{id} or die("Can't find hall booking: need id");
        $hbkg = $self->schema->resultset('HallBookings')->find($args{id});
    }

    my $parms = {
        map { $_ => $args{$_} }
        grep { $args{$_} } qw(date amount)
    };

    $hbkg->update($parms);
}

sub edit_room_booking {
    my $self = shift;
    my %args = @_;

    my $room;
    if ($room = $args{room}) {
        delete $args{room};
    } else {
        my $rid = delete $args{id} or die("Can't find room: need id");
        $room = $self->schema->resultset('RoomBookings')->find($args{id});
    }

    my $parms = {
        map { $_ => $args{$_} }
        grep { $args{$_} } qw(checkin checkout amount)
    };

    $room->update($parms);
}

sub book_room_amenity {
    my $self = shift;
    my %args = @_;

    my $parms = {
        amenity_id      => $args{amenity},
        roombooking_id  => $args{booking},
        count           => $args{count}
    };
    my $am = $self->get_amenity($args{amenity});
    $parms->{cost} = $am->rate * $args{count};
        
    $self->schema->resultset('RoomAmenityBookings')->create($parms);
}

sub book_hall_amenity {
    my $self = shift;
    my %args = @_;

    my $parms = {
        amenity_id      => $args{amenity},
        hallbooking_id  => $args{booking},
        count           => $args{count}
    };
    my $am = $self->get_amenity($args{amenity});
    $parms->{cost} = $am->rate * $args{count};
        
    $self->schema->resultset('HallAmenityBookings')->create($parms);
}

sub get_billing {
    my ( $self, $billing_id ) = @_;
    
    $self->schema->resultset('Billings')->find($billing_id);
}

sub create_client {
    my $self = shift;
    my %args = @_;

    my $parms = {
        fullname    => $args{fullname}
    };

    $parms->{phone} = $args{phone} if $args{phone};
    $parms->{address} = $args{address} if $args{address};

    $self->schema->resultset('Clients')->create($parms);
}

sub edit_billing {
    my ( $self, $billing_id, $client_id, $charges, $deposit, $total, $discount ) = @_;

    my $parms = {};
    $parms->{booked_by} = $self->user->id;
    $parms->{created} = strftime("%Y-%m-%d %T", localtime(time));
    $parms->{client_id} = $client_id;
    $parms->{charges} = $charges;
    $parms->{deposit} = $deposit ||= $charges * 0.25;
    $parms->{total} = $total;
    $parms->{discount} = $discount ||= 0;
    $self->get_billing($billing_id)->update($parms);
}

sub get_days_meals {
    my ( $self, $date ) = @_;

    $self->get_days_hall_meals($date);
}

sub get_days_hall_meals {
    my ( $self, $date ) = @_;

    my $rs = $self->schema->resultset('MealBookings')->search( {
        booked_for          =>  'Hall',
        'hallbooking.date'  =>  "$date 00:00:00"
    }, {
        join    => [ 'hallbooking', 'meal' ],
        select  => [ 'meal.timeslot_id', 'meal.type', { sum => 'count' } ],
        as      => [ 'timeslot', 'mealtype', 'count' ],
        group_by    =>  [ 'meal.timeslot_id', 'meal.type' ]
    } );

    my $mc = {};
    while (my $row = $rs->next()) {
        my $ts_id = $row->get_column('timeslot');
        $mc->{$ts_id}->{$row->get_column('mealtype')} = $row->get_column('count');
    }

    return $mc;
}

sub get_days_room_meals {
    my ( $self, $date, $log ) = @_;

    my $ts = $self->get_timeslots();
    my $mealtimes = {};
    my $mta = [];
    my $lasttime = "00:00:00";
    while (my $slot = $ts->next()) {
        $mealtimes->{$slot->name} = $slot->time;
        push(@$mta, {
            id => $slot->id,
            stime => $lasttime,
            etime => $slot->time,
            name => $slot->name
        } );
        $lasttime = $slot->time;
    }
    push(@$mta, {
        stime => $lasttime,
        etime => "23:59:59",
        name => "last"
    } );

    my $rs = $self->schema->resultset('MealBookings')->search( {
        booked_for              =>  'Room',
        'roombooking.checkin'   =>  {
            '<' => $date
        },
        'roombooking.checkout'   =>  {
            '>' => "$date 23:59:59"
        }
    }, {
        join    => [ 'roombooking', 'meal' ],
        select  => [ 'meal.timeslot_id', 'meal.type', { sum => 'count' } ],
        as      => [ 'timeslot', 'mealtype', 'count' ],
        group_by    =>  [ 'meal.timeslot_id', 'meal.type' ]
    } );

    my $mc = {};
    while (my $row = $rs->next()) {
        my $ts_id = $row->get_column('timeslot');
        $mc->{$ts_id}->{$row->get_column('mealtype')} = 
            $row->get_column('count');
    }

    my $starttimes = {};
    my $endtimes = {};
    my $startset = {};
    my $endset = {};
    my $unionset = {};
    foreach my $i (0..(scalar @$mta - 2)) {
        my $stimes = [];
        my $etimes = [];
        my $mts = $mta->[$i];
        my $mte = $mta->[$i+1];

        $log->debug("Start stime, etime: [" .
            $mts->{stime} . "," . $mts->{etime} . "]");
        my $rs = $self->schema->resultset('RoomBookings')->search( {
            -and => [
            checkin     =>  {
                '>' => "$date " . $mts->{stime}
            },
            checkin     =>  {
                '<=' => "$date " . $mts->{etime}
            } ]
        } );
        while (my $rb = $rs->next()) {
            push(@$stimes, $rb->id);
            $startset->{$rb->id} = 1;
            $unionset->{$rb->id} = 1;
        }
        $log->debug("Start times: " . join(",", @$stimes));

        $log->debug("End stime, etime: [" .
            $mte->{stime} . "," . $mte->{etime} . "]");
        $rs = $self->schema->resultset('RoomBookings')->search( {
            -and => [
            checkout    =>  {
                '>=' => "$date " . $mte->{stime}
            },
            checkout    =>  {
                '<' => "$date " . $mte->{etime}
            } ]
        } );
        while (my $rb = $rs->next()) {
            push(@$etimes, $rb->id);
            $endset->{$rb->id} = 1;
            $unionset->{$rb->id} = 1;
        }
        $log->debug("End times: " . join(",", @$etimes));

        $endtimes->{$mts->{id}} = $etimes;
        $starttimes->{$mts->{id}} = $stimes;
    }

    foreach my $rb (keys %$unionset) {
        unless ($startset->{$rb}) {
            push(@{$starttimes->{$mta->[0]->{id}}}, $rb);
        }
    }

    foreach my $rb (keys %$unionset) {
        unless ($endset->{$rb}) {
            push(@{$endtimes->{$mta->[scalar @$mta - 2]->{id}}}, $rb);
        }
    }

    my $ts_rbs = [];
    foreach my $i (0..(scalar @$mta - 2)) {
        my $tsid = $mta->[$i]->{id};
        push(@$ts_rbs, @{ $starttimes->{$tsid} } );
        $log->debug("ts $tsid room bookings: " . join(",",@$ts_rbs));

        my $rs = $self->schema->resultset('MealBookings')->search( {
            booked_for          =>  'Room',
            'meal.timeslot_id'  =>  $tsid,
            booking_id          =>  $ts_rbs
        }, {
            join    => [ 'meal' ],
            select  => [ 'meal.type', { sum => 'count' } ],
            as      => [ 'mealtype', 'count' ],
            group_by    =>  [ 'meal.type' ]
        } );

        while (my $row = $rs->next()) {
            $mc->{$tsid}->{$row->get_column('mealtype')} += $row->get_column('count');
        }

        my $regex = '^(' . join('|', @{ $endtimes->{$tsid} }) . ')$';
        @$ts_rbs = grep { $_ !~ m/$regex/ } @$ts_rbs;
    }

    return $mc;
}

sub get_hall_bookings {
    my ( $self, $date ) = @_;

    $self->schema->resultset('HallBookings')->search( {
        'date'  => "$date 00:00:00"
    }, {
        join    => { halltimeslot => 'timeslot' },
        order_by    => 'timeslot.id'
    } );
}

sub get_room_bookings {
    my ( $self, $date ) = @_;

    $self->schema->resultset('RoomBookings')->search( {
        checkin => { '<='   => "$date 23:59:59" },
        checkout => { '>='  => "$date 00:00:00" }
    } );
}

sub get_booking_users {
    my $self = shift;

    $self->schema->resultset('Users')->search( {
    }, {
        join    =>  [ 'billings' ],
        group_by    => [ 'me.id' ]
    } );
}

sub get_user_billings {
    my ( $self, $uid ) = @_;

    $self->schema->resultset('Billings')->search( {
        booked_by   =>  $uid
    } );
}

sub get_user {
    my ( $self, $uid ) = @_;

    $self->schema->resultset('Users')->find($uid);
}

1;
