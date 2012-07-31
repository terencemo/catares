package catares::Schema::MealBookings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('mealbookings');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        meal_id => {
                            data_type => 'integer'
                        },
                        booked_for => {
                            data_type   => 'varchar',
                            size        => 10
                        },
                        booking_id => {
                            data_type => 'integer',
                            is_nullable => 1,
                            default_value => undef
                        },
                        count => {
                            data_type => 'integer'
                        },
                        cost => {
                            data_type => 'double'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(meal => 'catares::Schema::Meals', 'meal_id');
__PACKAGE__->belongs_to(hallbooking => 'catares::Schema::HallBookings', 'booking_id');
__PACKAGE__->belongs_to(roombooking => 'catares::Schema::RoomBookings', 'booking_id');

1;
