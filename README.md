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

Or just:

```ruby
puts Nxxd::Dump.new.run data
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


## Inside Neovim

If you're using Neovim and the Ruby provider
[ruby-nvim](https://github.com/BertramScharpf/ruby-nvim) (Not the official
neovim-ruby!), you probably prefer to pipe from and to buffers.

```vim
rubyfile <nxxd/nvim>
vertical HexDump /etc/localtime
```

In case you have a string in a Ruby variable, dump it like this:

```vim
ruby t = "tränenüberströmt"
ruby Nxxd::Nvim.dump_data t
```

You may dump a programs output as well:

```vim
HexDump! echo QmF6aW5nYSEK | openssl enc -a -d
HexDump! dd if=/dev/urandom bs=16 count=4
```

Pipe your editor lines to a program like this:

```
 1 H4sIALDvomcAA7u3
 2 dt/7ewOIAX8tU5eA
 3 AAAA
 ~
 ~
:1,3HexPipe openssl enc -a -d | gzip -cd
```

See the file [nxxd.txt](./vim/doc/nxxd.txt) for a full documentation.


## Colorization

There is no and there will be no color support. Pipe the output to your
favourite editor and use the syntax highlighting there.

If you are using Vim/Neovim, you might like the more elaborate syntax
highlighting included in this package [xxd.vim](./vim/syntax/xxd.vim).


## Copyright

  * (C) 2025 Bertram Scharpf <software@bertram-scharpf.de>
  * License: [BSD-2-Clause+](./LICENSE)

