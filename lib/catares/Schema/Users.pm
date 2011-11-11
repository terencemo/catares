package catares::Schema::Users;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('users');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        name => {
                            data_type => 'varchar',
                            size => 50
                        },
                        pass => {
                            data_type => '50'                        },
                        lastlogin => {
                            data_type => 'datetime'                        },
                        fullname => {
                            data_type => 'varchar',
                            size => 255
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(billings => 'catares::Schema::Billings', 'booked_by');
__PACKAGE__->has_many(roles => 'catares::Schema::UserRoles', 'user_id');

1;
