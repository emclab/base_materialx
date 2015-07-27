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
      @erb_code = find_config_const('part_index_view', 'base_materialx') #unless @aux_resource
      #@erb_code = find_config_const('part_' + @aux_resource.sub(/.+\//,'').singularize.to_s + '_index_view', 'base_materialx') if @aux_resource
    end
  
    def new
      @title = t('New Base Part')
      @part = BaseMaterialx::Part.new()
      @part.send("build_#{@aux_resource.sub(/.+\//,'').singularize.to_s}") if @aux_resource
      @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
      @erb_code = find_config_const('part_new_view', 'base_materialx') unless @aux_resource
      @erb_code = find_config_const('part_' + @aux_resource.sub(/.+\//,'').singularize.to_s + 'new_view', 'base_materialx') if @aux_resource
      @js_erb_code = find_config_const('part_new_js_view', 'base_materialx') if @aux_resource.blank?
      @js_erb_code = find_config_const('part_' + @aux_resource.sub(/.+\//,'').singularize.to_s + '_new_js_view', 'base_materialx') if @aux_resource.present?
    end
  
    def create
      @part = BaseMaterialx::Part.new(new_params)
      @part.last_updated_by_id = session[:user_id]
      if params[:part][:aux_resource].present?
        aux_model = params[:part][:aux_resource].strip.sub(/.+\//,'').singularize.to_s
        if params[:part][aux_model.to_sym].present?   #fields presented in views
          aux_obj = @part.send("build_#{aux_model}")
          params[:part][aux_model.to_sym].each do |k, v|
            aux_obj[k.to_sym] = v if v.present?
          end
        end
      end
      if @part.save
        redirect_to URI.escape(SUBURI + "/view_handler?index=0&msg=Successfully Saved!")
      else
        @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
        @erb_code = find_config_const('part_new_view', 'base_materialx') if params[:part][:aux_resource].blank?
        @erb_code = find_config_const('part_'+ aux_model + '_new_view', 'base_materialx') if params[:part][:aux_resource].present?
        @js_erb_code = find_config_const('part_new_js_view', 'base_materialx') if params[:part][:aux_resource].blank?
        @js_erb_code = find_config_const('part_' + aux_model + '_new_js_view', 'base_materialx') if params[:part][:aux_resource].present?
        flash[:notice] = t('Data Error. Not Saved!')
        render 'new'
      end
    end
  
    def edit
      @title = t('Update Base Part')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
      @erb_code = find_config_const('part_edit_view', 'base_materialx') unless @aux_resource
      @erb_code = find_config_const('part_' + @aux_resource.sub(/.+\//,'').singularize.to_s + '_edit_view', 'base_materialx') if @aux_resource
      @js_erb_code = find_config_const('part_edit_js_view', 'base_materialx') unless @aux_resource
      @js_erb_code = find_config_const('part_' + @aux_resource.sub(/.+\//,'').singularize.to_s + '_edit_js_view', 'base_materialx') if @aux_resource     
    end
  
    def update
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @part.last_updated_by_id = session[:user_id]
      if @aux_resource
        aux_model = @aux_resource.sub(/.+\//,'').singularize.to_s
        if params[:part][aux_model.to_sym].present? #aux fields presented in views
          aux_obj = @part.send(aux_model)
          params[:part][aux_model.to_sym].each do |k, v|
            aux_obj[k.to_sym] = v if v.present?
          end
        end
      end
      if @part.update_attributes(edit_params)
        redirect_to URI.escape(SUBURI + "/view_handler?index=0&msg=Successfully Updated!")
      else
        @qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
        @erb_code = find_config_const('part_edit_view', 'base_materialx') unless @aux_resource
        @erb_code = find_config_const('part_' + aux_model + '_edit_view', 'base_materialx') if @aux_resource
        @js_erb_code = find_config_const('part_edit_js_view', 'base_materialx') unless @aux_resource
        @js_erb_code = find_config_const('part_' + aux_model + '_edit_js_view', 'base_materialx') if @aux_resource
        flash[:notice] = t('Data Error. Not Updated!')
        render 'edit'
      end
    end
  
    def show
      @title = t('Base Part Info')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @erb_code = find_config_const('part_show_view', 'base_materialx') if @aux_resource.blank?
      @erb_code = find_config_const('part_' + @aux_resource.sub(/.+\//,'').singularize.to_s + '_show_view', 'base_materialx') if @aux_resource.present?
    end
    
    def autocomplete
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("name like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name} -    #{f.spec}"}    #return string of 2 fields. format []-[][][][]    
    end
    
    def autocomplete_part_num
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("name like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name} -    #{f.part_num}"}    #return string of 2 fields. format []-[][][][]    
    end
    
    def autocomplete_name
      @parts = BaseMaterialx::Part.where("active = ?", true).order(:name).where("name like ?", "%#{params[:term]}%")
      render json: @parts.map {|f| "#{f.name}"}    #return name only    
    end
      
    protected
    def load_parent_record
      @category_id = params[:category_id] if params[:category_id].present?
      @sub_category_id = params[:sub_category_id] if params[:sub_category_id].present?
      @aux_resource = params[:aux_resource].strip if params[:aux_resource]  #cob_orderx/cob_orders
      @aux_resource = BaseMaterialx::Part.find(params[:id]).aux_resource if params[:id].present?   
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
  end
end
