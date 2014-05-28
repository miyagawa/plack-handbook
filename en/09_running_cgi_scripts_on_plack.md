## Day 9: Running CGI scripts on Plack

For the last couple of days we've been talking about how to convert existing CGI based applications to PSGI, and then run them as a PSGI application. Today we will show you the ultimate way to run *any* CGI scripts as a PSGI application, most of the time unmodified.

[CGI::PSGI](http://search.cpan.org/perldoc?CGI::PSGI) is a subclass of CGI.pm to allow you a very easy migration from CGI.pm with only *a few lines of code changes* to run it on PSGI environment. But what about a messy or legacy CGI script that just prints to STDOUT a lot and is not easy to fix?

[CGI::Emulate::PSGI](http://search.cpan.org/perldoc?CGI::Emulate::PSGI) is a module to run any CGI based perl program in a PSGI environment. Whatever messy/old script that prints stuff to STDOUT or directly reads HTTP headers from `%ENV` would just work because that's what CGI::Emulate::PSGI tries to emulate. The original POD of CGI::Emulate::PSGI was illustrating it like:

    use CGI::Emulate::PSGI;
    CGI::Emulate::PSGI->handler(sub {
        do "/path/to/foo.cgi";
        CGI::initialize_globals() if &CGI::initialize_globals;
    });

to run existing CGI application that may or may not use CGI.pm (CGI.pm caches lots of environment variables so it needs `initialize_globals()` call to clear out the previous request variables).

A few days ago on my flight from San Francisco to London to attend London Perl Workshop I was hacking on something more intelligent, that is to take any CGI scripts and compiles it into a subroutine. The module is named [CGI::Compile](http://search.cpan.org/perldoc?CGI::Compile) and should be best used combined with CGI::Emulate::PSGI.

    my $sub = CGI::Compile->compile("/path/to/script.cgi");
    my $app = CGI::Emulate::PSGI->handler($sub);

There's also [Plack::App::CGIBin](http://search.cpan.org/perldoc?Plack::App::CGIBin) Plack application to run existing CGI scripts written in Perl as PSGI applications, suppose you have bunch of CGI scripts in `/path/to/cgi-bin`, you'll run the server with:

    > plackup -MPlack::App::CGIBin -e 'Plack::App::CGIBin->new(root => "/path/to/cgi-bin"))'

And that will mount the path `/path/to/cgi-bin`, so suppose you have `foo.pl` in that directory, you can access http://localhost:5000/foo.pl to run the CGI application as a PSGI over the plackup, just like the scripts running on Apache mod_perl Registry mechanism.
