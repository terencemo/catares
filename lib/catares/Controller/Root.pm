package catares::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

catares::Controller::Root - Root Controller for catares

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
    $c->res->redirect($c->uri_for('/search'));
}

sub auto : Private {
    my ( $self, $c ) = @_;

    if ($c->req->path !~ m/^(login|logout)$/ and
            ($c->session_expires == 0 or !$c->session->{name})) {
#        $c->stash->{process_file} = 'login.tt';
#        $c->detach('/login');
#        return 0;
#        $c->session->{name} = 'admin';
#        $c->session->{passcode} = 'd033e22ae348aeb5660fc2140aec35850c4da997';
        $c->session->{path} = $c->req->path;
        $c->forward('/login/index');
        $c->res->redirect($c->uri_for('/login'));
        return 0;
    }

    return 1 if $c->req->action =~ m/^(login|logout)$/;

    my ( $conn, $roles );
    if (my $conn = $c->model('Adaptor')->login( {
            name => $c->session->{name},
            passcode => $c->session->{passcode} } ) ) {

        my $roles = $conn->get_role_array();
        $c->stash->{roles} = $roles;

        $c->stash->{Connection} = $conn;

#        $c->log->debug("Roles: " . join(",",@$roles));

        foreach my $role (@$roles) {
#            $c->log->debug("Actions for $role: " . join(", ", @{ $c->config->{acl}->{$role} }));
            if (grep { $c->req->action eq $_ }
                    @{ $c->config->{acl}->{$role} } ) {
                return 1;
            }
        }
    }

#    my $auth = $c->authenticate( {
#        username    => $c->session->{name},
#        password    => $c->session->{passcode}
#    } );

#    $c->log->debug("Auth result: $auth");

    $c->log->debug("ACL violation. Action: " . $c->req->action);
    $c->forward('/access_violation');
    return 0;
}

sub access_violation : Local {
    my ( $self, $c ) = @_;

    $c->stash->{'process_file'} = 'access-violation.tt';
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    return 1 if $c->res->body();

    $c->stash->{template} ||= 'index.tt';
    unless ($c->stash->{process_file}) {
        my $pf = lc($c->req->path);
        $pf =~ s/::/\//g;
        $c->stash->{process_file} = "$pf.tt";
    }

    if ($c->stash->{includes}) {
        my ( $styles, $scripts ) = ( [], [] );
        foreach my $include (@{ $c->stash->{includes} } ) {
            my $new_styles = $c->config->{includes}->{$include}->{styles};
            if (defined $new_styles) {
                $new_styles = [ $new_styles ] if (ref($new_styles) ne 'ARRAY');
                push(@$styles, @$new_styles);
            }

            my $new_scripts = $c->config->{includes}->{$include}->{scripts};
            if (defined $new_scripts) {
                $new_scripts = [ $new_scripts ] if (ref($new_scripts) ne 'ARRAY');
                push(@$scripts, @$new_scripts);
            }
        }
        $c->stash->{styles} = $styles;
        $c->stash->{scripts} = $scripts;
    }

    my $file = $c->stash->{process_file};
    $file =~ s/\//-/g;
    my $css_file = $file;
    $css_file =~ s/tt$/css/;
    my $static_dir = $c->path_to('/root');
    my $stylesheet = "static/css/$css_file";
    if ( ! $c->stash->{stylesheet} and -f $static_dir->file($stylesheet) ) {
        $c->stash->{stylesheet} = "/$stylesheet";
    }
    my $script = "static/js/$file";
    if ( -f $static_dir->file($script) ) {
        $c->stash->{script} = $script;
    }

    if (my $bid = $c->session->{billing}) {
        my $conn = $c->stash->{Connection};
        my $billing = $conn->get_billing($bid);
        $c->stash->{billing} = $billing;
    }

    $c->forward($c->view("TT"));
}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
