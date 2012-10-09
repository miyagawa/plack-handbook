## Day 2: Hello World

The first program you write in any programming language is the one that prints "Hello World". Let's follow that tradition for PSGI as well.

**Note:** Today's code is written to a raw PSGI interface to help you understand what's going on. In reality you should never have to do this unless you're a web application framework developer. Instead you should use one of the [existing frameworks that supports PSGI](http://plackperl.org/#frameworks).

### Hello, World

Here's the minimal code that prints "Hello World" to the client:

    my $app = sub {
        return [ 200, [ 'Content-Type' => 'text/plain' ], [ 'Hello World' ] ];
    };

A PSGI application is a Perl subroutine reference (a coderef) and is usually referenced as `$app` (it could be named anything else obviously). It takes exactly one argument `$env` (which is not used in this code) and returns an array ref containing status, headers, and body. That's it.

Save this code in a file named `hello.psgi` and then use the plackup command to run it:

    > plackup hello.psgi
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

plackup runs your application with the default HTTP server HTTP::Server::PSGI on localhost port 5000. Open the URL http://127.0.0.1:5000/ and you should see the "Hello World" page.

### Give me something different

Hello World is the simplest code imaginable. We can do more here. Let's read and display the client information using the PSGI environment hash.

    my $app = sub {
        my $env = shift;
        return [
            200,
            ['Content-Type' => 'text/plain'],
            [ "Hello stranger from $env->{REMOTE_ADDR}!"],
        ];
    };

This code will display the remote address using the PSGI environment hash. Normally it should be 127.0.0.1 if you're running the server on your localhost. The PSGI environment hash contains lots of information about an HTTP connection like incoming HTTP headers and request paths, much like the CGI environment variables.

Want to display something that isn't just text by reading a file? Do this:

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

This app would serve favicon.ico if the request path looks like /favicon.ico, the "Hello World" page for requests to the root (/) and otherwise a 404. You can see that a Perl filehandle (`$fh`) is a valid PSGI response, and you can use any valid HTTP status code for a response.
