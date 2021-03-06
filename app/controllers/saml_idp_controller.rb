# frozen_string_literal: true

class SamlIdpController < SamlIdp::IdpController
  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :authenticate_user!, except: [:show]
  # rubocop:enable Rails/LexicallyScopedActionFilter

  # override create and make sure to set both "GET" and "POST" requests to /saml/auth to #create
  # rubocop:disable Metrics/MethodLength
  def create
    if user_signed_in?
      @saml_response = idp_make_saml_response(current_user)
      render template: 'saml_idp/idp/saml_post', layout: false
      Login.create(
        user: current_user,
        service_provider: SamlServiceProvider.find_by(issuer_or_entity_id: @saml_request.issuer)
      )
      nil
    else
      # it shouldn't be possible to get here, but lets render 403 just in case
      render status: :forbidden
    end
  end
  # rubocop:enable Metrics/MethodLength

  # NOT USED -- def idp_authenticate(email, password) -- NOT USED

  protected

  def authn_context_classref
    # Recommended via https://wiki.cac.washington.edu/display/infra/Configure+a+Service+Provider+for+Two-Factor+Authentication
    return 'https://refeds.org/profile/mfa' if user_signed_in? && current_user.two_factor_enabled?

    super
  end

  private

  # not using params intentionally
  def idp_make_saml_response(found_user)
    encode_response found_user, { signed_message: true }
  end

  def saml_acs_url
    super || ''
  end

  def idp_logout
    sign_out current_user if user_signed_in?
  end
  private :idp_logout
end
