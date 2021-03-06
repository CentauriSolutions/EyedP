# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :home

  def home
    @template = Liquid::Template.parse(Setting.home_template)
  end

  def template_variables # rubocop:disable Metrics/MethodLength
    if current_user
      {
        'user' => {
          'username' => current_user.username,
          'email' => current_user.email
        },
        'groups' => current_user.groups.pluck(:name)
      }
    else
      {}
    end
  end
  helper_method :template_variables
end
