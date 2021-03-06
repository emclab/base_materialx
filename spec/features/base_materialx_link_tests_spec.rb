require 'spec_helper'

describe "LinkTests" do
  describe "GET /base_materialx_link_tests" do
    mini_btn = 'btn btn-mini '
    ActionView::CompiledTemplates::BUTTONS_CLS =
        {'default' => 'btn',
         'mini-default' => mini_btn + 'btn',
         'action'       => 'btn btn-primary',
         'mini-action'  => mini_btn + 'btn btn-primary',
         'info'         => 'btn btn-info',
         'mini-info'    => mini_btn + 'btn btn-info',
         'success'      => 'btn btn-success',
         'mini-success' => mini_btn + 'btn btn-success',
         'warning'      => 'btn btn-warning',
         'mini-warning' => mini_btn + 'btn btn-warning',
         'danger'       => 'btn btn-danger',
         'mini-danger'  => mini_btn + 'btn btn-danger',
         'inverse'      => 'btn btn-inverse',
         'mini-inverse' => mini_btn + 'btn btn-inverse',
         'link'         => 'btn btn-link',
         'mini-link'    => mini_btn +  'btn btn-link'
        }
    before(:each) do
      @pagination_config = FactoryGirl.create(:engine_config, :engine_name => nil, :engine_version => nil, :argument_name => 'pagination', :argument_value => 30)
      piece_unit = FactoryGirl.create(:engine_config, :engine_name => nil, :engine_version => nil, :argument_name => 'piece_unit', :argument_value => "set, piece")
      z = FactoryGirl.create(:zone, :zone_name => 'hq')
      type = FactoryGirl.create(:group_type, :name => 'employee')
      ug = FactoryGirl.create(:sys_user_group, :user_group_name => 'ceo', :group_type_id => type.id, :zone_id => z.id)
      @role = FactoryGirl.create(:role_definition)
      ur = FactoryGirl.create(:user_role, :role_definition_id => @role.id)
      ul = FactoryGirl.build(:user_level, :sys_user_group_id => ug.id)
      @u = FactoryGirl.create(:user, :user_levels => [ul], :user_roles => [ur])
      
      user_access = FactoryGirl.create(:user_access, :action => 'index', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "BaseMaterialx::Part.where(:active => true).order('created_at DESC')")
        
      user_access = FactoryGirl.create(:user_access, :action => 'create', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'create', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'update', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'update', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'show', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "record.last_updated_by_id == session[:user_id]")
      user_access = FactoryGirl.create(:user_access, :action => 'create_base_part_category', :resource => 'commonx_misc_definitions', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'create_base_part', :resource => 'commonx_logs', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
             
      @cate = FactoryGirl.create(:commonx_misc_definition, 'for_which' => 'base_part_category')
      
      visit '/'
      #save_and_open_page
      fill_in "login", :with => @u.login
      fill_in "password", :with => @u.password
      click_button 'Login'
    end
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      task = FactoryGirl.create(:base_materialx_part, active: true, :category_id => @cate.id, unit: 'piece', :last_updated_by_id => @u.id)
      visit parts_path
      #save_and_open_page
      page.should have_content('Base Parts')
      click_link 'Edit'
      page.should have_content('Update Base Part')
      #save_and_open_page
      fill_in 'part_name', :with => 'a test Base Part'
      click_button 'Save'
      visit parts_path
      page.should have_content('a test Base Part')
      #with wrong data
      visit parts_path
      page.should have_content('Base Parts')
      click_link 'Edit'
      fill_in 'part_name', :with => ''
      fill_in 'part_spec', :with => 'this will never show'
      click_button 'Save'
      save_and_open_page
      visit parts_path
      page.should_not have_content('this will never show')
            
      visit parts_path
      click_link task.id.to_s
      #save_and_open_page
      page.should have_content('Base Part Info')
      click_link 'New Log'
      #save_and_open_page
      page.should have_content('Log')
      
      visit parts_path
      #save_and_open_page
      click_link 'New Base Part'
      save_and_open_page
      page.should have_content('New Base Part')
      fill_in 'part_name', :with => 'a test Base Part new'
      fill_in 'part_spec', :with => 'a test spec'
      select('piece', :from => 'part_unit')
      select('MyString', :from => 'part_category_id')
      click_button 'Save'
      visit parts_path
      page.should have_content('a test Base Part new')
      #with wrong data
      visit parts_path
      #save_and_open_page
      click_link 'New Base Part'
      fill_in 'part_name', :with => ''
      fill_in 'part_spec', :with => 'a test spec will never show up'
      select('piece', :from => 'part_unit')
      select('MyString', :from => 'part_category_id')
      click_button 'Save'
      #save_and_open_page
      visit parts_path
      page.should_not have_content('a test spec will never show up')
           
    end
  end
end
