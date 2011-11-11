package catares::Schema::Roles;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('roles');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        name => {
                            data_type => 'varchar',
                            size => 50
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(users => 'catares::Schema::UserRoles', 'role_id');

1;
