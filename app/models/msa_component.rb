class MsaComponent < Component
  has_many :certificates, as: :component
  has_and_belongs_to_many :services, join_table: "msa_components_services"

private

  def additional_metadata
    { entity_id: entity_id }
  end
end
