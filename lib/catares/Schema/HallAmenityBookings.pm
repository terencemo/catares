package catares::Schema::HallAmenityBookings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('hallamenitybookings');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        amenity_id => {
                            data_type => 'integer'
                        },
                        hallbooking_id => {
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
__PACKAGE__->belongs_to(amenity => 'catares::Schema::Amenities', 'amenity_id');
__PACKAGE__->belongs_to(hallbooking => 'catares::Schema::HallBookings', 'hallbooking_id');

1;
