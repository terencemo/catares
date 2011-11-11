package catares::Schema::Meals;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('meals');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        timeslot_id => {
                            data_type => 'integer'
                        },
                        type => {
                            data_type => 'varchar',
                            size => 15
                        },
                        rate => {
                            data_type => 'double'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(timeslot => 'catares::Schema::TimeSlots', 'timeslot_id');

1;
