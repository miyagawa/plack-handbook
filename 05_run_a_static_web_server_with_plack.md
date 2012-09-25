## Day 5: Run a static web server with Plack

Plack distribution comes with some readymade PSGI applications in Plack::App namespace. Some of them might be pretty handy, and one example for that would be [Plack::App::File](http://search.cpan.org/perldoc?Plack::App::File) and [Plack::App::Directory](http://search.cpan.org/perldoc?Plack::App::Directory).

Plack::App::File is to translate the request path, like `/foo/bar.html` into the local file, like `/path/to/htdocs/foo/bar.html` and opens the file handle and passes it back as a PSGI response. So that's basically what a static web server like lighttpd, nginx or Apache does.

Plack::App::Directory is a wrapper around Plack::App::File to give a directory index, just like [Apache's mod_autoindex](http://httpd.apache.org/docs/2.0/mod/mod_autoindex.html) does.

Using those applications is pretty easy. Just write a .psgi file like this:

    use Plack::App::File;
    my $app = Plack::App::File->new(root => "$ENV{HOME}/public_html");

and run it with the plackup:

    > plackup file.psgi

now you can get any files under your `~/public_html` with the URL http://localhost:5000/somefile.html

You can also use Plack::App::Directory but this time with just the plackup command line, without a .psgi file, like this:

    > plackup -MPlack::App::Directory \
     -e 'Plack::App::Directory->new(root => "$ENV{HOME}/Sites");
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

plackup command, like the perl command itself, accepts flags like `-I` (include path) `-M` (modules to load) and `-e` (the code to eval), so it's easy to load these Plack::App::* applications without even touching a .psgi file!

There is a couple other Plack::App applications in the Plack distribution.