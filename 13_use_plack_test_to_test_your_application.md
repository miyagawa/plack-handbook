# Day 13: use Plack::Test to test your application

### Testing

There are many ways to test web applications, either with a live server or using a mock request technique. Some web application frameworks allow you to write an unit test using one of those methods, but the way you write tests differ per framework of your choice.

Plack::Test gives you *an unified interface* to test *any* web applications and frameworks that is compatible to PSGI using *both* mock request and live HTTP server.

### Using Plack::Test

Using Plack::Test is pretty simple and it's of course compatible to the Perl's standard testing protocol [TAP](http://testanything.org/wiki/) and [Test::More](http://search.cpan.org/perloc?Test::More).

    use Plack::Test;
    use Test::More;
    use HTTP::Request;
    
    my $app = sub {
        return [ 200, [ 'Content-Type', 'text/plain' ], [ "Hello" ] ];
    };
    
    test_psgi $app, sub {
        my $cb = shift;
        
        my $req = HTTP::Request->new(GET => 'http://localhost/');
        my $res = $cb->($req);
        
        is $res->code, 200;
        is $res->content, "Hello";
    };
    
    done_testing;

Create or load PSGI application like usual (you can use [Plack::Util](http://search.cpan.org/perldoc?Plack::Util)'s `load_psgi` function if you want to load an app from a `.psgi` file), and call `test_psgi` function to test the application. The second argument is a callback that acts as a testing client.

You can use the named parameters as well, like the following.

    test_psgi app => $app, client => sub { ... }

The client code takes a callback (`$cb`), which you can pass an HTTP::Request object that would return HTTP::Response object, like normal LWP::UserAgent would do, and you can make as many requests as you want, and test various attributes and response details.

Save that code as `.t` file and use the tool such as `prove` to run the tests.

### use HTTP::Request::Common

This is not required, but recommended to use [HTTP::Request::Common](http://search.cpan.org/perldoc?HTTP::Request::Common) when you want to make an HTTP request, since it's more obvious and less code to write:

    use HTTP::Request::Common;
    
    test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->(GET "/");
        # ...
    };

Notice that you can even omit the scheme and hostname, which would default to http://localhost/ anyway.

### Run in a server/mock mode

By default the `test_psgi` function's callback runs as a *Mock HTTP* request mode, turning a HTTP::Request object into a PSGI env hash and then run the PSGI application, and returns the response as a HTTP::Response object.

You can change this to live HTTP mode, by setting either a) the package variable `$Plack::Test::Impl` or b) the environment variable `PLACK_TEST_IMPL` to the string `Server`.

    use Plack::Test;
    $Plack::Test::Impl = "Server";
    
    test_psgi ... # the same code

By using the environment variable, you don't really need to change the .t code:

    env PLACK_TEST_IMPL=Server prove -l t/test.t

This will run the PSGI application using the Standalone server backend and uses LWP::UserAgent to send the live HTTP request. You don't need to modify your testing client code, and the callback would automatically adjust host names and port numbers depending on the test configuration.

### Test your web application framework with Plack::Test

Once again, the beauty of PSGI and Plack is that everything written to run for the PSGI interface can be used for *any* web application frameworks that speaks PSGI. By [running your web application framework in PSGI mode](http://advent.plackperl.org/2009/12/day-7-use-web-application-framework-in-psgi.html), you can also use Plack::Test:

    use Plack::Test;
    use MyCatalystApp;
    
    MyCatalystApp->setup_engine('PSGI');
    my $app = sub { MyCatalystApp->run(@_) };
    
    test_psgi $app, sub {
        my $cb = shift;
        # ...
    };
    done_testing;

You can of course do the same thing against any frameworks that supports PSGI.
