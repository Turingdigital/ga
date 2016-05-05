require 'test_helper'

class UrlBuildersControllerTest < ActionController::TestCase
  setup do
    @url_builder = url_builders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:url_builders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create url_builder" do
    assert_difference('UrlBuilder.count') do
      post :create, url_builder: { content: @url_builder.content, medium: @url_builder.medium, name: @url_builder.name, source: @url_builder.source, term: @url_builder.term, url: @url_builder.url, user_id: @url_builder.user_id }
    end

    assert_redirected_to url_builder_path(assigns(:url_builder))
  end

  test "should show url_builder" do
    get :show, id: @url_builder
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @url_builder
    assert_response :success
  end

  test "should update url_builder" do
    patch :update, id: @url_builder, url_builder: { content: @url_builder.content, medium: @url_builder.medium, name: @url_builder.name, source: @url_builder.source, term: @url_builder.term, url: @url_builder.url, user_id: @url_builder.user_id }
    assert_redirected_to url_builder_path(assigns(:url_builder))
  end

  test "should destroy url_builder" do
    assert_difference('UrlBuilder.count', -1) do
      delete :destroy, id: @url_builder
    end

    assert_redirected_to url_builders_path
  end
end
