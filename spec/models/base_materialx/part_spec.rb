require 'rails_helper'

module BaseMaterialx
  RSpec.describe Part, type: :model do
    it "should be OK" do
      c = FactoryGirl.build(:base_materialx_part)
      expect(c).to be_valid
    end
    
    it "should reject nil name" do
      c = FactoryGirl.build(:base_materialx_part, :name => nil)
      expect(c).not_to be_valid
    end
    
    it "should reject nil unit" do
      c = FactoryGirl.build(:base_materialx_part, :unit => nil)
      expect(c).not_to be_valid
    end
    
    it "should reject nil spec" do
      c = FactoryGirl.build(:base_materialx_part, :spec => nil)
      expect(c).not_to be_valid
    end
    
    it "should reject 0 category_id" do
      c = FactoryGirl.build(:base_materialx_part, :category_id => 0)
      expect(c).not_to be_valid
    end
    
    it "should reject nil category_id" do
      c = FactoryGirl.build(:base_materialx_part, :category_id => nil)
      expect(c).not_to be_valid
    end
    
    it "should reject 0 sub_category_id" do
      c = FactoryGirl.build(:base_materialx_part, :sub_category_id => 0)
      expect(c).not_to be_valid
    end
    
    it "should take nil sub_category_id" do
      c = FactoryGirl.build(:base_materialx_part, :sub_category_id => nil)
      expect(c).to be_valid
    end
    
    it "should reject dup name for the same spec" do
      c = FactoryGirl.create(:base_materialx_part, :name => "nil", :spec => 'new new spec')
      c1 = FactoryGirl.build(:base_materialx_part, :name => "Nil", :spec => 'new new spec')
      expect(c1).not_to be_valid
    end
    
    it "should allow dup name for different spec" do
      c = FactoryGirl.create(:base_materialx_part, :name => "nil", :spec => 'new new spec')
      c1 = FactoryGirl.build(:base_materialx_part, :name => "Nil", :spec => 'spec')
      expect(c1).to be_valid
    end
    
  end
end
