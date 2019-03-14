require 'rails_helper'

RSpec.describe Event, type: :model do
  # See spec/models/shared_examples/event.rb for tests of implementing classes

  it 'is the default superclass for all actions and Aggregate is the same for aggregates' do
    records_that_wont_be_event_sourced = []
    (ApplicationRecord.descendants - records_that_wont_be_event_sourced).each do |klass|
      expect(klass.ancestors).to include(Event).or include(Aggregate) 
    end
  end
end
