## Day 15: Authenticate your app with Middleware

There're lots of Plack middleware components out there, whether in Plack core distribution as well as separate distributions on CPAN. While I've been writing this Plack advent calendar lots of people have shown their interest and taken ideas out of my wishlist.

From today we'll introduce some of the nice middleware components that you can use quickly to enhance any of your PSGI ready applications.

### Basic authentication

Since Plack middleware wraps an application, the best thing it can do is pre-process or post-process to do things around HTTP layers. Today let's talk about the Basic Authentication.

Adding a basic authentication can be done in multiple ways: you can do that in the web application framework layer if it's supported in your framework. In case of Catalyst it's [Catalyst::Authentication::Credential::HTTP](http://search.cpan.org/perldoc?Catalyst::Authentication::Credential::HTTP). Just like other Catalyst tools, it allows you to configure the authentication from simple to very complex, by using credential (how to authenticate: basic and/or digest) and store (how to authorize username and passwords).

Otherwise you can do the authentication in the web server layer. For instance if you run your application with Apache and mod_perl, using Apache's default mod_auth module to authenticate is pretty easy and handy for development, while it limits the ability to share "how to authenticate users" since usually you need to write your custom module to do things like database backed authentication.

Plack middleware allows web application frameworks to share such a functionality, mostly with a pretty simple Perl callback system, and Plack::Middleware::Auth::Basic is to do this for Basic authentication. And this is why most Plack standalone servers do not have an authentication system: it's best implemented as a middleware component.

### Using Plack::Middleware::Auth::Basic

Just like [other middleware](http://advent.plackperl.org/2009/12/day-10-using-plack-middleware.html), using Auth::Basic middleware is quite simple:

    use Plack::Builder;
    
    my $app = sub { ... };
    
    builder {
        enable "Auth::Basic", authenticator => sub {
            my($username, $password) = @_;
            return $username eq 'admin' && $password eq 'foobar';
        };
        $app;
    };

This adds a basic authentication to your application `$app`, and the user *admin* can sign in with the password *foobar* and nobody else. The successful signed-in user gets `REMOTE_USER` set in PSGI `$env` hash so it can be used in the applications and is logged using the standard AccessLog middleware.

Since it's a callback based, adding another authentication system such as Kerberos would be pretty trivial and easy with modules such as Authen::Simple:

    use Plack::Builder;
    use Authen::Simple;
    use Authen::Simple::Kerberos;

    my $auth = Authen::Simple->new(
        Authen::Simple::Kerberos->new(realm => ...),
    );
    
    builder {
        enable "Auth::Basic", authenticator => sub {
            $auth->authenticate(@_):
        };
        $app;
    };

The same way you can use lots of [Authen::Simple backends](http://search.cpan.org/search?query=authen+simple&mode=all) with small changes.

### With URLMap

URLMap allows you to compound multiple apps into one app, so combined with Auth middleware, you can run the same application in a auth vs. non-auth mode, using different paths:

    use Plack::Builder;
    my $app = sub {
        my $env = shift;
        if ($env->{REMOTE_USER}) { 
            # Authenticated
        } else {
            # Unauthenticated
        }
    };
    
    builder {
        mount "/private" => builder {
            enable "Auth::Basic", authenticator => ...;
            $app;
        };
        mount "/public" => $app;
    };

This way you run the same `$app` in "/public" and "/private" paths, while "/private" requires a basic authentication and "/public" doesn't. (Inlining `$env->{REMOTE_USER}`, or whatever application logic in .psgi is not really recommended -- I just used it to explain it in an obvious way)
