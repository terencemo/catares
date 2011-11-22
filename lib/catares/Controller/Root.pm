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
        foreach my $include (@{ $c->stash->{includes} } ) {
            my $styles = $c->config->{includes}->{$include}->{styles};
            if (defined $styles) {
                $styles = [ $styles ] if (ref($styles) ne 'ARRAY');
                $c->stash->{styles} = $styles;
            }

            my $scripts = $c->config->{includes}->{$include}->{scripts};
            if (defined $scripts) {
                $scripts = [ $scripts ] if (ref($scripts) ne 'ARRAY');
                $c->stash->{scripts} = $scripts;
            }
        }
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
