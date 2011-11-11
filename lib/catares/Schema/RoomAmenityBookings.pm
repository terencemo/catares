package catares::Schema::RoomAmenityBookings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('roomamenitybookings');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        amenity_id => {
                            data_type => 'integer'
                        },
                        roombooking_id => {
                            data_type => 'integer'
                        },
                        count => {
                            data_type => 'integer'
                        },
                        cost => {
                            data_type => 'double'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(roombooking => 'catares::Schema::RoomBookings', 'roombooking_id');
__PACKAGE__->belongs_to(amenity => 'catares::Schema::Amenities', 'amenity_id');

1;
