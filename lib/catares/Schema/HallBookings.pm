package catares::Schema::HallBookings;
use base qw/DBIx::Class/;
use YAML 'Dump';

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('hallbookings');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        halltimeslot_id => {
                            data_type => 'integer'
                        },
                        date => {
                            date_type => 'datetime'
                        },
                        billing_id => {
                            data_type => 'integer'
                        },
                        amount => {
                            data_type => 'double'
                        },
                        checkedout => {
                            data_type => 'bit'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(halltimeslot => 'catares::Schema::HallTimeSlots', 'halltimeslot_id');
__PACKAGE__->belongs_to(billing => 'catares::Schema::Billings', 'billing_id');
__PACKAGE__->has_many(hallamenitybookings => 'catares::Schema::HallAmenityBookings', 'hallbooking_id');
__PACKAGE__->has_many(mealbookings => 'catares::Schema::MealBookings', 'booking_id');

sub mealbooking {
    my $self = shift;

    my $rs = $self->search_related('mealbookings', {
        booked_for  => 'Hall'
    } );
    return $rs->first;
}

1;
