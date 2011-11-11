package catares::Schema::UserRoles;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('userroles');
__PACKAGE__->add_columns(
                        id => {
                            data_type => 'integer',
                            is_auto_increment => 1
                        },
                        user_id => {
                            data_type => 'integer'
                        },
                        role_id => {
                            data_type => 'integer'
                        }
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(user => 'catares::Schema::Users', 'user_id');
__PACKAGE__->belongs_to(role => 'catares::Schema::Roles', 'role_id');

1;
