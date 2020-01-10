class GithubSyncController < ApplicationController
  before_action :filter_github_issues, :verify_signature

  def create
    GithubSyncJob.perform_later event_params
    head :no_content
  end

  private

  def filter_github_issues
    event_type = request.headers["X-GitHub-Event"]
    return head :forbidden unless event_type

    head :no_content unless event_type == "issues"
  end

  def verify_signature
    provided_signature = request.headers["X-Hub-Signature"]
    return head :forbidden unless provided_signature

    payload_body = request.body.read
    webhook_key = Rails.application.credentials.authors_github[:webhook_key]
    signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), webhook_key, payload_body)
    head :unauthorized unless Rack::Utils.secure_compare(signature, provided_signature)
  end

  def event_params
    # GitHub sends an action in their top-level json, but Rails overwrites it in the routing logic to match the create
    # method in this controller. So both controller and actions are removed, permit! is called (because the signature
    # from GH was already validated) and  merge the original action from the request.
    params.except(:action, :controller).permit!.to_h.merge("action": request.request_parameters["action"])
  end
end
