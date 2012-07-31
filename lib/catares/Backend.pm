package catares::Backend;
use Moose;
use catares::Schema;
use catares::Backend::Connection;
use Digest::SHA1 qw/sha1_hex/;

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
    my ( $self, $args ) = @_;

    my $schema = $self->{'schema'};
    my $rs = $schema->resultset('Users')->search( {
        name => $args->{'name'}
    } );
    if (my $row = $rs->first) {
        my $pcode = $args->{passcode};
        unless ($pcode) {
            my $pass = $args->{pass};
            return unless $pass;
            $pcode = sha1_hex($pass);
            $args->{passcode} = $pcode;
        }

        if ($pcode eq $row->pass) {
            my $conn = catares::Backend::Connection->new( {
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
