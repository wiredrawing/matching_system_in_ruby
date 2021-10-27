require "test_helper"

class Api::TimelineControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def test_create_message
    pp(api_timeline_create_message_path)
    post_params = {
      :message => {
        :message => "メッセージ作成 テスト",
        :from_member_id => 1,
        :to_member_id => 2,
      },
    }
    pp(post_params)
    response = post api_timeline_create_message_path, :params => post_params
    pp(response)
  end
end
