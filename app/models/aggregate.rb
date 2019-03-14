class Aggregate < ApplicationRecord
  self.abstract_class = true
  has_many :events

  alias_method :save_from_event!, :save!
  ActiveRecord::Persistence.public_instance_methods.reject do |method|
    method.to_s.ends_with?("?")
  end.each do |method|
    define_method method do
      raise "Aggregate Persistance Error: #{method} can't be called directly on an instance of #{self.class.name}"
    end
  end
end
