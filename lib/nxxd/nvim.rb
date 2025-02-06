#
#  nxxd/nvim.rb  --  Neovim commands
#

require "nxxd"

(Neovim::Client === $vim rescue false) or
  raise "This file must be required from inside Neovim using the 'nvim' Rubygem."


<<~'EOT'.each_line { |c| c.chomp! ; $vim.command c }
  command -nargs=?          -bang -complete=file      HexDump ruby Nxxd::Nvim.dump<bang> <q-args>, <q-mods>
  command -nargs=1 -range=%       -complete=file      HexPipe ruby Nxxd::Nvim.pipe       <q-args>, <q-mods>, <line1>..<line2>
  command -nargs=? -range=% -bang -complete=file -bar HexPack ruby Nxxd::Nvim.pack<bang> <q-args>, <range>, <line1>..<line2>
  command -nargs=1 -range=%       -complete=file      HexFeed ruby Nxxd::Nvim.feed       <q-args>, <line1>..<line2>
EOT


module Nxxd

  module Nvim

    class <<self

      attr_accessor :split

      private

      def split_new mods
        if mods.notempty? then
          "#{mods} new"
        else
          case @split
          when /\bvert/ then "vnew"
          when /\bhor/  then "new"
          else               "enew"
          end
        end
      end

      public

      def dump a, m
        a = a.notempty?
        a ||= cur_buf_name
        File.open a do |f|
          dump_data f, a, m
        end
        $vim.get_current_buf.set_var "origfile", a
      end

      def dump! a, m
        a = a.notempty?
        a ||= cur_buf_name_exec
        pipe a, m, nil
      end

      def pipe a, m, range
        popen a do |ro,re|
          begin
            if range then
              # It would be nicer to write the lines as they are demanded. If
              # you have an idea how this could easily be done, feel free to
              # propose a patch. Putting this begin-end block into a Thread
              # didn't work.
              (Neovim::Lines.new $vim.get_current_buf, range).each { |l| ro.puts l }
            end
            ro.close_write
          end
          dump_data ro, a, m
          re.each_line { |l|
            l.chomp!
            $vim.put [ "# #{l}"], "l", false, true
          }
        end
        $?.success? or $vim.put [ "### Exit code: #{$?.exitstatus}"], "l", false, true
      end

      def dump_data f, a = nil, m = nil
        (split_new m).tap { |sc| $vim.command sc }
        $vim.set_option filetype: "xxd", buftype: "nofile"
        $vim.get_current_buf.set_name "[hex: #{a}]"
        (Dump.new input: a).run f do |l|
          $vim.put [ l], "l", false, true
        end
      end

      private

      def cur_buf_name
        # $vim.buf_get_name 0           # gives the full path
        $vim.evaluate "bufname('%')"
      end

      def cur_buf_name_exec
        r = cur_buf_name
        r = File.join ".", r unless r.include? "/"
        r
      end

      def popen cmd
        re, we = IO.pipe
        IO.popen cmd, "r+", err: we do |ro|
          we.close
          yield ro, re
        end
      ensure
        re.close
      end

      public

      def pack a, rarg, range
        pack_check a, rarg, range do |d|
          raise "File exists. Overwrite with '!'." if File.exist? d
        end
      end

      def pack! a, rarg, range
        pack_check a, rarg, range do || end
      end

      private

      def pack_check a, rarg, range
        b = $vim.get_current_buf
        a = a.notempty?
        unless a then
          a = b.get_var "origfile" rescue nil
          a or raise "No file name given."
          rarg.zero? or raise "No range allowed when using default output name."
        end
        yield a
        File.open a, "w" do |f|
          r = Neovim::Lines.new b, range
          Nxxd::Dump.reverse r, f
        end
      end

      public

      def feed a, range
        $vim.command "#{range.last}"
        popen a do |ro,re|
          $vim.put [ ""], "l", true, true
          r = Neovim::Lines.new $vim.get_current_buf, range
          Nxxd::Dump.reverse r, ro, consecutive: true
          ro.close_write
          ro.each_line { |l|
            l.chomp!
            $vim.put [ l], "l", false, true
          }
          re.each_line { |l|
            l.chomp!
            $vim.put [ "# #{l}"], "l", false, true
          }
        rescue
          $vim.put [ "# #{$!.class}: #$!"], "l", false, true
        end
        $?.success? or $vim.put [ "### Exit code: #{$?.exitstatus}"], "l", false, true
      end

    end

  end

end

