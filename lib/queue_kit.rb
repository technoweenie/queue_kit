module QueueKit
  VERSION = "0.0.1"
end

%w(worker).each do |lib|
  require File.expand_path("../queue_kit/#{lib}", __FILE__)
end

