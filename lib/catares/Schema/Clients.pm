package catares::Schema::Clients;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('clients');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        fullname => {
                            data_type => 'varchar',
                            size => 255
                        },
                        phone   => {
                            data_type => 'varchar',
                            size    => 15
                        },
                        address => {
                            data_type => 'text'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(billings => 'catares::Schema::Billings', 'client_id');

1;
