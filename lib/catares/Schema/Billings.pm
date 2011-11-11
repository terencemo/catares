package catares::Schema::Billings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('billings');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        booked_by => {
                            data_type => 'integer'
                        },
                        created => {
                            data_type => 'datetime'
                        },
                        charges => {
                            data_type => 'double'
                        },
                        discount => {
                            data_type => 'double'
                        },
                        total => {
                            data_type => 'double'
                        },
                        deposit => {
                            data_type => 'double'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(hallbookings => 'catares::Schema::HallBookings', 'billing_id');
__PACKAGE__->has_many(roombookings => 'catares::Schema::RoomBookings', 'billing_id');
__PACKAGE__->belongs_to(booker => 'catares::Schema::Users', 'booked_by');

1;
