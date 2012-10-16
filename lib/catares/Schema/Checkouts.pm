package catares::Schema::Checkouts;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('checkouts');
__PACKAGE__->add_columns(
                        billing_id => {
                            data_type => 'integer'
                        },
                        late_penalty => {
                            data_type => 'double'
                        },
                        damages => {
                            data_type => 'double'
                        },
                        checked_out => {
                            data_type => 'datetime'
                        }
);

__PACKAGE__->set_primary_key('billing_id');
__PACKAGE__->belongs_to(billing => 'catares::Schema::Billings', 'billing_id');

1;
