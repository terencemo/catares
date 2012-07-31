package catares::Schema::RoomBookings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('roombookings');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        billing_id => {
                            data_type => 'integer'
                        },
                        room_id => {
                            data_type => 'integer'
                        },
                        checkin => {
                            data_type => 'datetime'
                        },
                        checkout => {
                            data_type => 'datetime'
                        },
                        days    => {
                            data_type => 'integer'
                        },
                        amount => {
                            data_type => 'double'
                        },
                        checkedout => {
                            data_type => 'bit'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(billing => 'catares::Schema::Billings', 'billing_id');
__PACKAGE__->belongs_to(room => 'catares::Schema::Rooms', 'room_id');
__PACKAGE__->has_many(roomamenitybookings => 'catares::Schema::RoomAmenityBookings', 'roombooking_id');
__PACKAGE__->has_many(allmealbookings => 'catares::Schema::MealBookings', 'booking_id');

sub mealbookings {
    my $self = shift;

    $self->search_related('allmealbookings', {
        booked_for  => 'Room'
    } );
}

1;
