## Day 1: Getting Plack

The most important step to get started is to install [Plack](http://search.cpan.org/dist/Plack) and other utilities. Because PSGI and Plack are just normal Perl module distributions the installation is easy: just launch your CPAN shell and type:

```
cpan> install PSGI Plack
```

[PSGI](http://search.cpan.org/dist/PSGI) is a specification document for the PSGI interface. By installing the distribution you can read the documents in your shell with the `perldoc PSGI` or `perldoc PSGI::FAQ` commands. Plack gives you the standard server implementations, core middleware components, and utilities like plackup and Plack::Test.

Plack doesn't depend on any non-core XS modules so with any Perl distribution later than 5.8.1 (which was released more than 6 years ago!) it can be installed very easily, even on platforms like Win32 or Mac OS X without developer tools (e.g., C compilers).

If you're a developer of web applications or frameworks (I suppose you are!), it's highly recommended you install the optional module bundle [Task::Plack](http://search.cpan.org/dist/Task-Plack) as well. The installation is as easy as typing:

```
cpan> install Task::Plack
```

You will be prompted with a couple of questions depending on your environment. If you're unsure whether you should or should not install, just type return to select the default. You'll get optional XS speedups by default, while other options like non-blocking environments are disabled by default.

Start reading the documentation with `perldoc Plack` to get prepared.
