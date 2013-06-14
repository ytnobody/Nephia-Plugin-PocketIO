# NAME

Nephia::Plugin::PocketIO - Nephia plugin that provides DSL for using PocketIO

# SYNOPSIS

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

# DOWNLOAD ASSETS

If you use this plugin, it try to download "socket.io.js" into $APPROOT/root/static/socket.io.js from https://raw.github.com/vti/pocketio/master/examples/chat/public/socket.io.js

# AUTO LOADING FEATURE

When calls Nephia::View::\*::render(), Nephia::Plugin::PocketIO injects javascript-tag(for loading socket.io.js) into result html.

# LICENSE

Copyright (C) ytnobody / satoshi azuma.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

PocketIO

Nephia

# AUTHOR

ytnobody / satoshi azuma <ytnobody@gmail.com>
