class TimelineBroadcastJob < ApplicationJob
  queue_as :default

  def perform(timeline)
    pp "perform ============================================"
    # Do something later
    pp timeline
    json_response = {
      :status => true,
      :response => {
        :timeline => timeline,
      },
    }
    channel = ""
    if (timeline[:from_member_id] < timeline[:to_member_id])
      channel = "timeline_channel" + timeline[:from_member_id].to_s + "-" + timeline[:to_member_id].to_s
    else
      channel = "timeline_channel" + timeline[:to_member_id].to_s + "-" + timeline[:from_member_id].to_s
    end
    ActionCable.server.broadcast channel, json_response
  end
end
