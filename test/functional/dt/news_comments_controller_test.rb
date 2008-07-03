require File.dirname(__FILE__) + '/../../test_helper'

class Dt::NewsCommentsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:dt_news_comments)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_news_comment
    assert_difference('Dt::NewsComment.count') do
      post :create, :news_comment => { }
    end

    assert_redirected_to news_comment_path(assigns(:news_comment))
  end

  def test_should_show_news_comment
    get :show, :id => dt_news_comments(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => dt_news_comments(:one).id
    assert_response :success
  end

  def test_should_update_news_comment
    put :update, :id => dt_news_comments(:one).id, :news_comment => { }
    assert_redirected_to news_comment_path(assigns(:news_comment))
  end

  def test_should_destroy_news_comment
    assert_difference('Dt::NewsComment.count', -1) do
      delete :destroy, :id => dt_news_comments(:one).id
    end

    assert_redirected_to dt_news_comments_path
  end
end
