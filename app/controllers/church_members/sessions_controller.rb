class ChurchMembers::SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    items_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
