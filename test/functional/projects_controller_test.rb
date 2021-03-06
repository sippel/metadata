require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < ActionController::TestCase

  def setup
    #TODO test with admin and non admin users
    @controller.current_user = User.new(:role => 'admin')  
  end
  
  def teardown
    Project.destroy_all
  end
  
  context "on GET to :index" do
    setup do
      get :index
    end
    
    should assign_to :projects
    should render_template :index
  end
  
  context "on GET to :show for a project" do
    setup do
      @project = Factory.create(:project)
      get :show, :id => @project
    end

    should render_template :show
    should assign_to :project
  end

  context "on GET to :new" do
    setup do
      get :new
    end

    should assign_to :project
    should assign_to :datasets
    should render_template :new
  end
  
  context "on GET to :edit for a project" do
    setup do
      @project = Factory.create(:project)
      get :edit, :id => @project
    end
    
    should render_template :edit
    should assign_to :project
    should assign_to :datasets
  end

  context "on POST to :create for a valid project" do  
    setup do
      post :create, :project => {}
    end
    
    should redirect_to("the project's page") {project_url(assigns(:project))}
    should set_the_flash
  end
  
  #A test should be made for trying to create an invalid project once invalid projects are possible.

  context "on PUT :update for a project" do
    setup do
      @project = Factory.create(:project, :title => "The old boring title")
    end
    
    context "with a valid change" do
    
      setup do
        put :update, :id => @project, :project => {:title => "A new title"}
      end
    
      should assign_to :project
      should set_the_flash
      should redirect_to("the project's show page") {project_url(@project)}
    end
  end

#   A test should be made trying to update with an invalid change if any invalid parameters are ever adopted.  

  context "a project which exists" do
    setup do
      @project = Factory.create(:project)
    end
    
    context "on DELETE :destroy for the project" do
      setup do
        delete :destroy, :id => @project
      end
      
      should assign_to :project
      should redirect_to("projects page") {projects_url}
    end
  end
  
end

