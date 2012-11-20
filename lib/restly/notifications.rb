require 'colorize'

module Restly
  class LogSubscriber < ActiveSupport::LogSubscriber

    def request(event)
      event.payload[:color] ||= :light_green
      log_items = []
      log_items << event.payload[:name].colorize(event.payload[:color].to_sym)
      log_items << "(#{event.duration.round(1)} ms)"
      log_items << event.payload[:method].to_s.upcase.light_white
      log_items << event.payload[:url].light_white

      info "  " + log_items.join(" ")
    end

    def cache(event)
      event.payload[:color] ||= :green
      log_items = []
      log_items << event.payload[:name].colorize(event.payload[:color].to_sym)
      log_items << "(#{event.duration.round(1)} ms)"
      log_items << event.payload[:key].light_white

      info "  " + log_items.join(" ")
    end

    def load_collection(event)
      log_items = []
      log_items << "#{event.payload[:model]} Collection Load".blue
      log_items << "(#{event.duration.round(1)} ms)"

      info "  " + log_items.join(" ")
    end

    def missing_attribute(event)
      log_items = []
      log_items << "  WARNING: Attribute `#{event.payload[:attr]}` not written.".light_black
      log_items << "  To fix this add the following the the model --  field :#{event.payload[:attr]}".light_black

      warn log_items.join("\n")
    end

    def load_association(event)
      log_items = []
      log_items << "#{event.payload[:model]}##{event.payload[:association]} Association Load".cyan
      log_items << "(#{event.duration.round(1)} ms)"

      info "  " + log_items.join(" ")
    end

    def load_instance(event)
      log_items = []
      log_items << "#{event.payload[:instance].class.name} Instance Load".blue
      log_items << "(#{event.duration.round(1)} ms)"

      info "  " + log_items.join(" ") if event.payload[:instance].response
    end

    def logger
      Rails.logger
    end
  end
end

Restly::LogSubscriber.attach_to :restly