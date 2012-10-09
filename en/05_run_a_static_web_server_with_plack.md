## Day 5: Run a static web server with Plack

The Plack distribution comes with some ready made PSGI applications in the Plack::App namespace. Some of them might be pretty handy, examples of that would be [Plack::App::File](http://search.cpan.org/perldoc?Plack::App::File) and [Plack::App::Directory](http://search.cpan.org/perldoc?Plack::App::Directory).

Plack::App::File translates a request path like `/foo/bar.html` into a local file like `/path/to/htdocs/foo/bar.html` and opens the file handle and passes it back as a PSGI response. So it does basically what a static web server like lighttpd, nginx or Apache does.

Plack::App::Directory is a wrapper around Plack::App::File that gives a directory index, just like [Apache's mod_autoindex](http://httpd.apache.org/docs/2.0/mod/mod_autoindex.html) does.

Using these applications is pretty easy. Just write a .psgi file like this:

    use Plack::App::File;
    my $app = Plack::App::File->new(root => "$ENV{HOME}/public_html");

and run it with plackup:

    > plackup file.psgi

now you can get any file under your `~/public_html` with the URL http://localhost:5000/somefile.html

You can also use Plack::App::Directory. This time let's run it with just the plackup command line without a .psgi file:

    > plackup -MPlack::App::Directory \
     -e 'Plack::App::Directory->new(root => "$ENV{HOME}/Sites");
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

The plackup command, like the perl command itself, accepts flags like `-I` (include path), `-M` (modules to load), and `-e` (the code to eval), so it's easy to load these Plack::App::* applications without ever touching a .psgi file!

There are a couple of other Plack::App applications in the Plack distribution.
