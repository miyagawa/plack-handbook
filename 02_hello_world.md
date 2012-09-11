## Day 2: Hello World

The first program you write with any of the programming language is the one that prints "Hello World". Let's follow the tradition for PSGI as well. 

**Note:** today's code is written in a raw PSGI interface to understand what's going on, but in reality you should never have to do this unless you're a web application framework developer. Otherwise you should use one of [existing frameworks that supports PSGI](http://plackperl.org/#frameworks).

### Hello, World

Here's the minimal code that prints "Hello World" to the client.

    my $app = sub {
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Hello World' ] ];
    };

PSGI application is a Perl subroutine reference (a coderef) and usually referenced as `$app` (but could be anything else obviously). It takes exactly one argument `$env` (which is not used in this code) and return an array ref containing status, headers and body. That's it.

Save this code in a file named `hello.psgi` and then use plackup command to run it:

    > plackup hello.psgi
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

plackup runs your application with the default HTTP server HTTP::Server::PSGI on localhost port 5000. Open the URL http://127.0.0.1:5000/ and you see the "Hello World" page?

### Give me something different 

Hello World is the simplest code you could imagine, so we could do something else here. Let's read and display the client information using the PSGI environment hash.

    my $app = sub {
        my $env = shift;
        return [
            200, 
            ['Content-Type' => 'text/plain'],
            [ "Hello stranger from $env->{REMOTE_ADDR}!"],
        ];
    };

This code would display the remote address using the PSGI environment hash. Normally it should be 127.0.0.1 if you're running the server on your localhost. The PSGI environment hash contains lots of information about an HTTP connection, like incoming HTTP headers and request paths, much like the CGI environment variables.

Want to display something not text by reading a file? Do this.

    my $app = sub {
        my $env = shift;
        if ($env->{PATH_INFO} eq '/favicon.ico') {
            open my $fh, "<:raw", "/path/to/favicon.ico" or die $!;
            return [ 200, ['Content-Type' => 'image/x-icon'], $fh ];
        } elsif ($env->{PATH_INFO} eq '/') {
            return [ 200, ['Content-Type' => 'text/plain'], [ "Hello again" ] ];
        } else {
            return [ 404, ['Content-Type' => 'text/html'], [ '404 Not Found' ] ];
        }
    };

This app would serve favicon.ico if the request path looks like /favicon.ico, the "Hello World" page with requests to the root (/) and otherwise 404. You can see that a perl filehandle (`$fh`) is a valid PSGI response, and you can use whatever valid HTTP status code to return something different.
