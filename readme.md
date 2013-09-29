
PCRE#
===============================================================

what is this
--------------------------------

SML# <-> libpcre (Perl Compatible Regular Expressions) binding wrapper library.

This library allows you to use regexp library (libpcre) from SML# system.

requirements
--------------------------------

- [SML# 1.2.0](http://www.pllab.riec.tohoku.ac.jp/smlsharp/ja/)
- [libpcre](http://www.pcre.org/)
  - PCRE# is developped with PCRE-8.12


build
--------------------------------

```sh
 $ make
```

how to use
--------------------------------

see test.sml

use from REPL
--------------------------------

use library from SML# repl.

```sh
 $ smlsharp -lpcre -L<path/to/libpcre.a>
 # use "either.sml";
 # use "pcre_raw.sml";
 # use "pcre.sml";
```

