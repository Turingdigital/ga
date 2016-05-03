require 'test_helper'

class AccountSummariesControllerTest < ActionController::TestCase
  setup do
    @account_summary = account_summaries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:account_summaries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create account_summary" do
    assert_difference('AccountSummary.count') do
      post :create, account_summary: { jsonString: @account_summary.jsonString, user_id: @account_summary.user_id }
    end

    assert_redirected_to account_summary_path(assigns(:account_summary))
  end

  test "should show account_summary" do
    get :show, id: @account_summary
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @account_summary
    assert_response :success
  end

  test "should update account_summary" do
    patch :update, id: @account_summary, account_summary: { jsonString: @account_summary.jsonString, user_id: @account_summary.user_id }
    assert_redirected_to account_summary_path(assigns(:account_summary))
  end

  test "should destroy account_summary" do
    assert_difference('AccountSummary.count', -1) do
      delete :destroy, id: @account_summary
    end

    assert_redirected_to account_summaries_path
  end
end
