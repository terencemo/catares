package catares::Controller::Amenity;
use Moose;
use namespace::autoclean;
#use YAML 'Dump';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Amenity - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Amenity in Amenity.');
}

sub manage :Chained('/') PathPart('amenities/manage') {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    if ('POST' eq $c->req->method()) {
        my $h = {};
        foreach my $key (keys(%{$c->req->params})) {
            if (my ($aid, $fld) = $key =~ m/^am_(\d+)_(.*)$/) {
                $h->{$aid} ||= {};
                $h->{$aid}->{$fld} = $c->req->params->{$key};
            }
        }
        my $mcount = 0;
        foreach my $aid (keys(%$h)) {
            my $args = {
                id      => $aid,
                rate    => $h->{$aid}->{rate},
                map {
                    $_ => ( $h->{$aid}->{$_} ? 1 : 0 )
                } qw(for_hall for_room multiple)
            };
#            $c->log->debug("Amenities:", Dump($args));
            eval {
                ++$mcount if $conn->edit_amenity(%$args);
            };
            if ($@) {
                $c->log->warn("Failed to edit amenity: $@");
            }
        }
        if ($mcount) {
            $c->stash->{msg} = "$mcount amenities successfully edited";
        }
    }
    $c->stash->{amenities} = $conn->get_amenities();
    $c->stash->{process_file} = 'amenity/manage.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

sub add :Local {
    my ( $self, $c ) = @_;

    return unless ('POST' eq $c->req->method());

    my %params = map {
        $_ => $c->req->params->{$_}
    } qw(name rate for_hall for_room);

    my $conn = $c->stash->{Connection};
    my $amenity;
    eval {
        $amenity = $conn->create_amenity(%params);
    };
    if ($@) {
        $c->log->error("Failed to create amenity: $@");
        return;
    }
    $c->stash->{template} = 'amenity/row.tt';
    $c->stash->{amenity} = $amenity;
}

sub id : Chained('/') PathPart('amenity') CaptureArgs(1) {
    my ( $self, $c, $am_id ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{amenity} = $conn->get_amenity($am_id);
}

sub cost :Chained('id') PathPart('cost') Args(0) {
    my ( $self, $c ) = @_;

    my $am = $c->stash->{amenity};
    $c->res->body($am->rate);
}

=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
