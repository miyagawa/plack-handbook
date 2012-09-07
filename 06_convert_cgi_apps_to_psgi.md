# Day 6: Convert CGI apps to PSGI

The most popular web server environments to run web applications, for Perl, has been CGI, FastCGI and mod\_perl. CGI.pm is one of the Perl core module that happens to runs fine on any of those environments (with some tweaks). That means most web applications and frameworks somehow uses CGI.pm to deal with the environment differences because it's the easiest.

[CGI::PSGI][1] is a CGI module subclass that makes it easy to migrate existing CGI.pm based applications to PSGI. Imagine you have the following CGI application:

```
use CGI;

my $q = CGI->new;
print $q->header('text/plain'),
    "Hello ", $q->param('name');
```

This is a very simple CGI application, and converting this to PSGI is easy using the CGI::PSGI module:

```
use CGI::PSGI;

my $app = sub {
    my $env = shift;
    my $q = CGI::PSGI->new($env);
    return [
        $q->psgi_header('text/plain'),
        [ "Hello ", $q->param('name') ],
    ];
};
```

`CGI::PSGI->new($env)` takes the PSGI environment hash and creates an instance of CGI::PSGI, which is a subclass of CGI.pm. All methods including `param()`, `query_string` etc. do the right thing to get the values from PSGI environment rather than CGI's ENV values.

`psgi_header` is an utility method to work just like CGI's `header` method, and returns the status code and an array reference containing the list of HTTP headers.

Tomorrow, I'll talk about how to convert existing web frameworks that uses CGI.pm, using CGI::PSGI.

  [1]: http://search.cpan.org/perldoc?CGI::PSGI
