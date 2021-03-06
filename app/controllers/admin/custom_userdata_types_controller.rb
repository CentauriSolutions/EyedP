# frozen_string_literal: true

class Admin::CustomUserdataTypesController < AdminController
  private

  def model
    CustomUserdataType
  end

  def model_params
    params.require(:custom_userdata_type).permit(
      :name, :custom_type, :user_read_only
    )
  end

  def whitelist_attributes
    %w[name custom_type user_read_only]
  end
end
