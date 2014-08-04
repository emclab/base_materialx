require 'spec_helper'

module BaseMaterialx
  describe PartsController do
    before(:each) do
      controller.should_receive(:require_signin)
      controller.should_receive(:require_employee)
           
    end
    before(:each) do
      @pagination_config = FactoryGirl.create(:engine_config, :engine_name => nil, :engine_version => nil, :argument_name => 'pagination', :argument_value => 30)
      piece = FactoryGirl.create(:engine_config, :engine_name => nil, :engine_version => nil, :argument_name => 'piece_unit', :argument_value => "set, piece")
      z = FactoryGirl.create(:zone, :zone_name => 'hq')
      type = FactoryGirl.create(:group_type, :name => 'employee')
      ug = FactoryGirl.create(:sys_user_group, :user_group_name => 'ceo', :group_type_id => type.id, :zone_id => z.id)
      @role = FactoryGirl.create(:role_definition)
      ur = FactoryGirl.create(:user_role, :role_definition_id => @role.id)
      ul = FactoryGirl.build(:user_level, :sys_user_group_id => ug.id)
      @u = FactoryGirl.create(:user, :user_levels => [ul], :user_roles => [ur])
      
      @cate = FactoryGirl.create(:commonx_misc_definition, 'for_which' => 'base_part_category')
      
    end
    
    render_views
    
    describe "GET 'index'" do
      it "returns parts" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "BaseMaterialx::Part.where(:active => true).order('created_at DESC')")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.create(:base_materialx_part)
        task1 = FactoryGirl.create(:base_materialx_part, :name => 'a new task')
        get 'index', {:use_route => :base_materialx}
        assigns[:parts].should =~ [task, task1]
      end
      
      it "should only return the part for a category_id" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "BaseMaterialx::Part.where(:active => true).order('created_at DESC')")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id)
        task1 = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id + 1, :name => 'a new task')
        get 'index', {:use_route => :base_materialx, :category_id => @cate.id}
        assigns[:parts].should =~ [task]
      end
      
      it "should only return the part for the sub_category_id" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "BaseMaterialx::Part.where(:active => true).order('created_at DESC')")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.create(:base_materialx_part, :sub_category_id => @cate.id + 1)
        task1 = FactoryGirl.create(:base_materialx_part, :sub_category_id => @cate.id, :name => 'a new task')
        get 'index', {:use_route => :base_materialx, :sub_category_id => @cate.id}
        assigns[:parts].should =~ [task1]
      end
            
    end
  
    describe "GET 'new'" do
      it "returns bring up new page" do
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        get 'new', {:use_route => :base_materialx,  :category_id => @cate.id}
        response.should be_success
      end
      
    end
  
    describe "GET 'create'" do
      it "should create and redirect after successful creation" do
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.attributes_for(:base_materialx_part, :category_id => @cate.id )  
        get 'create', {:use_route => :base_materialx, :part => task, :category_id => @cate.id}
        response.should redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Saved!")
      end
      
      it "should render 'new' if data error" do        
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.attributes_for(:base_materialx_part, :category_id => @cate.id, :name => nil)
        get 'create', {:use_route => :base_materialx, :part => task, :category_id => @cate.id}
        response.should render_template('new')
      end
    end
  
    describe "GET 'edit'" do
      it "returns edit page" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id)
        get 'edit', {:use_route => :base_materialx, :id => task.id}
        response.should be_success
      end
      
    end
  
    describe "GET 'update'" do
      it "should return success and redirect" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id)
        get 'update', {:use_route => :base_materialx, :id => task.id, :part => {:name => 'new name'}}
        response.should redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Updated!")
      end
      
      it "should render edit with data error" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.create(:base_materialx_part)
        get 'update', {:use_route => :base_materialx, :id => task.id, :part => {:name => ''}}
        response.should render_template('edit')
      end
    end
  
    describe "GET 'show'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'show', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "record.last_updated_by_id == session[:user_id]")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id, :last_updated_by_id => @u.id)
        get 'show', {:use_route => :base_materialx, :id => task.id}
        response.should be_success
      end
    end
  end
end
