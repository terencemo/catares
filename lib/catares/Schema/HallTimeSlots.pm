package catares::Schema::HallTimeSlots;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('halltimeslots');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        timeslot_id => {
                            data_type => 'integer'
                        },
                        hall_id => {
                            data_type => 'integer'
                        },
                        start => {
                            data_type => 'varchar',
                            size => 50
                        },
                        end => {
                            data_type => 'varchar',
                            size => 50
                        },
                        rate => {
                            data_type => 'double'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(timeslot => 'catares::Schema::TimeSlots', 'timeslot_id');
__PACKAGE__->belongs_to(hall => 'catares::Schema::Halls', 'hall_id');
__PACKAGE__->has_many(hallbookings => 'catares::Schema::HallBookings', 'halltimeslot_id');

1;
