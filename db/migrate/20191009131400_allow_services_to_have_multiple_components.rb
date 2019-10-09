class AllowServicesToHaveMultipleComponents < ActiveRecord::Migration[6.0]
  def up
    create_table :msa_components_services, id: false do |t|
      t.belongs_to :msa_component, type: :uuid
      t.belongs_to :service, type: :uuid
    end

    create_table :sp_components_services, id: false do |t|
      t.belongs_to :service, type: :uuid
      t.belongs_to :sp_component, type: :uuid
    end

    Service.all.each do |s|
      if s.msa_component
        MsaComponentService.create(msa_component_id: s.msa_component.id, service_id: s.id)
      elsif s.sp_component
        SpComponentService.create(sp_component_id: s.sp_component.id, service_id: s.id)
      else
        raise "Encountered service with no MsaComponent or SpComponent during migration 20191009131400: #{s.name}"
      end
    end

    remove_column :services, :sp_component_id
    remove_column :services, :msa_component_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Migration 20191009131400 is not revertable"
  end
end
