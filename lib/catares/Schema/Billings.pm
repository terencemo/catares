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
                            is_nullable => 1,
                            data_type => 'integer'
                        },
                        created => {
                            is_nullable => 1,
                            data_type => 'datetime'
                        },
                        charges => {
                            is_nullable => 1,
                            data_type => 'double'
                        },
                        discount => {
                            is_nullable => 1,
                            data_type => 'double'
                        },
                        total => {
                            is_nullable => 1,
                            data_type => 'double'
                        },
                        deposit => {
                            is_nullable => 1,
                            data_type => 'double'
                        },
                        client_id   => {
                            is_nullable => 1,
                            data_type   => 'integer'
                        },
                        quota_id    => {
                            data_type => 'integer'
                        },
                        paymode     => {
                            data_type => 'varchar',
                            size      => 50
                        }
);

sub status {
    my $self = shift;

    return $self->checkout ? 'checked out' : 'booked';
}

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(hallbookings => 'catares::Schema::HallBookings', 'billing_id');
__PACKAGE__->has_many(roombookings => 'catares::Schema::RoomBookings', 'billing_id');
__PACKAGE__->belongs_to(booker => 'catares::Schema::Users', 'booked_by');
__PACKAGE__->belongs_to(client => 'catares::Schema::Clients', 'client_id');
__PACKAGE__->belongs_to(quota => 'catares::Schema::Quotas', 'quota_id');
__PACKAGE__->has_one(cheque => 'catares::Schema::Cheques', 'billing_id');
__PACKAGE__->has_one(checkout => 'catares::Schema::Checkouts', 'billing_id');

1;
