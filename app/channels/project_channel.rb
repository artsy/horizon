class ProjectChannel < ApplicationCable::Channel
  def subscribed
    stream_from self.class.channel_name(params[:organization_id])
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.channel_name(organization_id = nil)
    "organization:#{organization_identifier(organization_id)}"
  end

  def self.organization_identifier(organization_id = nil)
    (organization_id || -1).to_s # -1 indicates subscription to all organizations' updates
  end
end
