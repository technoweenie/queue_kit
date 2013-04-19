module QueueKit
  module Clients
    module RoundRobinShuffler
      include QueueKit::Instrumentable

      def self.included(klass)
        super(klass)
        klass.class_eval do
          def command_clients_size
            @clients.size
          end
        end
      end

      def client_command_with_retries(retries = 10)
        attempts = 0

        while attempts < retries
          if data = (yield client, attempts)
            return data
          end

          rotate_client
          attempts += 1
        end

        nil
      end

      def client
        @client_command_count += 1

        if @client_command_count > commands_per_client
          rotate_client
        end

        @current_client
      end

      def round_robin_from(options)
        @commands_per_client = options[:commands_per_client]
      end

      def rotate_client
        instrument "queue.rotate_client"
        @client_index ||= -1
        @client_len ||= clients.size

        @client_command_count = 0
        @client_index += 1

        if @client_index >= @client_len
          @client_index = 0
        end

        @current_client = clients[@client_index]
      end

      def commands_per_client
        @commands_per_client ||= 100
      end

      def clients
        []
      end
    end
  end
end

