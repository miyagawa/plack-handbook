## Day 12: Maps multiple apps with mount and URLMap

### Hello World! but anyone else?

Throughout the advent calendar we most of the time use the simplest web application using the "Hello World" example, like

    my $app = sub {
        return [ 200, [], [ "Hello World" ] ];
    };

what about more complex examples, like you have multiple applications, each of which inherit from one of the web application frameworks, and use one of apache magic like mod_alias etc. 

### Plack::App::URLMap

Plack::App::URLMap allows you to *composite* multiple PSGI applications into one application, to dispatch requests to multiple applications using the URL path, or even with virtual host based dispatch.

    my $app1 = sub {
        return [ 200, [], [ "Hello John" ] ];
    };
    
    my $app2 = sub {
        return [ 200, [], [ "Hello Bob" ] ];
    };

So you have two apps, one is to say hi to John and another to Bob, and say if you want to run this two application on the same server. With Plack::App::URLMap, you can do this.

    use Plack::App::URLMap;
    my $app = Plack::App::URLMap->new;
    $app->mount("/john" => $app1);
    $app->mount("/bob"  => $app2);

There you go. Your app now dispatches all requests beginning with `/john` to `$app1` which says "Hello John" and `/bob` to $app2, which is to say "Hello Bob". As a result, all requests to unmapped paths, like the root ("/") gives you 404.

The environment variables such as `PATH_INFO` and `SCRIPT_NAME` are automatically adjusted so it just works like when your application is mounted using Apache's mod_alias or CGI scripts. Your application framework should always use `PATH_INFO` to dispatch requests, and concatenate with `SCRIPT_NAME` to build links.

### mount in DSL

This `mount` interface with Plack::App::URLMap is quite useful, so we decided to add to Plack::Builder DSL itself, which is again an inspiration by Rack::Builder, using the syntax `mount`:

    use Plack::Builder;
    builder {
        mount "/john" => $app1;
        mount "/bob"  => builder {
            enable "Auth::Basic", authenticator => ...;
            $app2;
        };
    };

Requests to '/john' is handled exactly the same way with the normal URLMap. But this example uses `builder` for "/bob", so it enables the basic authentication to display the "Hello Bob" page. This should be syntactically equivalent to:

    $app = Plack::App::URLMap->new;
    $app->mount("/john", $app1);
    
    $app2 = Plack::Middleware::Auth::Basic->wrap($app2, authenticator => ...);
    $app->mount("/bob",  $app2);

but obviously, with less code to write and more obvious to understand what's going on.

### Multi tenant frameworks

Of course you can use this URLMap and mount API to run multiple framework applications on one server. Imagine you have three applications, "Foo" which is based on Catalyst, "Bar" which is based on CGI::Application and "Baz" which is based on Squatting. Do this:

    # Catalyst
    use Foo;
    Foo->setup_engine('PSGI');

    my $app1 = sub { Foo->new->run(@_) };
    
    # CGI::Application
    use Bar;
    use CGI::Application::PSGI;
    my $app2 = sub { 
        my $app = Bar->new({ QUERY => CGI::PSGI->new(shift) });
        CGI::Application::PSGI->run($app);
    };
    
    # Squatting
    use Baz 'On::PSGI';
    Baz->init;
    my $app3 = sub { Baz->psgi(shift) };
    
    builder {
        mount "/foo" => $app1;
        mount "/bar" => $app2;
        mount "/baz" => $app3;
    };

And now you have three applications, each of which inherit from different web framework, running on the same server (via plackup or other Plack::Server::* implementations) mapped on different paths.
