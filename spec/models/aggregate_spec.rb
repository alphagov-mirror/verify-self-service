require 'rails_helper'

RSpec.describe Aggregate, type: :model do
  it "can't be created directly" do
    expect {
      Certificate.create
    }.to raise_error "Aggregate Persistance Error: save can't be called directly on an instance of Certificate"
  end

  it "be create!(ed) directly" do
    expect {
      Certificate.create!
    }.to raise_error "Aggregate Persistance Error: save! can't be called directly on an instance of Certificate"
  end

  [:save, :save!, :update, :update!].each do |method|
    it "objects can't use #{method} directly" do
      expect {
        Certificate.new.public_send(method)
      }.to raise_error "Aggregate Persistance Error: #{method} can't be called directly on an instance of Certificate"
    end
  end
end
