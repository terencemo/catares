package catares::Schema::Quotas;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('quotas');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        name => {
                            data_type => 'varchar',
                            size => 255
                        },
                        discount => {
                            data_type => 'integer'
                        }
);

__PACKAGE__->set_primary_key('id');

1;
