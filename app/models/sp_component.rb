class SpComponent < Component
  has_many :certificates, as: :component
  has_and_belongs_to_many :services, join_table: "sp_components_services"

  def view_component_type(vsp)
    vsp ? COMPONENT_TYPE::VSP_SHORT : COMPONENT_TYPE::SP_SHORT
  end

private

  def additional_metadata
    { id: id }
  end
end
