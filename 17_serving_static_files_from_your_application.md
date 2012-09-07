# Day 17: Serving static files from your application

On [day 5][1] we talked about serving files from the current directory using plackup. Now that we've learned how to [use middleware][2] and [compound multiple applications with URLMap][3] it's extremely trivial to add a functionality you definitely need when developing an application: serving static files.

### Serving files from a certain path

Most frameworks come with this feature but with PSGI and Plack, frameworks don't need to implement this feature anymore. Just use the Static middleware.

```
use Plack::Builder;

my $app = sub { ... };

builder {
    enable "Static", path => qr!^/static!, root => './htdocs';
    $app;
}
```

This will intercept all requests beginning with "/static" and map that to the root directory "htdocs". So requests to "/static/images/foo.jpg" will result in serving a file "./htdocs/static/images/foo.jpg".

Often you want to overlap or cofigure the directory names, so a request to the URL "/static/index.css" mapped to "./static-files/index.css", here's how to do that:

```
builder {
    enable "Static", path => sub { s!^/static/!! }, root => './static-files';
    $app;
}
```

The important thing here is to use a callback and a pattern match `sub { s/// }` instead of a plain regular expression (`qr`). The callback is tested against a request path and if it matches, the value of `$_` is being used as a request path. So in this example we tested to see if the request begins with "/static/" and in that case, strip off that part, and map the files under "./static-files/".

As a result, "/static/foo.jpg" would become "./static-files/foo.jpg". All requests not matching the pattern match just passes through to the original `$app`.

### Do it your own with URLMap and App::File

Just like Perl there's more than one way to do it. When you grok how to use [mount and URLMap][4] then using App::File with mount should be more intuitive. The previous example can be written like this:

```
use Plack::Builder;

builder {
    mount "/static" => Plack::App::File->new(root => "./static-files");
    mount "/" => $app;
};
```

Your mileage may vary, but I think this one is more obvious. Static's callback based configuration allows you to write more complex regular expression, which you can't do with URLMap and mount, so choose whichever fits your need.

  [1]: http://advent.plackperl.org/2009/12/day-5-run-a-static-file-web-server-with-plack.html
  [2]: http://advent.plackperl.org/2009/12/day-10-using-plack-middleware.html
  [3]: http://advent.plackperl.org/2009/12/day-12-maps-multiple-apps-with-mount-and-urlmap.html
  [4]: http://advent.plackperl.org/2009/12/day-12-maps-multiple-apps-with-mount-and-urlmap.html