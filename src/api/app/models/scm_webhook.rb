# Contains the payload extracted from a SCM webhook and provides helper methods to know which webhook event we're dealing with
class ScmWebhook
  include ActiveModel::Model

  attr_accessor :payload

  validates_with ScmWebhookEventValidator

  def initialize(attributes = {})
    super
    # To safely navigate the hash and compare keys
    @payload = attributes[:payload].deep_symbolize_keys
  end

  def new_pull_request?
    (github_pull_request? && @payload[:action] == 'opened') ||
      (gitlab_merge_request? && @payload[:action] == 'open')
  end

  def updated_pull_request?
    (github_pull_request? && @payload[:action] == 'synchronize') ||
      (gitlab_merge_request? && @payload[:action] == 'update')
  end

  private

  def github_pull_request?
    @payload[:scm] == 'github' && @payload[:event] == 'pull_request'
  end

  def gitlab_merge_request?
    @payload[:scm] == 'gitlab' && @payload[:event] == 'Merge Request Hook'
  end
end