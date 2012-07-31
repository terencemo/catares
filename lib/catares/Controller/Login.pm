package catares::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

#    $c->response->body('Matched catares::Controller::Login in Login.');
    if ('POST' eq $c->req->method()) {
        my $args = {
            name => $c->req->params->{username},
            pass => $c->req->params->{password}
        };
        my $conn = $c->model('Adaptor')->login($args);
        if ('catares::Backend::Connection' eq ref($conn)) {
            $c->log->debug('Login successful');
            $c->session->{name} = $args->{name};
            $c->session->{passcode} = $args->{passcode};
            my $roles = $conn->get_roles();
            while (my $role = $roles->next()) {
                $c->log->debug(sprintf("Role: %s\n", $role->name));
            }
            my $path = $c->session->{path};
            $c->res->redirect($c->uri_for("/$path"));;
            $c->detach();
        } else {
            $c->log->debug('Login failed');
            $c->stash->{msg} = "Login failed. Kindy retry";
        }
    }
    $c->stash->{process_file} = 'login.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

sub logout :Global {
    my ( $self, $c ) = @_;

    $c->delete_session("User logged out");
    $c->stash->{process_file} = 'login.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
