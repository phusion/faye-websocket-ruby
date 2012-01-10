# WebSocket extensions for Rainbows
# Based on code from the Cramp project
# http://github.com/lifo/cramp

# Copyright (c) 2009-2011 Pratik Naik
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Faye
  class WebSocket
    
    class RainbowsClient < Rainbows::EventMachine::Client
      include Faye::WebSocket::Adapter
      attr_accessor :web_socket
      
      def receive_data(data)
        return super unless @state == :websocket
        web_socket.receive(data) if web_socket
      end
      
      def app_call(*args)
        if args.first == NULL_IO and @hp.content_length == 0 and websocket?
          prepare_request_body
        else
          super
        end
      end
      
      def on_read(data)
        if @state == :body and websocket? and @hp.body_eof?
          @state = :websocket
          @input.rewind
          @env['em.connection'] = self
          app_call StringIO.new(@buf)
        else
          super
        end
      end
      
      def unbind
        super
      ensure
        web_socket.fail if web_socket
      end
      
      def write_headers(*args)
        super unless websocket?
      end
    end
    
  end
end
