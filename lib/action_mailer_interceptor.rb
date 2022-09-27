require "action_mailer_interceptor/version"
require "action_mailer"

ActionMailer::Base.class_eval do
  class << self
    attr_accessor :interceptor
  end
end

module ActionMailerInterceptor
  class Error < StandardError; end

  def deliver_now
    intercept
    super
  end

  def deliver_now!
    intercept
    super
  end

  private
  def intercept
    return unless interceptor

    self.subject += original_receivers_description
    self.to = interceptor
    self.cc = nil
    self.bcc = nil
  end

  def interceptor
    ActionMailer::Base.interceptor
  end

  def original_receivers_description
    receivers = ""
    receivers << "To: #{to.join(", ")}"
    receivers << "; Cc: #{cc.join(", ")}" if cc
    receivers << "; Bcc: #{bcc.join(", ")}" if bcc
    " [Originally sent #{receivers}]"
  end
end

ActionMailer::MessageDelivery.prepend(ActionMailerInterceptor)
