package catares::Schema::Transactions;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('transactions');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        descr => {
                            data_type => 'varchar',
                            size => 255
                        },
                        user_id => {
                            data_type => 'integer'
                        },
                        type => {
                            data_type => 'varchar',
                            size => 15
                        },
                        created => {
                            data_type => 'datetime'
                        },
                        amount => {
                            data_type => 'double'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(user => 'catares::Schema::Users', 'user_id');

1;
