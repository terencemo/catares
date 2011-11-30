package catares::Controller::RoomClass;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::RoomClass - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::RoomClass in RoomClass.');
}

sub id : Chained('/') PathPart('roomclass') CaptureArgs(1) {
    my ( $self, $c, $rc_id ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{rc} = $conn->get_roomclass($rc_id);
}

sub add: Local {
    my ( $self, $c, $rc_id ) = @_;

    my $conn = $c->stash->{Connection};
    return unless ('POST' eq $c->req->method);
    
    my %args = map {
        $_ => $c->req->params->{$_}
    } qw(building name descr rate);

    my $rc;
    
    eval {
      $rc = $conn->create_roomclass(%args);
    };
    if ($@) {
        $c->log->debug("Unable to create room class: $@");
        return;
    }

    $c->stash->{template} = 'roomclass/row.tt';
    $c->stash->{rc} = $rc;
}

sub edit :Chained('id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    if ('GET' eq $c->req->method()) {
        $c->stash->{template} = 'roomclass/details.tt';
        return;
    }

    return unless 'POST' eq $c->req->method();

    my $conn = $c->stash->{Connection};
    my %args = map {
        $_ => $c->req->params->{$_}
    } qw(rc name rate descr);

    my $rc;

    eval {
      $rc = $conn->edit_roomclass(%args);
    };
    if ($@) {
        $c->log->debug("Unable to edit room class: $@");
        return;
    }
    $c->stash->{rc} = $rc;
    $c->stash->{template} = 'roomclass/row-data.tt';
}

sub delete :Chained('id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;

}

sub rooms :Chained('id') PathPart('rooms') Args(0) {
    my ( $self, $c ) = @_;

    my $rc = $c->stash->{rc};
    my $conn = $c->stash->{Connection};
    if ('POST' eq $c->req->method()) {
        my $newrnos = $c->req->params->{rno_n}
            or goto NO_NEW_ROOMS;
        if ($newrnos and ref($newrnos) ne 'ARRAY') {
            $newrnos = [ $newrnos ];
        }
        my $nrc = 0;
        foreach my $nrno (grep { $_ ne "" } @$newrnos) {
            if ($conn->create_room(
                roomclass   => $rc->id,
                number      => $nrno
            )) {
                ++$nrc;
            }
        }
        if ($nrc) {
            $c->stash->{msg} = "$nrc new rooms created";
        }
        NO_NEW_ROOMS:
        foreach my $rkey (grep {
            m/^rno_\d+$/
        } keys(%{$c->req->params})) {
            my ( $rid ) = $rkey =~ m/^rno_(\d+)$/;
            my $rno = $c->req->params->{$rkey};
            if ($rno ne "") {
                $conn->edit_room(
                    id      => $rid,
                    number  => $rno
                );
            } else {
                $conn->delete_room($rid);
            }
        }
    }

    $c->stash->{rooms} = $rc->rooms;
    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'roomclass/rooms.tt';
}

=head1 AUTHOR

FOSS Hacker,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
