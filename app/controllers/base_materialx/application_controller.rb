module BaseMaterialx
  class ApplicationController < ::ApplicationController
    include Authentify::SessionsHelper
    include Authentify::AuthentifyUtility
    include Authentify::UsersHelper
    include Authentify::UserPrivilegeHelper
    include Commonx::CommonxHelper
    include Searchx::SearchHelper
    
    before_action :require_signin
    before_action :max_pagination 
    before_action :check_access_right 
    before_action :load_session_variable, :only => [:new, :edit]  #for parent_record_id & parent_resource in check_access_right
    after_action :delete_session_variable, :only => [:create, :update]   #for parent_record_id & parent_resource in check_access_right
    before_action :view_in_config?
    skip_before_action :verify_authenticity_token, unless: :json_request?
    
    protected
    
    def json_request?
      request.format.json?
    end
  
    def max_pagination
      @max_pagination = find_config_const('pagination')
    end
    
    def view_in_config?
      @view_in_config = Authentify::AuthentifyUtility.load_view_in_config
    end
  end
end
