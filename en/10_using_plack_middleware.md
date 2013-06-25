## Day 10: Using Plack middleware

### Middleware 

Middleware is a concept in PSGI (as always, stolen from Python's WSGI and Ruby's Rack) where we define components that plays the both side of a server and an application.

![WSGI middleware onion](../images/pylons_as_onion.png)

(Image courtesy of Pylons project for Python WSGI)

This picture illustrates the middleware concept very well. The PSGI application is in the core of the Onion layers, and middleware components wrap the original application in return, and they preprocess as a request comes in (outer to inner) and then postprocess the response as a response goes out (inner to outer).

Lots of functionalities can be added to the PSGI application by wrapping it with a middleware component, from HTTP authentication, capturing errors to logging output or wrapping JSON output with JSONP.

### Plack::Middleware

[Plack::Middleware](http://search.cpan.org/perldoc?Plack::Middleware) is a base class for middleware components and it allows you to write middleware really simply but in a reusable fashion. 

Using Middleware components written with Plack::Middleware is easy, just wrap the original application with `wrap` method:

    my $app = sub { [ 200, ... ] };
    
    use Plack::Middleware::StackTrace;
    $app = Plack::Middleware::StackTrace->wrap($app);

This example wraps the original application with StackTrace middleware (which is actually enabled [by default using plackup](http://advent.plackperl.org/2009/12/day-3-using-plackup.html)) with the `wrap` method. So when the wrapped application throws an error, the middleware component catches the error to [display a beautiful HTML page](http://bulknews.typepad.com/blog/2009/10/develstacktraceashtml.html) using Devel::StackTrace::AsHTML.

Some other middleware components take parameters, in which case you can pass the parameters as a hash after `$app`, like:

    my $app = sub { ... };
    
    use Plack::Middleware::MethodOverride;
    $app = Plack::Middleware::MethodOverride->wrap($app, header => 'X-Method');

Installing multiple middleware components is tedious especially since you need to `use` those modules first, and we have a quick solution for that using a DSL style syntax.

    use Plack::Builder;
    my $app = sub { ... };

    builder {
        enable "StackTrace";
        enable "MethodOverride", header => 'X-Method';
        enable "Deflater";
        $app;
    };

We'll see more about Plack::Builder tomorrow.

### Middleware and Frameworks

The beauty of Middleware is that it can wrap *any* PSGI application. It might not be obvious from the code examples, but the wrapped application can be anything, which means you can [run your existing web application in the PSGI mode](http://advent.plackperl.org/2009/12/day-7-use-web-application-framework-in-psgi.html) and apply middleware components to it. For instance, with CGI::Application:

    use CGI::Application::PSGI;
    use WebApp;
    
    my $app = sub {
        my $env = shift;
        my $app = WebApp->new({ QUERY => CGI::PSGI->new($env) });
        CGI::Application::PSGI->run($app);
    };
    
    use Plack::Builder;
    builder {
        enable "Auth::Basic", authenticator => sub { $_[1] eq 'foobar' };
        $app;
    };

This will enable the Basic authentication middleware to CGI::Application based application. You can do the same with [any other frameworks that supports PSGI](http://plackperl.org/#frameworks).
