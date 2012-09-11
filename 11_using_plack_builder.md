# Day 11: Using Plack::Builder

[Yesterday](http://advent.plackperl.org/2009/12/day-10-using-plack-middleware.html) we saw how to enable Plack middleware components in .psgi file, using its `wrap` class method. The way you `use` the middleware and then wrap the `$app` with `wrap` is tedious and not intuitive, so we have a DSL (Domain Specific Language) to make it much easier, and that is Plack::Builder.

### Using Plack::Builder

The way you use Plack::Builder is so easy. Just use the keywords `builder` and `enable`:

    my $app = sub { 
        return [ 200, [], [ "Hello World" ] ];
    };
    
    use Plack::Builder;
    builder {
        enable "JSONP";
        enable "Auth::Basic", authenticator => sub { ... };
        enable "Deflater";
        $app;
    };

This takes the original application (`$app`) and wraps it with Deflater, Auth::Basic and JSONP middleware components (inner to outer). So it's equivalent to:

    $app = Plack::Middleware::Deflater->wrap($app);
    $app = Plack::Middleware::Auth::Basic->wrap($app, authenticator => sub { });
    $app = Plack::Middleware::JSONP->wrap($app);

but without lots of `use`ing the module which is anti DRY.

### Outer to Inner, Top to the bottom

Notice that the order of middleware wrapping is in reverse? The builder/enable DSL allows you to *wrap* application so the line close to the original `$app` is *inner*, while the first one in the top is *outer*. You can compare that with [the onion picture](http://pylonshq.com/docs/en/0.9.7/_images/pylons_as_onion.png) and see that it's more obvious: something closer to the application is inner.

`enable` takes the middleware name without the Plack::Middleware:: prefix but in case you want to enable some other namespace, like MyFramework::PSGI::MW::Foo, you can say:

    enable "+MyFramework::PSGI::MW::Foo";

the key here is to use the plus (+) sign to indicate that it is a fully qualified class name.

### What's happening behind

If you're curious what Plack::Builder is doing, take a look at the code and see what's happening. The `builder` takes the code block and executes the code, and take the result (return value of the last statement) as an original application (`$app`), and then returns the wrapped application by applying Middleware in the reverse order. So it is important to have `$app` in the last line inside the `builder` block, and have the `builder` statement as the final statement in .psgi file as well.

### Thanks, Rack

This idea of Plack::Builder is totally an inspiration by [Rack::Builder](http://m.onkey.org/2008/11/18/ruby-on-rack-2-rack-builder). You can see that they use the `use` keyword but obviously we can's *use* that in Perl :) so we chose `enable` instead. You can see that they have `map` which is to map applications to a different path, and we'll talk about its equivalent in Plack tomorrow ;)
