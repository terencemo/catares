package catares::Controller::Meal;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

catares::Controller::Meal - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched catares::Controller::Meal in Meal.');
}

sub manage :Chained('/') PathPart('meals/manage') {
    my ( $self, $c ) = @_;

    my $conn = $c->stash->{Connection};
    my $timeslots = $conn->get_timeslots();
    if ('POST' eq $c->req->method()) {
        my $mcount = 0;
        while (my $ts = $timeslots->next()) {
            foreach my $type (qw(veg nonveg)) {
                my %parms = (
                    timeslot    => $ts->id,
                    type        => $type
                );
                my $key = sprintf("%s_%s_rate", $ts->name, $type);
                my $rate = $c->req->params->{$key};
                my $meal;
                if ($meal = $conn->get_meal(%parms)) {
                    eval ++$mcount if $conn->edit_meal(%parms, rate => $rate);
                    if ($@) {
                        $c->log->warn("Failed to edit meal: $@");
                    }
                } else {
                    eval ++$mcount if $conn->create_meal(%parms, rate => $rate);
                    if ($@) {
                        $c->log->warn("Failed to create meal: $@");
                    }
                }
            }
        }
        if ($mcount) {
            $c->stash->{msg} = "$mcount meals saved successfully";
        }
        $timeslots->reset();
    }
    
    $c->stash->{meals} = $conn->get_meals();
    $c->stash->{timeslots} = $timeslots;
    $c->stash->{process_file} = 'meal/manage.tt';
    $c->stash->{includes} = [ 'wufoo' ];
}

=head1 AUTHOR

Terence Monteiro,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
