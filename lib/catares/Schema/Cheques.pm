package catares::Schema::Cheques;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('cheques');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        bank => {
                            data_type => 'varchar',
                            size => 50
                        },
                        branch => {
                            data_type => 'varchar',
                            size => 50
                        },
                        date => {
                            data_type => 'datetime'
                        },
                        cheque_no => {
                            data_type => 'varchar',
                            size => 255
                        },
                        billing_id => {
                            data_type => 'integer'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(billing => 'catares::Schema::Billings', 'billing_id');

1;
