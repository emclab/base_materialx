
require_dependency "base_materialx/application_controller"

module BaseMaterialx
  class PartsController < ApplicationController
    before_action :require_employee
    before_action :load_parent_record
    after_action :info_logger, :except => [:new, :edit, :event_action_result, :wf_edit_result, :search_results, :stats_results, :acct_summary_result]
    
    helper_method :return_misc_definitions 
        
    def index
      @title = t('Base Parts')
      @parts = params[:base_materialx_parts][:model_ar_r]  #returned by check_access_right
      @parts = @parts.where(:category_id => @category_id) if @category_id  
      @parts = @parts.where(:flag => @flag) if @flag   
      @parts = @parts.where(:customer_id => @customer.id) if @customer                 
      @parts = @parts.where(:sub_category_id => @sub_category_id) if @sub_category_id 
      @parts = @parts.where(aux_resource: @aux_resource) if @aux_resource     
      @parts = @parts.page(params[:page]).per_page(@max_pagination) 
      @erb_code = find_config_const(view_name_string('index',  @aux_resource, @flag), session[:fort_token], 'base_materialx') 
    end
  
    def new
      @title = t('New Base Part')
      @part = BaseMaterialx::Part.new()
      @part.send("build_#{@aux_resource.sub(/.+\//,'').singularize.to_s}") if @aux_resource
      @erb_code = find_config_const(view_name_string('new',  @aux_resource, @flag), session[:fort_token], 'base_materialx') 
      @aux_erb_code = find_config_const(@aux_model + '_new_view', session[:fort_token], @aux_engine) if @aux_resource  #cob_info_new_view, cob_orderx
      @js_erb_code = find_config_const('part_new_js_view', session[:fort_token], 'base_materialx') 
    end
  
    def create
      @part = BaseMaterialx::Part.new(new_params)
      @part.fort_token = session[:fort_token]
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
        @erb_code = find_config_const(view_name_string('new',  params[:part][:aux_resource], params[:part][:flag]), session[:fort_token], 'base_materialx') 
        @aux_erb_code = find_config_const(aux_model + '_new_view', session[:fort_token], @aux_engine) if params[:part][:aux_resource].present?
        @js_erb_code = find_config_const('part_new_js_view', session[:fort_token], 'base_materialx') #if params[:part][:aux_resource].blank?
        flash[:notice] = t('Data Error. Not Saved!')
        render 'new'
      end
    end
  
    def edit
      @title = t('Update Base Part')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @erb_code = find_config_const(view_name_string('new',  @part.aux_resource, @part.flag), session[:fort_token], 'base_materialx') 
      @aux_erb_code = find_config_const(@aux_model + '_edit_view', session[:fort_token], @aux_engine) if @aux_resource
      @js_erb_code = find_config_const('part_edit_js_view', session[:fort_token], 'base_materialx') 
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
        @erb_code = find_config_const(view_name_string('new',  @aux_resource, @part.flag), session[:fort_token], 'base_materialx') 
        @aux_erb_code = find_config_const(@aux_model + '_edit_view', session[:fort_token], @aux_engine) if @aux_resource
        @js_erb_code = find_config_const('part_edit_js_view', session[:fort_token], 'base_materialx') 
        flash[:notice] = t('Data Error. Not Updated!')
        render 'edit'
      end
    end
  
    def show
      @title = t('Base Part Info')
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      @erb_code = find_config_const(view_name_string('new',  @aux_resource, @part.flag), session[:fort_token], 'base_materialx') 
      @aux_erb_code = find_config_const(@aux_model + '_show_view', session[:fort_token], @aux_engine) if @aux_resource
    end
    
    def destroy
      @part = BaseMaterialx::Part.find_by_id(params[:id])
      BaseMaterialx::Part.delete(params[:id].to_i)
      redirect_to URI.escape(SUBURI + "/view_handler?index=0&msg=Successfully Deleted!")
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
      qty_str = find_config_const('piece_unit', session[:fort_token])
      @qty_unit = qty_str.split(',').map(&:strip) if qty_str.present?
      @qty_unit = return_misc_definitions('piece_unit') if qty_str.blank?
      @flag = params[:flag].strip if params[:flag].present?
      @flag = params[:part][:flag].strip if params[:part].present? && params[:part][:flag].present?
      @customer = BaseMaterialx.customer_class.find_by_id(params[:customer_id].to_i) if params[:customer_id].present?
      @category_id = params[:category_id] if params[:category_id].present?
      @sub_category_id = params[:sub_category_id] if params[:sub_category_id].present?
      @aux_resource = params[:aux_resource].strip if params[:aux_resource]  #cob_orderx/cob_orders
      @aux_resource = BaseMaterialx::Part.find(params[:id]).aux_resource if params[:id].present? && BaseMaterialx::Part.find(params[:id]).respond_to?(:aux_resource)  
      @aux_engine = @aux_resource.sub(/\/.+/, '') if @aux_resource  #aux_resource='base_materialx/parts'
      @aux_model = @aux_resource.sub(/.+\//,'').singularize.to_s if @aux_resource  #cob_info
    end
    
    def view_name_string(action, aux_resource, flag)  #action: index
      aux_model = aux_resource.sub(/.+\//,'').singularize.to_s if aux_resource
      case action
      when 'index'
        str = 'part_index_view' if aux_resource.blank?
        str = 'part_' + aux_model + '_index_view' if aux_resource.present?
        str = str + '_' + flag if flag.present?
      when 'new'
        str = 'part_new_view' if aux_resource.blank?
        str = 'part_' + aux_model + '_new_view' if aux_resource.present?
        str = str + '_' + flag if flag.present?
      when 'edit'
        str = 'part_edit_view' if aux_resource.blank?
        str = 'part_' + aux_model + '_edit_view' if aux_resource.present?
        str = str + '_' + flag if flag.present?
      when 'show'
        str = 'part_show_view' if aux_resource.blank?
        str = 'part_' + aux_model + '_show_view' if aux_resource.present?
        str = str + '_' + flag if flag.present?
      end
       return str
    end
    
    private
    
    def new_params
      params.require(:part).permit(:active, :category_id, :desp, :unit, :last_updated_by_id, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state,
                    :part_num, :aux_resource, :i_unit_id, :min_stock_qty, :flag, :note, :document_related, :customer_id)
    end
    
    def edit_params
      params.require(:part).permit(:active, :category_id, :desp, :unit, :last_updated_by_id, :name, :preferred_mfr, :preferred_supplier, :spec, :sub_category_id, :wf_state,
                    :part_num, :i_unit_id, :min_stock_qty, :note, :document_related, :customer_id)
    end
    
    def clean_page
      params[:part][:name] = nil
      params[:part][:part_num] = nil
    end
  end
end
