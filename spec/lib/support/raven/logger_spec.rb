require 'spec_helper'
require 'logger'
require 'support/raven/logger'
require 'raven'

describe Support::Raven::Logger do
  let(:logger) { Support::Raven::Logger.new }

  context "#error" do
    it 'will send exceptions to sentry' do
      error = StandardError.new
      expect(Raven).to receive(:capture_exception).with(error)
      logger.error(error)
    end

    it 'will send non-exceptions to sentry after inspection' do
      msg = double(:message)
      inspected = double(:inspected)
      expect(msg).to receive(:inspect).and_return inspected
      expect(Raven).to receive(:capture_exception).with(inspected)
      logger.error(msg)
    end

    it 'will send string to sentry as string' do
      msg = "foobar"
      expect(Raven).to receive(:capture_exception).with(msg)
      logger.error(msg)
    end
  end

  context "not #error" do
    it 'will not send non-error level exceptions to sentry' do
      raven = double(:raven)
      stub_const("Raven", raven)
      error = StandardError.new
      expect(raven).to_not receive(:capture_exception)
      logger.warn(error)
    end
  end
end
