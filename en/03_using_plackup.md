## Day 3: Using plackup

In [day 2](http://advent.plackperl.org/2009/12/day-2-hello-world.html) article I used the plackup command to run the Hello World PSGI application. 

Plackup is a command line launcher of PSGI applications, inspired by Rack's rackup command. It can be used to run any PSGI applications saved in .psgi file with one of PSGI web server backends using Plack handlers. The usage is simple, just give a .psgi file path to the command:

    > plackup hello.psgi
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

You can actually omit the filename as well if you're trying to run the file called `app.psgi` in the current directory.

The default backend is chosen using one of the following methods.

* If the environment variable `PLACK_SERVER` is set, it is used
* If some environment specific variable like `GATEWAY_INTERFACE` or `FCGI_ROLE` is set, the backends for CGI or FCGI is used accordingly.
* If loaded `.psgi` file uses specific event modules like AnyEvent, Coro or POE, the equivalent and most appropriate backend is chosen automatically.
* Otherwise, fallback to the default "Standalone" backend, implemented as HTTP::Server::PSGI module.

You can also specify the backend yourself from the command line using `-s` or `--server` switch, like:

    > plackup -s Starman hello.psgi

plackup command would by default enable three middleware components: Lint, AccessLog and StackTrace to help aid the development, but you can disable them with the `-E` (or `--environment`) switch:

    > plackup -E production -s Starman hello.psgi

In case you really want to use `development` Plack environment but want to disable the default middleware, there is `--
no-default-middleware` option too.

Other command line switches would also be passed to the server, so you can specify the Server listen port with:

    > plackup -s Starlet --host 127.0.0.1 --port 8080 hello.psgi
    Plack::Handler::Starlet: Accepting connections at http://127.0.0.1:8080/

or specify the unix domain socket the FCGI backend would listen:

    > plackup -s FCGI --listen /tmp/fcgi.sock app.psgi

For more options for plackup, run `perldoc plackup` from the command line. You'll see more plackup options and hacks tomorrow as well.
