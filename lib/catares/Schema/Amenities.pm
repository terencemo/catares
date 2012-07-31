package catares::Schema::Amenities;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('amenities');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        name => {
                            data_type => 'varchar',
                            size => 50
                        },
                        for_hall => {
                            data_type => 'bit'
                        },
                        for_room => {
                            data_type => 'bit'
                        },
                        multiple => {
                            data_type => 'bit'
                        },
                        rate => {
                            data_type => 'double'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(hallamenitybookings => 'catares::Schema::HallAmenityBookings', 'amenity_id');
__PACKAGE__->has_many(roomamenitybookings => 'catares::Schema::RoomAmenityBookings', 'amenity_id');

1;
