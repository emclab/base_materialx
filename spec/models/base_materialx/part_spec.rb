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
    
    it "should reject dup name for spec" do
      c = FactoryGirl.create(:base_materialx_part, :name => "nil", :spec => 'new new spec')
      c1 = FactoryGirl.build(:base_materialx_part, :name => "Nil")
      c1.should_not be_valid
    end
    
  end
end
