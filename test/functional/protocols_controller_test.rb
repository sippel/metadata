require File.dirname(__FILE__) + '/../test_helper'
require 'protocols_controller'

# Re-raise errors caught by the controller.
class ProtocolsController; def rescue_action(e) raise e end; end

class ProtocolsControllerTest < ActionController::TestCase
  fixtures :protocols

  def setup
    @controller = ProtocolsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:protocols)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_protocol
     old_count = Protocol.count
     post :create, :protocol => {:dataset_id => 35 }
     assert_equal old_count+1, Protocol.count
     
     assert_redirected_to protocol_path(assigns(:protocol))
   end

  def test_should_show_protocol
    get :show, :id => 48
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 48
    assert_response :success
  end
  
  def test_should_update_protocol
    put :update, :id => 48, :protocol => { }
    assert_redirected_to protocol_path(assigns(:protocol))
  end
  
  def test_should_destroy_protocol
    old_count = Protocol.count
    delete :destroy, :id => 48
    assert_equal old_count-1, Protocol.count
    
    assert_redirected_to protocols_path
  end
end
