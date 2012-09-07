# Day 16: Adding JSONP support to your app

Today we'll see another very simple but useful example of a middleware component, this time to add functionality beyond just basic HTTP functions.

### JSONP

[JSONP][1] (JSON-Padding) is a technology to wrap JSON in a JavaScript callback function. This is normally useful when you want to allow your JSON-based content included programatically in the third party websites using HTML `script` tags.

### Middleware::JSONP

Assume your web application returns a JSON encoded data with the Content-Type `application/json`, again with a simple inline PSGI application:

```
use JSON;
my $app = sub {
    my $env = shift;
    if ($env->{PATH_INFO} eq '/whatever.json') {
        my $body = JSON::encode_json({
            hello => 'world',
        });
        return [ 200, ['Content-Type', 'application/json'], [ $body ] ];
    }
    return [ 404, ['Content-Type', 'text/html'], ['Not Found']];
};
```

Adding a JSONP support is easy using Middleware::JSONP:

```
use Plack::Builder;
builder {
    enable "JSONP";
    $app;
};
```

So it's just one line! The middleware checks if the response content type is `application/json` and if so, checks if there is a `callback` parameter in the URL. So a request to "/whatever.json" continues to return the JSON but requests to "/whatever.json?callback=myCallback" would return:

```
myCallback({"hello":"world"});
```

with the Content-Type `text/javascript`. Content-Length is automatically adjusted if there's any.

### Works with frameworks

Supporting JSONP in addition to JSON would be fairly trivial for most frameworks to do, but Middleware::JSONP should be an example of the things that could be done in Plack middleware layer with no complexity.

And of course, this JSONP middleware should work with any existing web frameworks that emits JSON output. So with Catalyst:

```
package MyApp::View::JSON;
use base qw( Catalyst::View::JSON );

package MyApp::Controller::Foo;
sub hello : Local {
    my($self, $c) = @_;
    $c->stash->{message} = 'Hello World!';
    $c->forward('MyApp::View::JSON');
}
```

And then using Catalyst::Engine::PSGI and Plack::Builder, you can add a JSONP support to this controller.

```
use MyApp;
MyApp->setup_engine('PSGI');
my $app = sub { MyApp->run(@_) };

use Plack::Builder;
builder {
    enable "JSONP";
    $app;
};
```

Accidentally this [Catalyst::View::JSON][2] is my module :) and supports JSONP callback configuration by default, but there is more than one way to do it!

  [1]: http://ajaxian.com/archives/jsonp-json-with-padding
  [2]: http://search.cpan.org/perldoc?Catalyst::View::JSON