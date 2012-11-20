require 'colorize'

module Restly
  class LogSubscriber < ActiveSupport::LogSubscriber
    def fetch(event)
      log_items = []
      log_items << event.payload[:name].green if event.payload[:name]
      log_items << "(#{event.duration.round(1)} ms) "
      log_items << [event.payload[:method].to_s.upcase.light_white, event.payload[:url]].join(" ")

      info log_items.join
    end

    def cache_miss(event)
      log_items = []
      log_items << event.payload[:name].red if event.payload[:name]
      log_items << "(#{event.duration.round(1)} ms) "
      log_items << [event.payload[:method].to_s.upcase.light_white, event.payload[:url]].join(" ")

      info log_items.join
    end

    def load_collection(event)
      log_items = []
      log_items << "#{event.payload[:model]} Collection Load".blue
      log_items << "(#{event.duration.round(1)} ms) "

      info log_items.join
    end

    def load_instance(event)
      log_items = []
      log_items << "#{event.payload[:model]} Instance Load".blue
      log_items << "(#{event.duration.round(1)} ms) "

      info log_items.join
    end

    def logger
      Rails.logger
    end
  end
end

Restly::LogSubscriber.attach_to :restly