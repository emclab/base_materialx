class CreateBaseMaterialxParts < ActiveRecord::Migration
  def change
    create_table :base_materialx_parts do |t|
      t.string :name
      t.string :spec
      t.string :part_num
      t.string :unit
      t.text :desp
      t.text :preferred_mfr
      t.text :preferred_supplier
      t.integer :category_id
      t.integer :sub_category_id
      t.integer :last_updated_by_id
      t.string :wf_state
      t.boolean :active, :default => true
      t.timestamps
      t.string :aux_resource
    end
    
    add_index :base_materialx_parts, :name
    add_index :base_materialx_parts, :spec
    add_index :base_materialx_parts, :part_num
    add_index :base_materialx_parts, :category_id
    add_index :base_materialx_parts, :sub_category_id
    add_index :base_materialx_parts, :wf_state
    add_index :base_materialx_parts, :active
    add_index :base_materialx_parts, :aux_resource
  end
end
