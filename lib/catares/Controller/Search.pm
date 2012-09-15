package catares::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
#    $conn->get_halls();

    $c->stash->{buildings} = $conn->get_buildings();
    $c->stash->{quotas} = $conn->get_quotas();
    $c->stash->{includes} = [ 'wufoo', 'calendar' ];
    $c->stash->{process_file} = 'search.tt';
}

sub fields :Local {
    my ( $self, $c ) = @_;

    my $target = lc($c->req->params->{target});
    $c->forward("/$target/fields");
}


=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
