class AggregatedEvent < Event
  self.abstract_class = true
  before_validation :preset_aggregate
  before_create :apply_and_persist_changes_to_aggregate

  def preset_aggregate
    self.aggregate ||= build_aggregate
  end

  def build_aggregate
    public_send "build_#{aggregate_name}"
  end

  def self.belongs_to_aggregate(aggregate_name)
    @aggregate_name = aggregate_name
    belongs_to :aggregate, polymorphic: true, autosave: false
    define_method :aggregate_name do
      aggregate_name
    end
    alias_attribute aggregate_name, :aggregate
  end

  def apply_and_persist_changes_to_aggregate
    self.aggregate.lock! if self.aggregate.persisted?

    self.aggregate.assign_attributes(attributes_to_apply)

    self.aggregate.save!
    self.aggregate_id = aggregate.id if aggregate_id.nil?
  end

  def attributes_to_apply
    raise NotImplementedError
  end

  def name_is_present
    errors.add(:name, "can't be blank") unless name.present?
  end
end
