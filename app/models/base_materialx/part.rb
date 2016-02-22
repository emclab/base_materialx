module BaseMaterialx
  class Part < ActiveRecord::Base
    attr_accessor :active_noupdate, :last_updated_by_name, :category_name, :sub_category_name, :field_changed, :stay_input

    model_name = Authentify::AuthentifyUtility.find_config_const('aux_resource', 'base_materialx')  #cob_orderx/orders
    model_name.split(',').each do |a|
      has_one a.sub(/.+\//,'').singularize.to_sym, class_name: a.camelize.singularize.to_s, dependent: :destroy, autosave: true, validate: true
      validates_associated a.sub(/.+\//,'').singularize.to_sym
    end if model_name.present?
    belongs_to :category, :class_name => BaseMaterialx.category_class.to_s
    belongs_to :sub_category, :class_name => BaseMaterialx.sub_category_class.to_s
    belongs_to :last_updated_by, :class_name => 'Authentify::User' 
    belongs_to :i_unit, :class_name => 'Commonx::MiscDefinition'
      
                    
    validates :name, :spec, :unit, :presence => true
    validates :category_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'category_id.present?'  
    validates :sub_category_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'sub_category_id.present?'  
    validates :i_unit_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'i_unit_id.present?'  
    validates :name, :uniqueness => {:scope => :spec, :case_sensitive => false, :message => I18n.t('Duplicate Name!')}
    validates :part_num, :uniqueness => {:scope => :spec, :case_sensitive => false, :message => I18n.t('Duplicate Part#!')}, :if => 'part_num.present?'
    validate :dynamic_validate 
    
    def dynamic_validate
      wf = Authentify::AuthentifyUtility.find_config_const('dynamic_validate', 'base_materialx')
      eval(wf) if wf.present?
    end            
  end
end
