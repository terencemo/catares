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
        $c->session->{name} = 'admin';
        $c->session->{passcode} = 'd033e22ae348aeb5660fc2140aec35850c4da997';
    }

    if ('POST' eq $c->req->method and 'login' eq $c->req->path) {
        return 1;
    }

    my $conn = $c->model('DBIC')->login(
        name => $c->session->{name},
        passcode => $c->session->{passcode} );

    $c->stash->{Connection} = $conn;

    return 1;
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
