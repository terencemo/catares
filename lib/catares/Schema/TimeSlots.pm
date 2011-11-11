package catares::Schema::TimeSlots;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('timeslots');
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
__PACKAGE__->has_many(halltimeslots => 'catares::Schema::HallTimeSlots', 'timeslot_id');

1;
