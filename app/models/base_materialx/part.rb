module BaseMaterialx
  class Part < ActiveRecord::Base
    attr_accessor :active_noupdate, :last_updated_by_name, :category_name, :sub_category_name, :field_changed
=begin
    attr_accessible :active, :category_id, :desp, :unit, :last_updated_by_id, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state,
                    :part_num, :field_changed,
                    :as => :role_new
    attr_accessible :active, :category_id, :desp, :unit, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state, :part_num,
                    :last_updated_by_name, :active_noupdate, :category_name, :sub_category_name, :field_changed,
                    :as => :role_update  
    attr_accessor :start_date_s, :end_date_s, :name_s, :spec_s, :part_num_s, :category_id_s, :sub_category_id_s, :active_s, :desp_s, :preferred_mfr_s, 
                  :preferred_supplier_s
    attr_accessible :start_date_s, :end_date_s, :name_s, :spec_s, :part_num_s, :category_id_s, :sub_category_id_s, :active_s, :desp_s, :preferred_mfr_s, :preferred_supplier_s,    
                    :as => :role_search_stats

=end
    belongs_to :category, :class_name => BaseMaterialx.category_class.to_s
    belongs_to :sub_category, :class_name => BaseMaterialx.sub_category_class.to_s
    belongs_to :last_updated_by, :class_name => 'Authentify::User'   
                    
    validates :name, :spec, :unit, :presence => true
    validates :category_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'category_id.present?'  
    validates :sub_category_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'sub_category_id.present?'  
    validates :name, :uniqueness => {:scope => :spec, :case_sensitive => false, :message => I18n.t('Duplicate Name!')} 
    validate :dynamic_validate 
    
    def dynamic_validate
      wf = Authentify::AuthentifyUtility.find_config_const('dynamic_validate', 'base_materialx')
      eval(wf) if wf.present?
    end            
  end
end
