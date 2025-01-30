#
#  nxxd/nvim.rb  --  Neovim commands
#

require "nxxd"

(Neovim::Client === $vim rescue false) or
  raise "This file must be required from inside Neovim using the 'nvim' Rubygem."


[
  "command -nargs=?          -bang -complete=file -bar HexDump call rubyeval('Nxxd::Nvim.dump<bang> %q|<args>|')",
  "command -nargs=? -range=% -bang -complete=file -bar HexPack call rubyeval('Nxxd::Nvim.pack<bang> %q|<args>|, <line1>..<line2>')",
].each { |c| $vim.command c }



module Kernel
  class <<self
    def popen_outerr a
      ro, wo = IO.pipe
      re, we = IO.pipe
      fork do
        ro.close
        re.close
        STDOUT.reopen wo
        STDERR.reopen we
        exec a
      end
      wo.close
      we.close
      yield ro, re
      Process.waitpid
    ensure
      ro.close
      re.close
    end
  end
end


module Nxxd

  module Nvim

    class <<self

      def dump a
        a ||= $vim.get_name 0
        File.open a do |f|
          dump_file a, f
        end
        $vim.get_current_buf.set_var "origfile", a
      end

      def dump! a
        Kernel.popen_outerr a do |ro,re|
          dump_file a, ro
          e = re.read.lines.map { |x| x.chomp! ; "# #{x}" }
          $vim.put e, "l", false, true
        end
        $?.success? or $vim.put [ "### Exit code: #{$?.exitstatus}"], "l", false, true
      end

      private

      def dump_file a, f
        $vim.command "enew"
        $vim.set_option filetype: "xxd", buftype: "nofile"
        $vim.get_current_buf.set_name "[hex: #{a}]"
        (Dump.new input: a).run f do |l|
          $vim.put [l], "l", false, true
        end
      end

      public

      def pack a, range
        pack_check a, range do |d|
          raise "File exists. Overwrite with '!'." if File.exist? d
        end
      end

      def pack! a, range
        pack_check a, range do || end
      end

      private

      def pack_check a, range
        b = $vim.get_current_buf
        a = a.notempty?
        a ||= b.get_var "origfile" rescue nil
        a or raise "No file name given."
        yield a
        File.open a, "w" do |f|
          r = Range.new b, range
          Nxxd::Dump.reverse r, f
        end
      end

    end

    class Range
      def initialize buf, range
        @buf, @range = buf, range
      end
      def each_line &block
        @buf.each @range, &block
      end
    end

  end

end

