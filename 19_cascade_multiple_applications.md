# Day 19: Cascade multiple applications

[Conditional middleware](http://advent.plackperl.org/2009/12/day-18-load-middleware-conditionally.html) and [URLMap app](http://advent.plackperl.org/2009/12/day-12-maps-multiple-apps-with-mount-and-urlmap.html) have something in common: they're PSGI applications but both takes PSGI application or middleware and dispatch them. This is the beauty of PSGI application and middleware architecture and today's application is another example of this.

### Cascading multiple applications

Cascading can be useful if you have a couple of applications and runs in order, then try until it returns a successful response. This is sometimes called [Chain of responsibility](http://en.wikipedia.org/wiki/Chain-of-responsibility_pattern) design pattern and often used in web applications such as [mod_perl handlers](http://perl.apache.org/docs/2.0/user/handlers/intro.html).

### Cascade Application

Plack::App::Cascade allows you to composite multiple applications in order and runs until it returns non-404 responses.

    use Plack::App::Cascade;
    use Plack::App::File;
    use Plack::App::URLMap;
    
    my @paths = qw(
        /home/www/static
        /virtualhost/example.com/htdocs/static
        /users/miyagawa/public_html/images
    );
    
    my $app = Plack::App::Cascade->new;
    for my $path (@paths) {
        my $file = Plack::App::File->new(root => $path);
        $app->add($file);
    }
    
    my $map = Plack::App::URLMap->new;
    $map->mount("/static" => $app);
    $map->to_app;

This application is mapped to `/static` using URLMap, and all requests will try the three directories specified in `@paths` using App::File application and returns the first found  files. It might be useful if you want to serve static files but want to cascade from multiple directories like this.

### Cascade different apps

    use CatalystApp;
    CatalystApp->setup_engine('PSGI');
    my $app1 = sub { CatalystApp->run(@_) };
    
    use CGI::Application::PSGI;
    use CGIApp;
    my $app2 = sub {
        my $app = CGIApp->new({
            QUERY => CGI::PSGI->new($_[0]),
        });
        CGI::Application::PSGI->run($app);
    };
    
    use Plack::App::Cascade;
    Plack::App::Cascade->new(apps => [ $app1, $app2 ])->to_app;

This will create two applications, one with Catalyst and the other with CGI::Application and runs two applications in order. Suppose you have an overlapping URL structure and `/what/ever.cat` served with the Catalyst application and `/what/ever.cgiapp` served with the CGI::Application app.

Well that might sound crazy and i guess it's better to use URLMap to map two applications in different paths, but if you *really want* to cascade them, this is the way to go :)

        
        