# Day 1: Getting Plack

The most important step to get started is to install [Plack][1] and other utilities. Because PSGI and Plack are just like normal Perl module distributions, the installation is as easy: just launch your CPAN shell and type

cpan> install PSGI Plack

[PSGI][2] is a specification document for PSGI interface, so by installing the distribution you can read the documents on your shell with `perldoc PSGI` or `perldoc PSGI::FAQ` command. Plack gives you the standard server implementations, core middleware components and utilities like plackup or Plack::Test.

Plack doesn't depend on any non-core XS modules, so with any Perl distribution later than 5.8.1 (which was released more than 6 years ago!) it can be installed very easily, even on platforms like Win32 or Mac OS X without developer tools (i.e. C compilers).

If you're a developer of web applications or frameworks (I suppose you are!), you're highly recommended to install optional module bundle [Task::Plack][3] as well. The installation is equally easy as just typing:

cpan&gt; install Task::Plack

It will prompt you a couple of questions depending on your environment. If you're unsure whether you should or should not install, just type return to pick the default. You'll get optional XS speedups by default, while other servers like non-blocking environments are disabled by default.

Start reading docs with `perldoc Plack` to get prepared.

  [1]: http://search.cpan.org/dist/Plack
  [2]: http://search.cpan.org/dist/PSGI
  [3]: http://search.cpan.org/dist/Task-Plack