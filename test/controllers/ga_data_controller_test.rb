require 'test_helper'

class GaDataControllerTest < ActionController::TestCase
  setup do
    @ga_datum = ga_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ga_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ga_datum" do
    assert_difference('GaDatum.count') do
      post :create, ga_datum: { ga_label_id: @ga_datum.ga_label_id, json: @ga_datum.json, profile: @ga_datum.profile }
    end

    assert_redirected_to ga_datum_path(assigns(:ga_datum))
  end

  test "should show ga_datum" do
    get :show, id: @ga_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ga_datum
    assert_response :success
  end

  test "should update ga_datum" do
    patch :update, id: @ga_datum, ga_datum: { ga_label_id: @ga_datum.ga_label_id, json: @ga_datum.json, profile: @ga_datum.profile }
    assert_redirected_to ga_datum_path(assigns(:ga_datum))
  end

  test "should destroy ga_datum" do
    assert_difference('GaDatum.count', -1) do
      delete :destroy, id: @ga_datum
    end

    assert_redirected_to ga_data_path
  end
end
