RSpec.shared_examples 'cannot be persisted outside of an event' do |klass|
  it "can't be created directly" do
    expect {
      klass.create
    }.to raise_error "Aggregate Persistance Error: save can't be called directly on an instance of #{klass.name}"
  end

  it "be create!(ed) directly" do
    expect {
      klass.create!
    }.to raise_error "Aggregate Persistance Error: save! can't be called directly on an instance of #{klass.name}"
  end

  [:save, :save!, :update, :update!].each do |method|
    it "objects can't use #{method} directly" do
      expect {
        klass.new.public_send(method)
      }.to raise_error "Aggregate Persistance Error: #{method} can't be called directly on an instance of #{klass.name}"
    end
  end
end
