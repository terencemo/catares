package catares::Schema::Rooms;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('rooms');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        roomclass_id => {
                            data_type => 'integer'
                        },
                        number => {
                            data_type => 'varchar',
                            size => 10
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(roombookings => 'catares::Schema::RoomBookings', 'room_id');
__PACKAGE__->belongs_to(roomclass => 'catares::Schema::RoomClasses', 'roomclass_id');

1;
