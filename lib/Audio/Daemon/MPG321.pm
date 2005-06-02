#!/usr/bin/perl
#########################
# Audio::Daemon::MPG321 #
#    By Da-Breegster    #
#########################

package Audio::Daemon::MPG321;

use strict;
use warnings;
use Audio::Play::MPG321;
use 5.006;
our $VERSION = 0.001;

sub new {
 my $class = shift;
 my @songs = @_;
 my $self = {
  player => new Audio::Play::MPG321,
  queue => [@songs],
  pointer => 0,
 };
 bless $self, $class;
 $self->load();
 return $self;
}

sub load {
 my $self = shift;
 $self->{player}->play($self->{queue}->[$self->{pointer}]);
}

sub add {
 my $self = shift;
 my @songs = @_;
 push @{$self->{queue}}, @songs;
}

sub next {
 my $self = shift;
 $self->{pointer}++;
 if ($self->{pointer} > $#{$self->{queue}}) {
  $self->stop();
 } else {
  $self->load();
 }
}

sub prev {
 my $self = shift;
 $self->{pointer}--;
 $self->stop() if ( $self->{pointer} < 0 );
 $self->load();
}

sub pause {
 my $self = shift;
 $self->{player}->pause();
}

sub resume {
 my $self = shift;
 $self->{player}->resume();
}

sub toggle {
 my $self = shift;
 $self->{player}->toggle();
}

sub restart {
 my $self = shift;
 $self->{player}->seek(undef, 0);
}

sub forward {
 my $self = shift;
 my $seconds = shift;
 $self->{player}->seek("+", $seconds);
}

sub backward {
 my $self = shift;
 my $seconds = shift;
 $self->{player}->seek("-", $seconds);
}

sub stop {
 my $self = shift;
 $self->{player}->stop();
}

1;

__END__

=head1 NAME

Audio::Daemon::MPG321 - A song queue daemon for Audio::Play::MPG321.

=head1 SYNOPSIS

  use Audio::Daemon::MPG321;
  my $player = new Audio::Daemon::MPG321 ("/home/dabreegster/mp3/foo.mp3",
                                          "/home/dabreegster/mp3/bar.mp3");

$SIG{CHLD} = 'IGNORE';
$player->add("/home/dabreegster/mp3/blah.mp3");

while (1) {
 until ($player->{player}->state() == 0) {
  $player->{player}->poll();
  select(undef, undef, undef, 1.0);
 }
 $player->{pointer}++;
 unless ($player->{queue}->[$player->{pointer}]) {
  exit 1;
 } else {
  $player->load();
 }
}

=head1 DESCRIPTION

This daemonizes Audio::Play::MPG321, or at least gives it the ability to manage
a song queue. You can build a simple queue of songs and move between them.

Note the infinite loop in the synopsis. You must put this in your program or
the queue won't work! All it does is keep Audio::Play::MPG321's knowledge of
the state of the player fresh and continously test to see if one song is over
so the next can be loaded. The code is kept out of the module itself because
this process must be done, one way or the other, and forking in the module
itself is very messy. The example loop will work fine and you may modify it any
way you like to incoorporate it into your frontend, as long as you poll the
player, test to see if the song is finished yet, and load the next song in the
queue (If there is one!) when it is time to do so.

=head2 METHODS

=over 4

=item new

This method creates a new instance of the daemon and does everything
Audio::Play::MPG321 does. It also starts playing the first song in the queue.
It takes a list of songs to play.

=item load

This immediatly starts to play the song in the queue that has the same index as
the pointer attribute. In other words, it plays the current song, where current
is defined by the pointer.

=item add

This takes a list of songs to be added to the end of the queue.

=item next

This advances the pointer and plays the next song. If you reach the end of the
queue and try to call next, the daemon will be stopped. See stop().

=item prev

This moves the pointer back one and plays the previous song. If you reach the
beginning of the queue and try to call prev, the daemon will be stopped. See
stop(). The pointer is not allowed to be negative!

=item pause

This forces a pause.

=item resume

This forces a resume.

=item toggle

This pauses if playing and resumes if paused.

=item restart

This starts the current song over.

=item forward

This takes one argument: The number of seconds to advance within the song. If
you try to advance beyond the song, the state will change to 0.

=item backward

This takes one argument: The number of seconds to skip backwards within the
song. If you try to advance to a time before the song, it will act as if
restart() had been called.

=item stop

This causes the MPG321 player to exit, so have a signal handler for CHLD ready
to reap some zombies.

=back

=head1 AUTHOR

Da-Breegster <scarlino@bellsouth.net>

=cut
