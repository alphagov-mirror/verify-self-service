class Service < Aggregate
  has_and_belongs_to_many :msa_components, join_table: "msa_components_services"
  has_and_belongs_to_many :sp_components, join_table: "sp_components_services"
  validates_uniqueness_of :entity_id
end
