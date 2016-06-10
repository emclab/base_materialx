require 'rails_helper'

RSpec.describe "LinkTests", type: :request do
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
         'mini-link'    => mini_btn +  'btn btn-link',
         'right-span#'         => '2', 
                 'left-span#'         => '6', 
                 'offset#'         => '2',
                 'form-span#'         => '4'
        }
    before(:each) do
      config_entry = FactoryGirl.create(:engine_config, :engine_name => 'rails_app', :engine_version => nil, :argument_name => 'SESSION_TIMEOUT_MINUTES', :argument_value => 30)
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
      user_access = FactoryGirl.create(:user_access, :action => 'update', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'show', :resource =>'base_materialx_parts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "record.last_updated_by_id == session[:user_id]")
      user_access = FactoryGirl.create(:user_access, :action => 'create_base_part_category', :resource => 'commonx_misc_definitions', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'create_base_part', :resource => 'commonx_logs', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      
      piece = FactoryGirl.create(:commonx_misc_definition, :name => 'piece', :for_which => 'piece_unit')       
      @cate = FactoryGirl.create(:commonx_misc_definition, 'for_which' => 'base_part_category')
      
      visit authentify.new_session_path
      #save_and_open_page
      fill_in "login", :with => @u.login
      fill_in "password", :with => @u.password
      click_button 'Login'
    end
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      task = FactoryGirl.create(:base_materialx_part, active: true, :category_id => @cate.id, unit: 'piece', :last_updated_by_id => @u.id)
      visit base_materialx.parts_path
      #save_and_open_page
      expect(page).to have_content('Base Parts')
      expect(Authentify::SysLog.all.count).to eq(1)
      expect(Authentify::SysLog.all.first.resource).to eq('base_materialx/parts')
      expect(Authentify::SysLog.all.first.user_id).to eq(@u.id)
      click_link 'Edit'
      expect(page).to have_content('Update Base Part')
      #save_and_open_page
      fill_in 'part_name', :with => 'a test Base Part'
      click_button 'Save'
      visit base_materialx.parts_path
      #save_and_open_page
      expect(page).to have_content('a test Base Part')
      #with wrong data
      visit base_materialx.parts_path
      expect(page).to have_content('Base Parts')
      click_link 'Edit'
      fill_in 'part_name', :with => ''
      fill_in 'part_spec', :with => 'this will never show'
      click_button 'Save'
      save_and_open_page
      visit base_materialx.parts_path
      expect(page).not_to have_content('this will never show')
            
      visit base_materialx.parts_path
      click_link task.id.to_s
      #save_and_open_page
      expect(page).to have_content('Base Part Info')
      click_link 'New Log'
      #save_and_open_page
      expect(page).to have_content('Log')
      
      visit base_materialx.parts_path
      #save_and_open_page
      click_link 'New Base Part'
      save_and_open_page
      expect(page).to have_content('New Base Part')
      fill_in 'part_name', :with => 'a test Base Part new'
      fill_in 'part_spec', :with => 'a test spec'
      select('piece', :from => 'part_unit')
      #select('MyString', :from => 'part_category_id')
      click_button 'Save'
      visit base_materialx.parts_path
      expect(page).to have_content('a test Base Part new')
      #with wrong data
      visit base_materialx.parts_path
      #save_and_open_page
      click_link 'New Base Part'
      fill_in 'part_name', :with => ''
      fill_in 'part_spec', :with => 'a test spec will never show up'
      select('piece', :from => 'part_unit')
      #select('MyString', :from => 'part_category_id')
      click_button 'Save'
      #save_and_open_page
      visit base_materialx.parts_path
      expect(page).not_to have_content('a test spec will never show up')
           
    end
  end
end
