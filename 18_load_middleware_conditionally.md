# Day 18: Load middleware conditionally

I've introduced a couple of middleware components. Some of them are useful and could be enabled globally, while others might be better enabled on certain conditions. Today we'll talk about a solution to this.

### Load middleware conditionally

Conditional middleware is a super (or meta) middleware that takes one middleware and enable that middleware based on a runtime condition. Let's take some examples:

* You want to enable [JSONP middleware][1] only if the path begins with /public
* You don't want to enable [Basic Auth][2] if the request comes from local IP

We investigated how they deal with situations like this in WSGI and Rack, but couldn't find a generic solution, and they mostly just implement options to individual component, which did not look cool for me.

### Middleware::Conditional

The Conditional middleware is an ultimate flexible solution to this:

```
use Plack::Builder;

builder {
    enable_if { $_[0]->{REMOTE_ADDR} !~ /^192\.168\.0\./ }
        "Auth::Basic", authenticator => ...;
    $app;
};
```

We added a new keyword to Plack::Builder `enable_if`, which takes a block that gets evaluated in the request time (`$_[0]` there is the `$env` hash) and if the block returns true, run the wrapped application but otherwise pass through.

This example code examines if the request comes from a local network and runs a basic authentication otherwise.

Conditional is implemented as a normal piece of middleware, and internally this is equivalent to:

```
use Plack::Middleware::Conditional;
use Plack::Middleware::Auth::Basic;

my $app = sub { ... };

$app = Plack::Middleware::Conditional->wrap($app,
    builder => sub {
        Plack::Middleware::Auth::Basic->wrap(
            $_[0], authenticator => ...,
        );
    },
    condition => sub {
        my $env = shift;
        $env->{REMOTE_ADDR} !~ /^192\.168\.0\./;
    },
);
```

But it's a little boring to write, so we added a DSL version, which I recommend to use :)

  [1]: http://advent.plackperl.org/2009/12/day-16-adding-jsonp-support-to-your-app.html
  [2]: http://advent.plackperl.org/2009/12/day-15-authenticate-your-app-with-middleware.html
