# frozen_string_literal: true

class BasicAuthController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def create
    # We need to compare against the last request time here ourselves because
    # warden handles user timeout in a subtly different way to not logged in,
    # namely, not logged in causes the `user_signed_in` method to return
    # fakse, but timed out causes ut ti redirect to the login page.
    last_session_activity = session.try(:[], 'warden.user.user.session').try(:[], 'last_request_at')
    head 401 and return if \
      last_session_activity.present? && \
      Time.at(last_session_activity).utc < Time.current - User.timeout_in.seconds

    if user_signed_in?
      permission_checks = [params[:permission_name], "#{params[:permission_name]}.#{params[:format]}"]
      groups = current_user.asserted_groups
      effective_permissions = groups
                              .map(&:effective_permissions)
                              .flatten
                              .uniq
                              .detect { |f| permission_checks.include? f.name }
      if effective_permissions
        head :ok
      else
        head 403
      end
    else
      head 401
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
