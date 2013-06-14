package Nephia::Plugin::PocketIO;
use 5.008005;
use strict;
use warnings;
use PocketIO;
use File::Spec;
use Furl;
use Plack::Builder;

our $VERSION = "0.01";
our $SOURCE_URL = 'https://raw.github.com/vti/pocketio/master/examples/chat/public/socket.io.js';
our $CLIENT_PATH = '/static/socket.io.js';
our %EVENTS = ();
our $RUN;

use Data::Dumper::Concise;

{
    no strict 'refs';
    $RUN = \&Nephia::Core::run;
}

sub import {
    my $file = File::Spec->catfile($FindBin::Bin, 'root', pocketio_asset_path());
    my $furl = Furl->new(agent => __PACKAGE__.'/'.$VERSION);
    my $res = $furl->get($SOURCE_URL);
    die 'could not fetch assets' unless $res->is_success;
    unless (-e $file) {
        open my $fh, '>', $file or die "could not open file $file : $!";
        print $fh $res->content;
        close $fh;
    }
}

sub pocketio ($&) {
    my ($event, $code) = @_;
    $EVENTS{$event} = $code;
}

sub pocketio_asset_path {
    my $path = shift;
    $path ||= $Nephia::Plugin::PocketIO::CLIENT_PATH;
    return File::Spec->catfile($path);
}

sub run {
    my $app = $RUN->(@_);

    my $asset = pocketio_asset_path();
    my $view_class = ref($Nephia::Core::VIEW);
    {
        no strict 'refs';
        no warnings 'redefine';
        my $render_orig = *{$view_class.'::render'}{CODE};
        *{$view_class.'::render'} = sub {
            my $html = $render_orig->(@_);
            $html =~ s|(</body>)|$1\n<script type="text/javascript" src="$asset"></script>|i;
            $html;
        };
    }

    return builder {
        mount '/socket.io' => PocketIO->new(handler => sub {
            my $self = shift;
            for my $event (keys %EVENTS) {
                my $action = $EVENTS{$event};
                $self->on($event => $action);
            }
            $self->send({buffer => []});
        });
        mount '/' => $app;
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Nephia::Plugin::PocketIO - It's new $module

=head1 SYNOPSIS

    package MyApp;
    use Nephia plugins => ['PocketIO'];
    
    pocketio_assets;
    pocketio 'message' => sub {
        my ($socket, $message) = @_;
        $socket->emit('response', sub {'response data'} );
    };

=head1 DESCRIPTION

Nephia::Plugin::PocketIO is ...

=head1 LICENSE

Copyright (C) ytnobody / satoshi azuma.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody / satoshi azuma E<lt>ytnobody@gmail.comE<gt>

=cut

