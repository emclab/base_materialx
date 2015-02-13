require 'spec_helper'

module BaseMaterialx
  describe Part do
    it "should be OK" do
      c = FactoryGirl.build(:base_materialx_part)
      c.should be_valid
    end
    
    it "should reject nil name" do
      c = FactoryGirl.build(:base_materialx_part, :name => nil)
      c.should_not be_valid
    end
    
    it "should reject nil unit" do
      c = FactoryGirl.build(:base_materialx_part, :unit => nil)
      c.should_not be_valid
    end
    
    it "should reject nil spec" do
      c = FactoryGirl.build(:base_materialx_part, :spec => nil)
      c.should_not be_valid
    end
    
    it "should reject 0 category_id" do
      c = FactoryGirl.build(:base_materialx_part, :category_id => 0)
      c.should_not be_valid
    end
    
    it "should reject nil category_id" do
      c = FactoryGirl.build(:base_materialx_part, :category_id => nil)
      c.should_not be_valid
    end
    
    it "should reject 0 sub_category_id" do
      c = FactoryGirl.build(:base_materialx_part, :sub_category_id => 0)
      c.should_not be_valid
    end
    
    it "should take nil sub_category_id" do
      c = FactoryGirl.build(:base_materialx_part, :sub_category_id => nil)
      c.should be_valid
    end
    
    it "should reject dup name for the same spec" do
      c = FactoryGirl.create(:base_materialx_part, :name => "nil", :spec => 'new new spec')
      c1 = FactoryGirl.build(:base_materialx_part, :name => "Nil", :spec => 'new new spec')
      c1.should_not be_valid
    end
    
    it "should allow dup name for different spec" do
      c = FactoryGirl.create(:base_materialx_part, :name => "nil", :spec => 'new new spec')
      c1 = FactoryGirl.build(:base_materialx_part, :name => "Nil", :spec => 'spec')
      c1.should be_valid
    end
    
  end
end
