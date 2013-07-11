package Nephia::Plugin::PocketIO;
use 5.008005;
use strict;
use warnings;
use PocketIO;
use File::Spec;
use Furl;
use Plack::Builder;
use Sub::Recursive;
use HTML::Escape ();
use Nephia::DSLModifier;

our $VERSION = "0.03";
our $SOURCE_URL = 'https://raw.github.com/vti/pocketio/master/examples/chat/public/socket.io.js';
our $CLIENT_PATH = '/static/socket.io.js';
our %EVENTS = ();
our @EXPORT = qw/pocketio pocketio_asset_path/;

sub load {
    my ($class, $app, $opts) = @_;
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
    $EVENTS{$event} = sub { 
        my $socket = shift;
        my $connection = pop;
        my @vals = @_;
        @vals = map { _escape_html_recursive($_) } @vals; ### suppress XSS risk
        $code->($socket, @vals);
    };
}

sub _escape_html_recursive {
    my $v = shift;
    return unless $v;
    my $work = recursive {
        my $val = shift;
        ref($val) eq 'ARRAY' ? [map {$REC->($_)} @$val] :
        ref($val) eq 'HASH'  ? +{map {($_, $REC->($val->{$_}))} keys %$val} :
        HTML::Escape::escape_html($val) ;
    };
    $work->($v);
}

sub pocketio_asset_path {
    my $path = shift;
    $path ||= $Nephia::Plugin::PocketIO::CLIENT_PATH;
    return File::Spec->catfile($path);
}

around run => sub {
    my ($class, $config, $orig) = @_;
    return builder {
        enable "SimpleContentFilter", filter => sub {
            my $asset = pocketio_asset_path();
            s|(</body>)|$1\n<script type="text/javascript" src="$asset"></script>|i;
        };
        mount '/socket.io' => PocketIO->new(handler => sub {
            my $self = shift;
            for my $event (keys %EVENTS) {
                my $action = $EVENTS{$event};
                $self->on($event => $action);
            }
            $self->send({buffer => []});
        });
        mount '/' => $orig->($class, $config);
    };
};

1;
__END__

1;
__END__

=encoding utf-8

=head1 NAME

Nephia::Plugin::PocketIO - Nephia plugin that provides DSL for using PocketIO

=head1 SYNOPSIS

Your app class ...

    package MyApp;
    use Nephia plugins => ['PocketIO'];
    
    path '/' => sub {
        +{ template => 'index.html' },
    };
    
    pocketio 'message' => sub {
        my ($socket, $message) = @_;
        $socket->emit('response', sub {sprintf('you said "%s"', $message)} );
    };

and, your template(view/index.html) ...

    <html>
    <head>
    <title>MyApp</title>
    </head>
    <body>
    <button onclick="send_to_server('boo');">boo!</button>
    </body>
    <script type="text/javascript">
    // init connection
    var socket = io.connect();

    // add event listener
    socket.on('response', function(server_message){
        alert(server_message);
    });
    function send_to_server(string) {
        socket.emit('message', string);
    }
    </script>
    </html>

=head1 DOWNLOAD ASSETS

If you use this plugin, it try to download "socket.io.js" into $APPROOT/root/static/socket.io.js from https://raw.github.com/vti/pocketio/master/examples/chat/public/socket.io.js

=head1 AUTO LOADING FEATURE

When calls Nephia::View::*::render(), Nephia::Plugin::PocketIO injects javascript-tag(for loading socket.io.js) into result html.

=head1 LICENSE

Copyright (C) ytnobody / satoshi azuma.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

PocketIO

Nephia

=head1 AUTHOR

ytnobody / satoshi azuma E<lt>ytnobody@gmail.comE<gt>

=cut

