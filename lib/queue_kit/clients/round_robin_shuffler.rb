module QueueKit
  module Clients
    module RoundRobinShuffler
      def current_client
        @client_command_count += 1

        if @client_command_count > commands_per_client
          rotate_client
        end

        clients[@client_index]
      end

      def rotate_client
        @client_index ||= -1
        @client_len ||= clients.size

        @client_command_count = 0
        @client_index += 1

        if @client_index >= @client_len
          @client_index = 0
        end
      end

      def commands_per_client
        100
      end

      def clients
        []
      end
    end
  end
end

