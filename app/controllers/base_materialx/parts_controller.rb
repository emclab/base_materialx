require_dependency "base_materialx/application_controller"

module BaseMaterialx
  class PartsController < ApplicationController
    before_filter :require_employee
    before_filter :load_parent_record
        
    def index
      @title = t('Base Parts')
      @parts = params[:base_materialx_parts][:model_ar_r]  #returned by check_access_right
      @parts = @parts.where(:category_id => @category_id) if @category_id      
      @parts = @parts.where(:sub_category_id => @sub_category_id) if @sub_category_id      
      @parts = @parts.page(params[:page]).per_page(@max_pagination) 
      @erb_code = find_config_const('part_index_view', 'base_materialx')
    end
  
    def new
      @title = t('New Base Part')
      @part = BaseMaterialx::Part.new()
      @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
      @erb_code = find_config_const('part_new_view', 'base_materialx')
      @js_erb_code = find_config_const('part_new_js_view', 'base_materialx')
    end
  
    def create
      @part = BaseMaterialx::Part.new(params[:part], :as => :role_new)
      @part.last_updated_by_id = session[:user_id]
      if @part.save
        redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Saved!")
      else
        @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
        @erb_code = find_config_const('part_new_view', 'base_materialx')
        @js_erb_code = find_config_const('part_new_js_view', 'base_materialx')
        flash[:notice] = t('Data Error. Not Saved!')
        render 'new'
      end
    end
  
    def edit
      @title = t('Update Base Part')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
      @erb_code = find_config_const('part_edit_view', 'base_materialx')
      @js_erb_code = find_config_const('part_edit_js_view', 'base_materialx')
      #if @part.wf_state.present? && @part.current_state != :initial_state
       # redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=NO Update. Record Being Processed!")
      #end
    end
  
    def update
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @part.last_updated_by_id = session[:user_id]
      if @part.update_attributes(params[:part], :as => :role_update)
        redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Updated!")
      else
        @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
        @erb_code = find_config_const('part_edit_view', 'base_materialx')
        @js_erb_code = find_config_const('part_edit_js_view', 'base_materialx')
        flash[:notice] = t('Data Error. Not Updated!')
        render 'edit'
      end
    end
  
    def show
      @title = t('Base Part Info')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @erb_code = find_config_const('part_show_view', 'base_materialx')
    end
    
    def autocomplete
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("name like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name} - #{f.spec}"}    #return string of 2 fields    
    end  
    
    protected
    def load_parent_record
      @category_id = params[:category_id] if params[:category_id].present?
      @sub_category_id = params[:sub_category_id] if params[:sub_category_id].present?
    end
  end
end
