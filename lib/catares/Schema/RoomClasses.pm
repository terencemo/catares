package catares::Schema::RoomClasses;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('roomclasses');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        building_id => {
                            data_type => 'integer'
                        },
                        name => {
                            data_type => 'varchar',
                            size => 50
                        },
                        rate => {
                            data_type => 'double'
                        },
                        descr => {
                            data_type => 'varchar',
                            size => 50
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(building => 'catares::Schema::Buildings', 'building_id');
__PACKAGE__->has_many(rooms => 'catares::Schema::Rooms', 'roomclass_id');

1;
