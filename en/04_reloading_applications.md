## Day 4: Reloading applications

[Yesterday](http://advent.plackperl.org/2009/12/day-3-using-plackup.html) I introduced the basics of plackup and its command line options. Today I'll show you more!

### Reload the application as necessary

During development you often change your Perl code, saved in `.psgi` or `.pm` files. Because the Plack server launched by the plackup command is a persistent process your Perl code (PSGI application) is compiled and runs multiple times. So you need to restart your server whenever your code changes and it's a little painful.

So there's an option to watch changes for files under your working directory and reloads the application as needed: `-r` (or `--reload`).

    plackup -r hello.psgi

It will watch files under the current directory by default, but you can change that to somewhere else by using the `-R` (note the upper case) option:

    plackup -R lib,/path/to/scripts hello.psgi

as you can see, multiple paths can be monitored by combining them with `,` (comma).

By default plackup uses a dumb timer to scan the whole directory, but if you're on Linux and have Linux::Inotify2 or on Mac OS and have Mac::FSEvents installed the filesystem notification is used so it's more efficient.

### -r vs Server auto-detection

In Day 3 I told you that the plackup's automatic server detection is smart so if your PSGI application uses one of the event modules AnyEvent or Coro the correct backend would be chosen. Be aware that this automatic selection doesn't work if you use the `-r` option because plackup will use a delayed loading technique to reload apps in the forked processes. It's recommended that you explicitly set the server with `-s` option when using the `-r` option.

### Reloading sucks? Shotgun!

Reloading a module or application on a persistent Perl process could cause problems. For instance, module package variables could be redefined or overwritten and then stuck in a bad state.

Plack now has the Shotgun loader, inspired by [Rack's shotgun](http://github.com/rtomayko/shotgun), which solves the reloading problem by loading the app on *every request* in a forked child environment.

Using the Shotgun loader is easy:

    > plackup -L Shotgun myapp.psgi

This will delay the compilation of your application to runtime. When a request is received it will fork off a new child process to compile your app and return the PSGI response over the pipe. You can also preload modules in the parent process that are not likely to be updated to reduce the time needed to compile your application.

For instance, if your application uses Moose and DBIx::Class then pass the following options to the command:

    > plackup -MMoose -MDBIx::Class -L Shotgun myapp.psgi

and speed up the time required to compile your application in the runtime.
