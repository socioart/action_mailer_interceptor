RSpec.describe ActionMailerInterceptor do
  before do
    ActionMailer::Base.delivery_method = :test
  end

  let(:mailer) {
    Class.new(ActionMailer::Base) do
      default from: "from@example.com"

      def test(subject: "Test", to: "to@example.com")
        mail(
          to: to,
          subject: subject,
          body: "Body",
          cc: "cc@example.com",
          bcc: "bcc@example.com",
        )
      end
    end
  }

  it "has a version number" do
    expect(ActionMailerInterceptor::VERSION).not_to be nil
  end

  context "ActionMailer::Base.interceptor is nil" do
    before do
      expect(ActionMailer::Base.interceptor).to be_nil
    end

    it "delivers original recipient" do
      mailer.test.deliver_now
      expect(mailer.deliveries.last.to).to eq ["to@example.com"]
      expect(mailer.deliveries.last.cc).to eq ["cc@example.com"]
      expect(mailer.deliveries.last.bcc).to eq ["bcc@example.com"]
    end

    it "delivers with original subject" do
      mailer.test.deliver_now
      expect(mailer.deliveries.last.subject).to eq "Test"
    end
  end

  context "ActionMailer::Base.interceptor is not nil" do
    before do
      ActionMailer::Base.interceptor = "interceptor@example.com"
    end

    it "delivers only to interceptor" do
      mailer.test.deliver_now
      expect(mailer.deliveries.last.to).to eq ["interceptor@example.com"]
      expect(mailer.deliveries.last.cc).to eq nil
      expect(mailer.deliveries.last.bcc).to eq nil
    end

    it "delivers with subject includes original recipient information" do
      mailer.test.deliver_now
      expect(mailer.deliveries.last.subject).to eq "Test [Originally sent To: to@example.com; Cc: cc@example.com; Bcc: bcc@example.com]"
    end
  end
end
