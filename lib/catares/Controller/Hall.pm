package catares::Controller::Hall;
use Moose;
use namespace::autoclean;
use YAML 'Dump';

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Hall - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Hall in Hall.');
}

sub fields :Local {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'hall/fields.tt';
}

sub add :Local {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};

    if ('POST' eq $c->req->method()) {
        
        my %args = map {
            $_ => $c->req->params->{$_}
        } qw(building name descr);

        my $hall;
        
        eval {
          $hall = $conn->create_hall(%args);
        };
        if ($@) {
            $c->log->debug("Unable to create hall: $@");
            return;           
        }

        $c->stash->{template} = 'hall/row.tt';
        $c->stash->{hall} = $hall;
    }
}

sub id : Chained('/') PathPart('hall') CaptureArgs(1) {
    my ( $self, $c, $hall_id ) = @_;

    my $conn = $c->stash->{Connection};
    $c->stash->{hall} = $conn->get_hall($hall_id);
}

sub edit :Chained('id') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    if ('POST' eq $c->req->method()) {
        my %args = map {
            $_ => $c->req->params->{$_}
        } qw(hall name descr);

        my $hall;

        eval {
          $hall = $conn->edit_hall(%args);
        };
        if ($@) {
            $c->log->debug("Unable to create hall: $@");
            return;
        }

        $c->stash->{hall} = $hall;
        $c->stash->{template} = 'hall/row-data.tt';
        return;
    }
    $c->stash->{template} = 'hall/details.tt';
}

sub rates :Chained('id') PathPart('rates') Args(0) {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my $timeslots = $conn->get_timeslots();
    my $hall = $c->stash->{hall};
    if ('POST' eq $c->req->method()) {
        my $mcount = 0;
        while (my $ts = $timeslots->next()) {
            my %parms = (
                timeslot    => $ts->id,
                hall        => $hall->id
            );
            my %search_parms = %parms;
            foreach my $tm (qw(start end)) {
                my $key = sprintf("%s_%s_time", $ts->name, $tm);
                $parms{$tm} = $c->req->params->{$key};
            }
            $parms{rate} = $c->req->params->{$ts->name . '_rate'};
            if (my $htss = $conn->get_hall_timeslots(%search_parms)) {
                my $hts = $htss->first();
                eval ++$mcount if $conn->edit_hall_timeslot(%parms);
                if ($@) {
                    $c->log->warn("Editing of ".$ts->name." timeslot failed: $@");
                }
            } else {
                eval ++$mcount if $conn->create_hall_timeslot(%parms);
                if ($@) {
                    $c->log->warn("Creation of " . $ts->name . " timeslot failed: $@");
                }
            }
        }
        if ($mcount) {
            $c->stash->{msg} = "$mcount timeslots saved successfully";
        }
        $timeslots->reset();
    }

    $c->stash->{timeslots} = $timeslots;
    $c->stash->{halltimeslots} = $hall->halltimeslots;
    $c->stash->{includes} = [ 'wufoo' ];
    $c->stash->{process_file} = 'hall/rates.tt';
}

sub delete :Chained('id') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;

}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
