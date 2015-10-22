
require_dependency "base_materialx/application_controller"

module BaseMaterialx
  class PartsController < ApplicationController
    before_action :require_employee
    before_action :load_parent_record
        
    def index
      @title = t('Base Parts')
      @parts = params[:base_materialx_parts][:model_ar_r]  #returned by check_access_right
      @parts = @parts.where(:category_id => @category_id) if @category_id      
      @parts = @parts.where(:sub_category_id => @sub_category_id) if @sub_category_id 
      @parts = @parts.where(aux_resource: @aux_resource) if @aux_resource     
      @parts = @parts.page(params[:page]).per_page(@max_pagination) 
      @erb_code = find_config_const('part_index_view', 'base_materialx') unless @aux_resource
      @erb_code = find_config_const('part_' + @aux_model + '_index_view', 'base_materialx') if @aux_resource
    end
  
    def new
      @title = t('New Base Part')
      @part = BaseMaterialx::Part.new()
      @part.send("build_#{@aux_resource.sub(/.+\//,'').singularize.to_s}") if @aux_resource
      @erb_code = find_config_const('part_new_view', 'base_materialx') unless @aux_resource
      @erb_code = find_config_const('part_' + @aux_model + '_new_view', 'base_materialx') if @aux_resource
      @aux_erb_code = find_config_const(@aux_model + '_new_view', @aux_engine) if @aux_resource  #cob_info_new_view, cob_orderx
      @js_erb_code = find_config_const('part_new_js_view', 'base_materialx') 
    end
  
    def create
      @part = BaseMaterialx::Part.new(new_params)
      @part.last_updated_by_id = session[:user_id]
      if params[:part][:aux_resource].present?
        aux_model = params[:part][:aux_resource].strip.sub(/.+\//,'').singularize.to_s
        if params[:part][aux_model.to_sym].present?   #fields presented in views
          aux_obj = @part.send("build_#{aux_model}")
          params[:part][aux_model.to_sym].each do |k, v|
            aux_obj[k.to_sym] = v if v.present? && aux_obj.has_attribute?(k.to_sym)
          end
        end
      end
      if @part.save
        unless params[:part][:stay_input] == '1' || params[:part][:stay_input] == 'true'
          redirect_to URI.escape(SUBURI + "/view_handler?index=0&msg=Successfully Saved!")
        else
          redirect_to new_part_url, notice: I18n.t('Successfully Saved!')
        end
      else
        @erb_code = find_config_const('part_new_view', 'base_materialx') if params[:part][:aux_resource].blank? 
        @erb_code = find_config_const('part_' + @aux_model + '_new_view', 'base_materialx') if params[:part][:aux_resource].present? 
        @aux_erb_code = find_config_const(aux_model + '_new_view', @aux_engine) if params[:part][:aux_resource].present?
        @js_erb_code = find_config_const('part_new_js_view', 'base_materialx') #if params[:part][:aux_resource].blank?
        #@js_erb_code = find_config_const('part_' + aux_model + '_new_js_view', 'base_materialx') if params[:part][:aux_resource].present?
        flash[:notice] = t('Data Error. Not Saved!')
        render 'new'
      end
    end
  
    def edit
      @title = t('Update Base Part')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @erb_code = find_config_const('part_edit_view', 'base_materialx') unless @aux_resource
      @erb_code = find_config_const('part_' + @aux_model + '_edit_view', 'base_materialx') if @aux_resource
      @aux_erb_code = find_config_const(@aux_model + '_edit_view', @aux_engine) if @aux_resource
      @js_erb_code = find_config_const('part_edit_js_view', 'base_materialx') 
    end
  
    def update
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @part.last_updated_by_id = session[:user_id]
      if @aux_resource
        aux_model = @aux_resource.sub(/.+\//,'').singularize.to_s
        if params[:part][aux_model.to_sym].present? #aux fields presented in views
          aux_obj = @part.send(aux_model)
          params[:part][aux_model.to_sym].each do |k, v|
            aux_obj[k.to_sym] = v if v.present? && aux_obj.has_attribute?(k.to_sym)
          end
        end
      end
      if @part.update_attributes(edit_params)
        redirect_to URI.escape(SUBURI + "/view_handler?index=0&msg=Successfully Updated!")
      else
        @erb_code = find_config_const('part_edit_view', 'base_materialx') unless @aux_resource
        @erb_code = find_config_const('part_' + @aux_model + '_edit_view', 'base_materialx') if @aux_resource
        @aux_erb_code = find_config_const(@aux_model + '_edit_view', @aux_engine) if @aux_resource
        @js_erb_code = find_config_const('part_edit_js_view', 'base_materialx') 
        flash[:notice] = t('Data Error. Not Updated!')
        render 'edit'
      end
    end
  
    def show
      @title = t('Base Part Info')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @erb_code = find_config_const('part_show_view', 'base_materialx') unless @aux_resource  
      @erb_code = find_config_const('part_' + @aux_model + '_show_view', 'base_materialx') if @aux_resource  
      @aux_erb_code = find_config_const(@aux_model + '_show_view', @aux_engine) if @aux_resource
    end
    
    def autocomplete
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("name like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name} -    #{f.spec}"}    #return string of 2 fields. format []-[][][][]    
    end
    
    def autocomplete_part_num
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("part_num like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name} -    #{f.part_num}"}    #return string of 2 fields. format []-[][][][]    
    end
    
    def autocomplete_name_part_num
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("name like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name} -    #{f.part_num}"}    #return string of 2 fields. format []-[][][][]    
    end
    
    def autocomplete_name
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("name like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name}"}    #return name only    
    end
      
    protected
    def load_parent_record
      @qty_unit = find_config_const('piece_unit').split(',').map(&:strip) if find_config_const('piece_unit').present?
      @qty_unit = Commonx::CommonxHelper.return_misc_definitions('piece_unit') if find_config_const('piece_unit').blank?
      @category_id = params[:category_id] if params[:category_id].present?
      @sub_category_id = params[:sub_category_id] if params[:sub_category_id].present?
      @aux_resource = params[:aux_resource].strip if params[:aux_resource]  #cob_orderx/cob_orders
      @aux_resource = BaseMaterialx::Part.find(params[:id]).aux_resource if params[:id].present? && BaseMaterialx::Part.find(params[:id]).respond_to?(:aux_resource)  
      @aux_engine = @aux_resource.sub(/\/.+/, '') if @aux_resource  #aux_resource='base_materialx/parts'
      @aux_model = @aux_resource.sub(/.+\//,'').singularize.to_s if @aux_resource  #cob_info
    end
    
    private
    
    def new_params
      params.require(:part).permit(:active, :category_id, :desp, :unit, :last_updated_by_id, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state,
                    :part_num, :aux_resource)
    end
    
    def edit_params
      params.require(:part).permit(:active, :category_id, :desp, :unit, :last_updated_by_id, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state,
                    :part_num)
    end
    
    def clean_page
      params[:part][:name] = nil
      params[:part][:part_num] = nil
    end
  end
end
