# Day 14: Use Plack::Request

Plack is not a framework per se, but is more of a toolkit that contains PSGI server implementations as well as utilities like [plackup](http://advent.plackperl.org/2009/12/day-3-using-plackup.html), [Plack::Test](http://advent.plackperl.org/2009/12/day-13-use-placktest-to-test-your-application.html) and [Middleware components](http://advent.plackperl.org/2009/12/day-10-using-plack-middleware.html). 

Since Plack project is a revolution from [HTTP::Engine](http://search.cpan.org/perldoc?HTTP::Engine), there seems a demand to write a quick web application in Request/Response style handler API. Plack::Request gives you a nice Object Oriented API around PSGI environment hash and response array, just like Rack's Rack::Request and Response objects. It could also be used as a library when writing a new middleware component, and a base class for requests/responses when you write a new web application framework based on Plack.

### Use Plack::Request and Response

Plack::Request is a wrapper around PSGI environment, and the code goes like this:

    use Plack::Request;
    
    my $app = sub {
        my $req = Plack::Request->new(shift);
        
        my $name = $req->param('name');
        my $res  = $req->new_response(200);
        $res->content_type('text/html');
        $res->content("<html><body>Hello World</body></html>");
        
        return $res->finalize;
    };

The only thing you need to change, if you're migrating from HTTP::Engine, is the first line of the application to create a Plack::Request out of PSGI env (`shift`) and then call `finalize` to get an array reference out of Response object.

All other methods like `path_info`, `uri`, `param`, `redirect` etc. work like HTTP::Engine::Request and Response object which is very similar to [Catalyst](http://search.cpan.org/dist/Catalyst-Runtime) 's Request and Response object.

### Plack::Request and Plack

Plack::Request is available as part of Plack on CPAN. Your framework can use Plack::Request to handle parameters and can also make it run on other PSGI server implementations such as mod_psgi.

### Use Plack::Request or not?

Directly using Plack::Request in the `.psgi` code is quite handy to quickly write and test your code but not really recommended for a large scale application. It's exactly like writing a 1000 lines of `.cgi` script where you could factor out the application code into a module (`.pm` files). The same thing applies to `.psgi` file: it's best to create an application class by using and possibly extending Plack::Request, and then have just a few lines of code in `.psgi` file with [Plack::Builder to configure middleware components](http://advent.plackperl.org/2009/12/day-11-using-plackbuilder.html).

Plack::Request is also supposed to be used from a web application framework to [adapt to PSGI interface](http://advent.plackperl.org/2009/12/day-8-adapting-web-frameworks-to-psgi.html).
