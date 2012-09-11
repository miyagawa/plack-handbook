# Day 4: Reloading applications

[Yesterday](http://advent.plackperl.org/2009/12/day-3-using-plackup.html) I introduced the basics of plackup and its command line options. Today I'll show you more!

### Reload the application as necessary

During the development you often change your perl code, saved in `.psgi` or `.pm` files. Because Plack servers launched by plackup command is a persistent process, your Perl code (PSGI application) is compiled and runs multiple times. So you need to restart your server whenever needed, and it's a little painful.

So there's an option to watch changes for files under your working directory and reloads the application as needed: `-r` (or `--reload`).

    plackup -r hello.psgi

It will watch files under the current directory by default, but you can change that to somewhere else by using `-R` (note the upper case) option:

    plackup -R lib,/path/to/scripts hello.psgi

as you can see, multiple paths can be monitored by combining them with `,` (comma).

By default it uses a dumb timer to scan the whole directory, but if you're on Linux and have Linux::Inotify2, or on Mac and have Mac::FSEvents installed, these filesystem notification is used, so it's more efficient.

### -r vs Server auto-detection

In Day 3 I told you that the plackup's server automatic detection is smart, so if your PSGI application uses one of the event modules AnyEvent, POE or Coro, the correct backend would be chosen. Beware this automatic selection doesn't work if you use `-r` option, because plackup will now use the delayed loading technique to reload apps in the forked processes. You're recommended to explicitly set the server with `-s` option when combined with `-r` option.

### Reloading sucks? Shotgun!

Reloading a module or application on a persistent perl process could cause problems, like  some module package variables are redefined or overwritten and then stuck in a bad state. 

Plack now has Shotgun loader, which is inspired by [Rack's shotgun](http://github.com/rtomayko/shotgun) and solves the reloading problem by loading the app on *every request* in a forked child environment.

Using Shotgun loader is easy:

    > plackup -L Shotgun myapp.psgi

This will delay load the compilation of your application until the runtime, and when a request comes, it forks off a new child process to compile your app and returns the PSGI response over the pipe. You can also preload the modules that are not likely to be updated in the parent process to reduce the time needed to compile your application.

For instance, if your application uses Moose and DBIx::Class, then you can say:

    > plackup -MMoose -MDBIx::Class -L Shotgun myapp.psgi

would speed up the time required to compile your application in the runtime.