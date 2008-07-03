require File.dirname(__FILE__) + '/../../test_helper'

class Dt::WallPostsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:dt_wall_posts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_wall_post
    assert_difference('Dt::WallPost.count') do
      post :create, :wall_post => { }
    end

    assert_redirected_to wall_post_path(assigns(:wall_post))
  end

  def test_should_show_wall_post
    get :show, :id => dt_wall_posts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => dt_wall_posts(:one).id
    assert_response :success
  end

  def test_should_update_wall_post
    put :update, :id => dt_wall_posts(:one).id, :wall_post => { }
    assert_redirected_to wall_post_path(assigns(:wall_post))
  end

  def test_should_destroy_wall_post
    assert_difference('Dt::WallPost.count', -1) do
      delete :destroy, :id => dt_wall_posts(:one).id
    end

    assert_redirected_to dt_wall_posts_path
  end
end
