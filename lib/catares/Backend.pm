package catares::Backend;
use Moose;
use catares::Schema;
use Digest::MD5 qw/md5_hex/;

sub new {
    my $class = shift;
    my $args = shift;

    my $self = {
        schema => catares::Schema->connect(@{$args->{'connect_info'}}),
    };

    bless $self, $class;
    return $self;
}

sub login {
    my $self = shift;
    my %args = @_;

    my $schema = $self->{'schema'};
    my $rs = $schema->resultset('Users')->search( {
        name => $args{'name'}
    } );
    if (my $row = $rs->first) {
        my $pass = $args{pass};
        return unless $pass;

        my $auth = 0;
        my $reg = $self->{reg};
        if (md5_hex($pass) eq $row->pass) {

            my $conn = mla::Backend::Connection->new( {
                schema => $schema,
                username => $row->name,
                user => $row,
            } );
            return $conn;
        }
    }
    return;
}


1;
