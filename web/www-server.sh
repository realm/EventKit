ruby -rwebrick -e'WEBrick::HTTPServer.new(:Port => 8383, :DocumentRoot => Dir.pwd + "/www").start'