## Day 7: Use web application framework in PSGI

Since we started this Plack and PSGI project in September 2009, there has been lots of feedback from the authors of many popular frameworks such as Catalyst, Jifty, and CGI::Application.

[CGI::Application](http://cgi-app.org/) is one of the most "traditional" CGI-based web application framework and it uses CGI.pm exclusively to handle web server environments just like we [discussed yesterday](http://advent.plackperl.org/2009/12/day-6-convert-cgi-apps-to-psgi.html).

Mark Stosberg, the current maintainer of CGI::Application, and I have been collaborating on adding PSGI support to CGI::Application. We thought of multiple approaches including adding native PSGI support to CGI.pm, but we ended up implementing [CGI::PSGI](http://search.cpan.org/perldoc?CGI::PSGI) as a CGI.pm wrapper and then [CGI::Application::PSGI](http://search.cpan.org/perldoc?CGI::Application::PSGI) to run existing CGI::Application code *unmodified* in a PSGI compatible mode.

All you have to do is to install CGI::Application::PSGI from CPAN and write a .psgi file that looks like this:

    use CGI::Application::PSGI;
    use WebApp;

    my $app = sub {
        my $env = shift;
        my $app = WebApp->new({ QUERY => CGI::PSGI->new($env) });
        CGI::Application::PSGI->run($app);
    };

Then use [plackup](http://advent.plackperl.org/2009/12/day-3-using-plackup.html) to run the application with a standalone server or any of the other backends.

Similarly, most web frameworks that support PSGI provide a plugin, engine, or adapter to make the framework run in PSGI mode. For instance, [Catalyst](http://www.catalystframework.org/) has a Catalyst::Engine::* web server abstraction and [Catalyst::Engine::PSGI](http://search.cpan.org/perldoc?Catalyst::Engine::PSGI) is the engine to adapt Catalyst to run on PSGI. (**EDIT**: As of Catalyst 5.8 released in 2011, Catalyst supports PSGI by default and there's no need to install a separate engine.)

The point is that with PSGI support from web frameworks your application often won't need to have a single line of code modified. And by switching to PSGI there are lots of benefits like being able to use the toolchain of plackup, Plack::Test, and middleware which we'll discuss in future advent entries.
