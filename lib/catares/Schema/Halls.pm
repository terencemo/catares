package catares::Schema::Halls;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('halls');
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
                        descr => {
                            data_type => 'varchar',
                            size => 50
                        },
                        active => {
                            data_type => 'bit',
                            default_value => 0
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(building => 'catares::Schema::Buildings', 'building_id');
__PACKAGE__->has_many(halltimeslots => 'catares::Schema::HallTimeSlots', 'hall_id');

1;
