# Day 23: Write your own middleware

Let's finish up this middleware discovery with "Do It Yourself" tutorial now.

### Writing Middleware

PSGI middleware behaves like a normal PSGI application but wraps the original PSGI application, so from the server it looks like an application but from an application it looks like a server (plays both sides).

A simple middleware that fakes HTTP user-agent would be like this:

    # Wrapped application
    my $app = sub {
        my $env = shift;
        my $who = $env->{HTTP_USER_AGENT} =~ /Mobile Safari/ ? 'iPhone' : 'non-iPhone';
        return [ 200, ['Content-Type','text/html'], ["Hello $who"] ];
    };
    
    # Middleware to wrap $app
    my $mw = sub {
        my $env = shift;
        $env->{HTTP_USER_AGENT} .= " (Mobile Safari)";
        $app->($env);
    };

The app would display "Hello iPhone" only if a request comes with iPhone browser (*Mobile Safari*), but the middleware adds that phrase to all incoming requests, so if you run this application and open the page with any browsers, you'll always see "Hello iPhone". And the default Access Log would say:

    127.0.0.1 - - [23/Dec/2009 12:34:31] "GET / HTTP/1.1" 200 12 "-" "Mozilla/5.0 
    (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.21.8 (KHTML, like
    Gecko) Version/4.0.4 Safari/531.21.10 (Mobile Safari)"

You can see " (Mobile Safari)" is added to the tail of User-Agent string.

### Make it a reusable Middleware

So that was a good example of writing your own middleware in `.psgi`. If it is one-time middleware that you can quickly whip up then that's great, but you often want to make it generic enough or reusable in other applications too. Then you should use Plack::Middleware.

    package Plack::Middleware::FakeUserAgent;
    use strict;
    use parent qw(Plack::Middleware);
    use Plack::Util::Accessors qw(agent);
    
    sub call {
        my($self, $env) = @_;
        $env->{HTTP_USER_AGENT} = $self->agent;
        $self->app->($env);
    };
    
    1;

That's it. All you have to do is to inherit from Plack::Middleware and defines options that your middleware would take, and implement `call` method that would delegate to `$self->app` which is a wrapped application. This middleware is now compatible to [Plack::Builder DSL](http://advent.plackperl.org/2009/12/day-11-using-plackbuilder.html) so you can say:

    use Plack::Builder;
    
    builder {
        enable "FakeUserAgent", agent => "Mozilla/3.0 (MSIE 4.0)";
        $app;
    };

to fake all incoming requests as it comes with the good old Internet Explorer, and you can also use `enable_if` to [conditionally enable](http://advent.plackperl.org/2009/12/day-18-load-middleware-conditionally.html) this middleware.

### Post process requests

The previous examples does pre-processing of PSGI request `$env` hash, what to do about the response? It's almost the same:

    my $app = sub { ... };
    
    # Middleware to fake status code to 500
    my $mw = sub {
        my $env = shift;
        my $res = $app->($env);
        $res->[0] = 500 unless $res->[2] == 200;
        $res;
    };

This is an *evil* middleware component that changes all the status code to 500 unless it's 200 OK. Not sure if there is any use for this but it's simple enough for a quick example.

Because some servers implement special [streaming interface](http://bulknews.typepad.com/blog/2009/10/psgiplack-streaming-is-now-complete.html) to delay HTTP response, this middleware doesn't really work with such an interface. Dealing with this special callback interface in individual middleware is not efficient, so we have a special callback interface in Plack::Middleware to make this easy:

    package Plack::Middleware::BadStatusCode;
    use strict;
    use parent qw(Plack::Middleware);
    
    sub call {
        my($self, $env) = @_;
        my $res = $self->app->($env);
        $self->response_cb($res, sub {
            my $res = shift;
            $res->[0] = 500 unless $res->[0] == 200;
        });
    }
    
    1;

Pass the response `$res` to `response_cb` and set the callback to wrap the real response, and the method takes care of the direct response and delayed response.

### Namespaces

In this example we use Plack::Middleware namespace to make middleware, but it doesn't really have to be. If you think your middleware is generic enough for all PSGI apps can benefit, feel free to use the namespace, but if the middleware is too specific for your own needs, or works only with a particular application framework, then use whatever namespace, like:

    package MyFramework::Middleware::Foo;
    use parent qw(Plack::Middleware);

and then use the + (plus) sign to indicate the fully qualified namespace,

    enable '+MyFramework::Middleware::Foo', ...;

Or use the non-DSL API,

    $app = MyFramework::Middleware::Foo->wrap($app, ...);

and they should work just fine.
