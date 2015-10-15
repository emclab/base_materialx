require 'rails_helper'

module BaseMaterialx
  RSpec.describe PartsController, type: :controller do
    routes {BaseMaterialx::Engine.routes}
    before(:each) do
      expect(controller).to receive(:require_signin)
      expect(controller).to receive(:require_employee)
           
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
      
      session[:user_role_ids] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id).user_role_ids
    end
    
    render_views
    
    describe "GET 'index'" do
      it "returns parts" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "BaseMaterialx::Part.where(:active => true).order('created_at DESC')")
        session[:user_id] = @u.id
        task = FactoryGirl.create(:base_materialx_part, :active => true)
        task1 = FactoryGirl.create(:base_materialx_part, :name => 'a new task', active: true, :part_num => nil)
        get 'index'
        expect(assigns(:parts)).to match_array([task1, task])
      end
      
      it "should only return the part for a category_id" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "BaseMaterialx::Part.where(:active => true).order('created_at DESC')")
        session[:user_id] = @u.id
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id, :part_num => nil)
        task1 = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id + 1, :name => 'a new task')
        get 'index', {:category_id => @cate.id}
        expect(assigns(:parts)).to  match_array([task])
      end
      
      it "should only return the part for the sub_category_id" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "BaseMaterialx::Part.where(:active => true).order('created_at DESC')")
        session[:user_id] = @u.id
        task = FactoryGirl.create(:base_materialx_part, :sub_category_id => @cate.id + 1, :part_num => nil)
        task1 = FactoryGirl.create(:base_materialx_part, :sub_category_id => @cate.id, :name => 'a new task')
        get 'index', {:sub_category_id => @cate.id}
        expect(assigns(:parts)).to match_array([task1])
      end
            
    end
  
    describe "GET 'new'" do
      it "returns bring up new page" do
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        get 'new', { :category_id => @cate.id}
        expect(response).to be_success
      end
      
    end
  
    describe "GET 'create'" do
      it "should create and redirect after successful creation" do
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        task = FactoryGirl.attributes_for(:base_materialx_part, :category_id => @cate.id )  
        get 'create', {:part => task, :category_id => @cate.id}
        expect(response).to redirect_to URI.escape(SUBURI + "/view_handler?index=0&msg=Successfully Saved!")
      end
      
      it "should render 'new' if stay input" do        
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        task = FactoryGirl.attributes_for(:base_materialx_part, :category_id => @cate.id, :stay_input => 'true' )  
        get 'create', {:part => task, :category_id => @cate.id}
        expect(response).to redirect_to new_part_url
      end
      
      it "should render 'new' if data error" do        
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        task = FactoryGirl.attributes_for(:base_materialx_part, :category_id => @cate.id, :name => nil)
        get 'create', {:part => task, :category_id => @cate.id}
        expect(response).to render_template('new')
      end
    end
  
    describe "GET 'edit'" do
      it "returns edit page" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id)
        get 'edit', {:id => task.id}
        expect(response).to be_success
      end
      
    end
  
    describe "GET 'update'" do
      it "should return success and redirect" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id)
        get 'update', {:id => task.id, :part => {:name => 'new name'}}
        expect(response).to redirect_to URI.escape(SUBURI + "/view_handler?index=0&msg=Successfully Updated!")
      end
      
      it "should render edit with data error" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        task = FactoryGirl.create(:base_materialx_part)
        get 'update', {:id => task.id, :part => {:name => ''}}
        expect(response).to render_template('edit')
      end
    end
  
    describe "GET 'show'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'show', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "record.last_updated_by_id == session[:user_id]")
        session[:user_id] = @u.id
        task = FactoryGirl.create(:base_materialx_part, :category_id => @cate.id, :last_updated_by_id => @u.id)
        get 'show', {:id => task.id}
        expect(response).to be_success
      end
    end
    
    describe "GET 'autocomplete_name_part_num'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'autocomplete_name_part_num', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        get 'autocomplete_name_part_num'
        expect(response).to be_success
      end
    end
    
    describe "GET 'autocomplete_name'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'autocomplete_name', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        get 'autocomplete_name'
        expect(response).to be_success
      end
    end
    
    describe "GET 'autocomplete'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'autocomplete', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        get 'autocomplete'
        expect(response).to be_success
      end
    end
    
    describe "GET 'autocomplete_part_num'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'autocomplete_part_num', :resource => 'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        get 'autocomplete_part_num'
        expect(response).to be_success
      end
    end
        
  end
end
