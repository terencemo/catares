package catares;
use Moose;
use namespace::autoclean;

use Config::General;
use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug

    ConfigLoader
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    Static::Simple
/;

extends 'Catalyst';

our $VERSION = '0.01';
$VERSION = eval $VERSION;

# Configure the application.
#
# Note that settings in catares.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'catares',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
);

my $aclconf = new Config::General(__PACKAGE__->config->{home} . "/acl.conf");
my %conf = $aclconf->getall();
foreach my $utype (keys(%conf)) {
    my $uconf = $conf{$utype};
    __PACKAGE__->config->{acl}->{$utype} = $uconf->{allow};
}

__PACKAGE__->config('Plugin::Authentication' =>
    {
        default_realm   => 'members',
        members => {
            credential  => {
                class   => 'Password',
                password_field  => 'pass',
                password_type   => 'clear'
            },
            store   => {
                class   => 'DBIx::Class',
                user_model  => 'DBIC',
                role_column => 'roles'
            }
        }
    }
);

__PACKAGE__->config('Model::Adaptor' => {
    class   => 'catares::Backend',
    args    => {
        connect_info => __PACKAGE__->config->{'Model::DBIC'}->{connect_info}
    }
} );

# Start the application
__PACKAGE__->setup();


=head1 NAME

catares - Catalyst based application

=head1 SYNOPSIS

    script/catares_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<catares::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
