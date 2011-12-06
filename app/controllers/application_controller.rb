class ApplicationController < ActionController::Base
  helper ApplicationHelper

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_api_version_header
  before_filter :set_number_of_columns

  JSON_API_VERSION = 4  # see CHANGELOG-API.txt

  private

  def self.protect_fields_for(record, fields = {})
    if fields[:in]
      before_filter(:only => fields[:in]) do |c|
        c.params[record] ||= {}
        fields_to_delete = []
        fields_to_delete += fields[:always] if fields[:always]
        fields_to_delete += fields[:admin] if fields[:admin] && !c.current_user.is_admin?
        fields_to_delete.each { |f| c.params[record].delete(f) }
      end
    end
  end

  def ensure_admin
    unless current_user.is_admin?
      forbidden and return
    end
  end

  def ensure_not_client_user
    forbidden and return if current_user.is_client_user?
  end
  
  def ensure_user_that_can_manage_financial_data
    unless current_user.can_manage_financial_data?
      forbidden and return
    end
  end
  
  def ensure_not_client_user
    if current_user.is_client_user?
      forbidden and return
    end
  end
  
  def render_success(content = "", status = 200)
    render :text => content, :layout => false, :status => status 
  end
  
  def render_failure(content = "", status = 400)
    render :text => content, :layout => false, :status => status
  end
  
  def number_of_columns
    2
  end

  def client_api_version
    request.env["HTTP_X_API_VERSION"].to_i
  end

  def set_api_version_header
    if request.env["HTTP_X_API_VERSION"]
      headers["X-API-Version"] = JSON_API_VERSION.to_s
    end
  end

  def set_number_of_columns
    if params[:controller] =~ /devise/
      @number_of_columns = 1
    else
      @number_of_columns = number_of_columns
    end
  end

  def send_api_version_error
    render_failure("", 412) # :precondition_failed
  end

  def load_column_properties
    @custom_properties = ActivityCustomProperty.all
    @column_properties = @custom_properties.select(&:show_as_column_in_tables)
    @non_column_properties = @custom_properties.reject(&:show_as_column_in_tables)
  end

  def not_found
    respond_to do |format|
      format.html { render "exceptions/not_found", :status => :not_found }
      format.json { render :json => "", :status => :not_found }
    end
  end

  def forbidden
    head :forbidden
  end

  def bad_request
    head :bad_request
  end
end