require 'test_helper'

class GaLabelsControllerTest < ActionController::TestCase
  setup do
    @ga_label = ga_labels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ga_labels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ga_label" do
    assert_difference('GaLabel.count') do
      post :create, ga_label: { name: @ga_label.name }
    end

    assert_redirected_to ga_label_path(assigns(:ga_label))
  end

  test "should show ga_label" do
    get :show, id: @ga_label
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ga_label
    assert_response :success
  end

  test "should update ga_label" do
    patch :update, id: @ga_label, ga_label: { name: @ga_label.name }
    assert_redirected_to ga_label_path(assigns(:ga_label))
  end

  test "should destroy ga_label" do
    assert_difference('GaLabel.count', -1) do
      delete :destroy, id: @ga_label
    end

    assert_redirected_to ga_labels_path
  end
end
