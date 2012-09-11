# Day 21: Lint your application and middleware

We've been talking about [adapting existing web frameworks to PSGI](http://advent.plackperl.org/2009/12/day-8-adapting-web-frameworks-to-psgi.html) and writing a new application using PSGI as an interface, but we haven't talked about error handling. 

### Handling errors

We have [an awesome stack trace](http://advent.plackperl.org/2009/12/day-3-using-plackup.html) middleware enabled by default, so if an end user application throws an error, we can catch them and display a nice error page. But what if there is an error or a bug in one of middleware components, or web application framework adapters themselves?

Try this code:

    > plackup -e 'sub { return [ 0, {"Content-Type","text/html"}, "Hello" ] }'

Again, writing a raw PSGI interface is not something end users would do every day, but this could be a good emulation of what would happen if there's a bug in one of middleware components or framework adapters itself.

When you access this application with the browser, the server dies with:

    Not an ARRAY reference at lib/Plack/Util.pm line 145.

or something similar. This is because the response format is invalid per the PSGI interface: the status code is not valid, HTTP headers is not an array ref but a hash reference and the response body is a string instead of an array ref.

### Lint middleware

Checking them in the individual server for every request at a run time is *possible* but not *ideal*: that will be a duplicate of codes, and doing so in every request is not efficient from the performance standpoint. We should better validate if an application, middleware or server backend conforms to the PSGI interface using the test suite during the development and disable that when running on production for the best performance.

Middleware::Lint is the middleware to validate request and response interface. Run the application above with the middleware:

    > plackup -e 'enable "Lint"; sub { return [ 0, { "Content-Type"=>"text/html" }, ["Hello"] ] }'

and now requests for the application would give a nice stack trace saying:

    status code needs to be an integer greater than or equal to 100 at ...

since now the Lint middleware checks if the response in the valid PSGI format.

When you develop a new framework adapter or a middleware component, be sure to check with Middleware::Lint during the development. 

### Writing a new PSGI server

Middleware::Lint validates both request and response interface, so this can be used when you develop a new PSGI web server as well. However if you are a server developer there's a more comprehensive testing tool to make sure your server behaves correctly, and that is Plack::Test::Suite.

You can look at the existing tests in the `t/Plack-Server` directory for how to use this utility, but it defines lots of expected requests and responses pairs to test a new PSGI server backend. Existing Plack::Server backends included in Plack core distribution as well as other CPAN distributions all pass this test suite.