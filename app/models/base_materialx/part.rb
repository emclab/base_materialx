module BaseMaterialx
  class Part < ActiveRecord::Base
    default_scope {where(fort_token: Thread.current[:fort_token])}
  
    attr_accessor :active_noupdate, :last_updated_by_name, :category_name, :sub_category_name, :field_changed, :stay_input, :customer_name

    model_name = Authentify::AuthentifyUtility.find_config_const('aux_resource', Thread.current[:fort_token], 'base_materialx')  #cob_orderx/orders
    model_name.split(',').each do |a|
      has_one a.sub(/.+\//,'').singularize.to_sym, class_name: a.camelize.singularize.to_s, dependent: :destroy, autosave: true, validate: true
      validates_associated a.sub(/.+\//,'').singularize.to_sym
    end if model_name.present?
    belongs_to :category, :class_name => BaseMaterialx.category_class.to_s
    belongs_to :sub_category, :class_name => BaseMaterialx.sub_category_class.to_s
    belongs_to :last_updated_by, :class_name => 'Authentify::User' 
    belongs_to :i_unit, :class_name => 'Commonx::MiscDefinition'
    belongs_to :customer, :class_name => BaseMaterialx.customer_class.to_s
      
                    
    validates :name, :spec, :fort_token, :presence => true
    validates :name, :uniqueness => {:scope => [:fort_token, :spec], :case_sensitive => false, :message => I18n.t('Duplicate Name!')}
    validates :category_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'category_id.present?'  
    validates :sub_category_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'sub_category_id.present?'  
    validates :i_unit_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'i_unit_id.present?'  
    validates :customer_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'customer_id.present?'  
    validates :min_stock_qty, :numericality => {:greater_than_or_equal_to => 0}, :if => 'min_stock_qty.present?'  
    validates :part_num, :uniqueness => {:scope => [:fort_token, :spec], :case_sensitive => false, :message => I18n.t('Duplicate Part#!')}, :if => 'part_num.present?'
    validate :dynamic_validate 
    
    def dynamic_validate
      wf = Authentify::AuthentifyUtility.find_config_const('dynamic_validate', self.fort_token, 'base_materialx')
      eval(wf) if wf.present?
    end            
  end
end
