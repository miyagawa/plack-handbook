# Day 7: Use web application framework in PSGI

Since we started this Plack and PSGI project in September, there have been lots of feedbacks from the authors of most popular frameworks, like Catalyst, Jifty and CGI::Application.

[CGI::Application](http://cgi-app.org/) is one of the most "traditional" CGI-based web application framework, and it's using CGI.pm exclusively to handle web server environments just like we [discussed yesterday](http://advent.plackperl.org/2009/12/day-6-convert-cgi-apps-to-psgi.html).

Mark Stosberg, the current maintainer of CGI::Application and I have been collaborating on adding PSGI support to CGI::Application. We thought of multiple approaches, including adding a native PSGI support to CGI.pm, but we ended up implementing [CGI::PSGI](http://search.cpan.org/perldoc?CGI::PSGI) as a CGI.pm wrapper and then [CGI::Application::PSGI](http://search.cpan.org/perldoc?CGI::Application::PSGI) to run existing CGI::Application *unmodified* in a PSGI compatible mode.

All you have to do is to install CGI::Application::PSGI from CPAN and write a .psgi file that looks like this:

    use CGI::Application::PSGI;
    use WebApp;

    my $app = sub {
        my $env = shift;
        my $app = WebApp->new({ QUERY => CGI::PSGI->new($env) });
        CGI::Application::PSGI->run($app);
    };

and use [plackup](http://advent.plackperl.org/2009/12/day-3-using-plackup.html) to run the application with a standalone server or any other backends.

Similarly, most web frameworks that "supports" PSGI provides a plugin, engine or adapter to make the framework run on PSGI mode. For instance, [Catalyst](http://www.catalystframework.org/) has a Catalyst::Engine::* web server abstraction and [Catalyst::Engine::PSGI](http://search.cpan.org/perldoc?Catalyst::Engine::PSGI) is the engine to adapt Catalyst to run on PSGI.

The point is that with "PSGI support" from web frameworks, your application doesn't need to be modified, most of the times any single lines of code. And then by switching to PSGI you'll have lots of benefits like being able to use toolchain like plackup, Plack::Test and middleware which we'll discuss later in the future advent entries.
