# Nxxd Hex Dump tool

Yet another Xxd reimplementation.

The original Xxd is part of the Vim editor (<https://www.vim.org>).
This one is written in plain Ruby.


## Installation

```bash
sudo gem install nxxd
```


## Command line execution

Plain output:

```bash
echo hello | grep --color=yes -nH ll | nxxd
dd if=/dev/urandom bs=16 count=4 status=none | nxxd
```

The filename will be added as a comment, unless you explicitly ask to refrain
from that.

```bash
nxxd    /bin/sleep 2>/dev/null | head
nxxd -p /bin/sleep 2>/dev/null | head
```

Repeated lines will be squeezed by default.

```bash
dd if=/dev/zero bs=16 count=4 status=none | nxxd
dd if=/dev/zero bs=16 count=4 status=none | nxxd -a
dd if=/dev/zero bs=16 count=4 status=none | nxxd -f
ruby -e 'print "xyz="*16' | nxxd
```

Reverse operation.

```bash
echo '42617a696e6761210a' | nxxd -r
echo hello | grep --color=yes -nH ll | nxxd | nxxd -r
```

C source code output.

```bash
nxxd -i someimage.png
```

Get help.

```bash
nxxd  -h
```


## Ruby classes and methods

Here's an example:

```ruby
require "nxxd"

data = " !\"\#$%&'()*+,-./0123456789:;<=>?"
Nxxd::Dump.new.run data do |l| puts l end
```

Reverse operation allows free address jumping.
Both string and file output can be done.

```ruby
require "nxxd"

x = <<~EOT
0004: 204d 696c 6b79 2047 7265 656e 0a     Milky Green
0000: 436f 6465                           Code
EOT

s = Nxxd::Dump.reverse x
puts s.encoding, s.length, s.inspect

File.open "status", "w" do |f|
  Nxxd::Dump.reverse x, f
end
```


## Colorization

There is no and there will be no color support. Pipe the output to your
favourite editor and use the syntax highlighting there.

If you are using Vim/Neovim, you might like the more elaborate syntax
highlighting included in this package [xxd.vim](./vim/syntax/xxd.vim).


## Copyright

  * (C) 2025 Bertram Scharpf <software@bertram-scharpf.de>
  * License: [BSD-2-Clause+](./LICENSE)

