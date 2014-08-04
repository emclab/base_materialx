module BaseMaterialx
  class Part < ActiveRecord::Base
    attr_accessor :active_noupdate, :last_updated_by_name, :category_name, :sub_category_name
    attr_accessible :active, :category_id, :desp, :unit, :last_updated_by_id, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state,
                    :part_num,
                    :as => :role_new
    attr_accessible :active, :category_id, :desp, :unit, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state, :part_num,
                    :last_updated_by_name, :active_noupdate, :category_name, :sub_category_name,
                    :as => :role_update  
    
    belongs_to :category, :class_name => 'Commonx::MiscDefinition'
    belongs_to :sub_category, :class_name => 'Commonx::MiscDefinition'
    belongs_to :last_updated_by, :class_name => 'Authentify::User' 
    
    attr_accessor :start_date_s, :end_date_s, :name_keyword_s, :spec_keyword_s, :category_keyword_s, :category_id_s, :sub_category_id_s, :active_s
    attr_accessible :start_date_s, :end_date_s, :name_keyword_s, :spec_keyword_s, :category_keyword_s, :category_id_s, :sub_category_id_s, :active_s,     
                    :as => :role_search_stats
                    
    validates :name, :spec, :unit, :presence => true
    validates :category_id, :presence => true, :numericality => {:only_integer => true, :greater_than => 0}  
    validates :name, :uniqueness => {:case_sensitive => false, :message => I18n.t('Duplicate Name!')} 
    validate :dynamic_validate 
    
    def dynamic_validate
      wf = Authentify::AuthentifyUtility.find_config_const('dynamic_validate', 'base_materialx')
      eval(wf) if wf.present?
    end            
  end
end
