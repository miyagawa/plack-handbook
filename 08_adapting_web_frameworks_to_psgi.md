# Day 8: Adapting web frameworks to PSGI

The biggest benefit of PSGI in terms of web application framework developers is that, once you adapt your framework to run on PSGI, you forget and throw away everything else that you needed to deal with, say, handle the differences between bunch of FastCGI servers or CGI.

Similarly, if you have a large scale web application, open source or proprietary, you probably have your own web application framework (or a base class or whatever).

Today's entry discusses how to convert existing web application framework to adapt to the PSGI interface.

## CGI.pm based framework

In Day 7 we saw how to run CGI::Application based application in PSGI, using CGI::Application::PSGI. CGI::Application, as the name suggests, uses CGI.pm, so using CGI::PSGI instead and define a new runner class is the easiest to go.

```
package CGI::Application::PSGI;
use strict;
use CGI::PSGI;

sub run {
    my($class, $app) = @_;

    # HACK: deprecate HTTP header generation
    # -- CGI::Application should support some flag to turn this off cleanly
    my $body = do {
        no warnings 'redefine';
        local *CGI::Application::_send_headers = sub { '' };
        local $ENV{CGI_APP_RETURN_ONLY} = 1;
        $app->run;
    };

    my $q    = $app->query;
    my $type = $app->header_type;

    my @headers = $q->psgi_header($app->header_props);
    return [ @headers, [ $body ] ];
}
```

This is quite simple, isn't it? CGI::Application's `run()` method usually returns the whole output, including HTTP headers and content body. As you can see, the module does some gross hack to disable the header generation since you can use `psgi_header` method of CGI::PSGI to generate the status code and HTTP headers as an array ref.

I've implemented PSGI adapters for [Mason][1] and [Maypole][2] and the code was pretty much look alike.

* Create CGI::PSGI out of `$env` and set that instead of the default CGI.pm instance
* Disable HTTP header generation if needed
* Runs the app main dispatcher
* Extracts the HTTP headers to be sent, use `psgi_header` to generate the status and headers
* Extracts the response body (content)

## Adapter based framework

If the framework in question already uses adapter based approaches to abstract server environments, it'd be much easier to adapt to PSGI, by reusing most of the CGI adapter code. Here's the code to adapt [Squatting][3] to PSGI. Squatting uses Squatting::On::\* namespace to adapt to environments like mod\_perl, FastCGI or even other frameworks like Catalyst or HTTP::Engine. It was extremely easy to write [Squatting::On::PSGI][4]:

```
package Squatting::On::PSGI;
use strict;
use CGI::Cookie;
use Plack::Request;
use Squatting::H;

my %p;
$p{init_cc} = sub {
  my ($c, $env)  = @_;
  my $cc       = $c->clone;
  $cc->env     = $env;
  $cc->cookies = $p{c}->($env->{HTTP_COOKIE} || '');
  $cc->input   = $p{i}->($env);
  $cc->headers = { 'Content-Type' => 'text/html' };
  $cc->v       = { };
  $cc->status  = 200;
  $cc;
};

# \%input = i($env)  # Extract CGI parameters from an env object
$p{i} = sub {
  my $r = Plack::Request->new($_[0]);
  my $p = $r->params;
  +{%$p};
};

# \%cookies = $p{c}->($cookie_header)  # Parse Cookie header(s).
$p{c} = sub {
  +{ map { ref($_) ? $_->value : $_ } CGI::Cookie->parse($_[0]) };
};

sub psgi {
  my ($app, $env) = @_;

  $env->{PATH_INFO} ||= "/";
  $env->{REQUEST_PATH} ||= do {
      my $script_name = $env->{SCRIPT_NAME};
      $script_name =~ s{/$}{};
      $script_name . $env->{PATH_INFO};
  };
  $env->{REQUEST_URI} ||= do {
    ($env->{QUERY_STRING})
      ? "$env->{REQUEST_PATH}?$env->{QUERY_STRING}"
      : $env->{REQUEST_PATH};
  };

  my $res;
  eval {
      no strict 'refs';
      my ($c, $args) = &{ $app . "::D" }($env->{REQUEST_PATH});
      my $cc = $p{init_cc}->($c, $env);
      my $content = $app->service($cc, @$args);

      $res = [
          $cc->status,
          [ %{ $cc->{headers} } ],
          [ $content ],
      ];
  };

  if ($@) {
      $res = [ 500, [ 'Content-Type' => 'text/plain' ], [ "<pre>$@</pre>" ] ];
  }

  return $res;
}
```

This is very straightforward, especially when compared with [Squatting::On::CGI][5]. It's almost line-by-line copy and some adjustment to use Plack::Request to parse parameters instead of CGI.pm.

Similarly Catalyst uses Catalyst::Engine abstraction and [Catalyst::Engine::PSGI][6] is the adapter to run Catlayst on PSGI, which most of the code is copied from CGI.

## mod\_perl centric frameworks

Some frameworks are centered around mod\_perl's API, in which case we can't take the approaches like we've seen here. Instead, you should probably start by mocking Apache::Request APIs using a fake/mock object. Patric Donelan, a WebGUI developer explains his approach to make mod\_perl-like API in [his blog post][7] that you might be interested in, and the [mock request class linked][8] would be a good start.

  [1]: http://search.cpan.org/perldoc?HTML::Mason
  [2]: http://search.cpan.org/perldoc?Maypole
  [3]: http://search.cpan.org/perldoc?Squatting
  [4]: http://search.cpan.org/perldoc?Squatting::On::PSGI
  [5]: http://cpansearch.perl.org/src/BEPPU/Squatting-0.70/lib/Squatting/On/CGI.pm
  [6]: http://search.cpan.org/perldoc?Catalyst::Engine::PSGI
  [7]: http://blog.patspam.com/2009/plack-roundup-at-sf-pm
  [8]: http://github.com/pdonelan/webgui/blob/plebgui/lib/WebGUI/Session/Plack.pm
