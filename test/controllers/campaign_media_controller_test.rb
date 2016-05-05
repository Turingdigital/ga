require 'test_helper'

class CampaignMediaControllerTest < ActionController::TestCase
  setup do
    @campaign_medium = campaign_media(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:campaign_media)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create campaign_medium" do
    assert_difference('CampaignMedium.count') do
      post :create, campaign_medium: { medium: @campaign_medium.medium }
    end

    assert_redirected_to campaign_medium_path(assigns(:campaign_medium))
  end

  test "should show campaign_medium" do
    get :show, id: @campaign_medium
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @campaign_medium
    assert_response :success
  end

  test "should update campaign_medium" do
    patch :update, id: @campaign_medium, campaign_medium: { medium: @campaign_medium.medium }
    assert_redirected_to campaign_medium_path(assigns(:campaign_medium))
  end

  test "should destroy campaign_medium" do
    assert_difference('CampaignMedium.count', -1) do
      delete :destroy, id: @campaign_medium
    end

    assert_redirected_to campaign_media_path
  end
end
