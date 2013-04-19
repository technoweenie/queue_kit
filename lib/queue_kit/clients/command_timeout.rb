module QueueKit
  module Clients
    module CommandTimeout
      def command_timeout(attempts = 0)
        timeout = command_timeout_ms
        timeout += timeout * (attempts / command_clients_size).floor

        if timeout > (max = max_command_timeout_ms)
          timeout = max
        end

        timeout
      end

      def command_timeout_from(options)
        @command_timeout_ms = options[:command_timeout_ms]
        @max_command_timeout_ms = options[:max_command_timeout_ms]
      end

      def command_timeout_ms
        @command_timeout_ms ||= 10
      end

      def max_command_timeout_ms
        @max_command_timeout_ms ||= 1000
      end

      def command_clients_size
        1
      end
    end
  end
end

