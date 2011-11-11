package catares::Schema::Buildings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('buildings');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        name => {
                            data_type => 'varchar',
                            size => 50
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(halls => 'catares::Schema::Halls', 'building_id');
__PACKAGE__->has_many(roomclasses => 'catares::Schema::RoomClasses', 'building_id');

1;
