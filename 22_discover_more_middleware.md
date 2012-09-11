# Day 22: Discover more middleware

Christmas is coming near and there aren't enough days to explore more middleware components. Today I'll show you a quick intro of great middleware components that I haven't had time to show.

### ErrorDocument

When you die out from an application or display some "Forbidden" error message when an auth wasn't successful you'll probably want to display a custom error page based on the response status code. ErrorDocument is exactly the middleware that does this, like Apache's ErrorDocument directive.

    builder {
        enable "ErrorDocument", 500 => "/path/to/error.html";
        $app;
    };

You can just map arbitrary error code to a static file path to be served. You can enable StackTrace middleware during the development and then this ErrorDocument middleware on the production so as to display nicer error pages.

This middleware is included in the Plack core distribution.

### Session

Actually this is (again) a steal from [Rack](http://rack.rubyforge.org/). Rack defines `rack.session` as a standard Rack environment hash and defines the interface as Ruby's built-in Hash object. We didn't define it as part of the standard interface but stole the idea and actual implementation a lot. 

     builder {
         enable "Session", store => "File";
         $qpp;
     };

By default Session will save the session in on-memory hash, which wouldn't work with the prefork (or multi process) servers. It's shipped with a couple of default store engines such as [CHI](http://search.cpan.org/perldoc?CHI), so it's so easy to adapt to other storage engines, exactly like we see with other middleware components such as Auth.

Session object has standard methods like `get` and `set` and can be accessed with `plack.session` key in the PSGI env hash. Application and frameworks with access to PSGI env hash can use this Session freely in the app, like in Tatsumaki:

     # Tatsumaki app
     sub get {
         my $self = shift;
         my $uid = $self->request->session->get('uid');
         $self->request->session->set(last_access => time);
         ...
     }

And the nice thing is that *any* PSGI apps can share this session data as long as they use the same storage etc. Some existing framework adapters don't have an access to this environment hash from end users application yet, so it should be updated gradually in the near future.

Session middleware is developed by Stevan Little on [github](http://github.com/stevan/plack-middleware-session) and is available on CPAN as well.

### Debug

This is a steal from [Rack-bug](http://github.com/brynary/rack-bug) and [django debug toolbar](http://github.com/robhudson/django-debug-toolbar). By enabling this middleware you'll see the handy debug "panels" in the right side where you can click and see the detailed data and analysis about the request.

The panels include Timer (the request time), Memory (how is memory increased if there's any leaks), Request (Detailed request headers) and Responses (Response headers etc.) and so on.

     builder {
         enable "Debug";
         $app;
     };

Using it is so easy as this, and you an also pass the list of `panels` to enable only certain panels or additional non default panels.

More extensions for the panels, such as DBI query profiler or Catalyst log dumper are being developed on [github](http://github.com/hanekomu/plack-middleware-debug/).

### Proxy

It's often useful to proxy HTTP requests to another application, either running on the internet or inside the same network. The former would be necessary if you want to proxy long poll or some JSON API from your application that doesn't support JSONP (because of Cross domain origin policy), and the latter would be to run applications on different machine and use your app as a reverse proxy, though chances are you want to use frontend web servers like nginx, lighttpd or perlbal to do the job.

Anyway, Plack::App::Proxy is the middleware to do this:

    use Plack::App::Proxy;
    use Plack::Builder;
    
    my $app = Plack::App::Proxy->new(host => '192.168.0.2:8080')->to_app;
    
    builder {
        mount "/app" => $app;
    };

Proxy middleware is developed by Lee Aylward on [github](http://github.com/leedo/Plack-App-Proxy).

### More

There are more middleware components available in the Plack distribution, and on [CPAN](http://search.cpan.org/search?query=plack+middleware&mode=dist). Not all middleware components are supposed to be great, but certainly they can be shared and used by most frameworks that support PSGI.
