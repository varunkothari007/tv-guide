require 'test_helper'

class TvGuidesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tv_guides_index_url
    assert_response :success
  end

end
