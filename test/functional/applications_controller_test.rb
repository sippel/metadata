require File.dirname(__FILE__) + '/../test_helper'
require 'application_controller'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < ActionController::TestCase


  class FooController < ApplicationController
  #This is a fake controller in which we can test the various things that should apply to all controllers.
  
    before_filter :admin?, :only => [:testadmin]
  
    def testadmin
      render :text => "You are an admin"
    end
    
    def testpagechoose
      sub = params[:sub]
      con = params[:cont]
      page_req = params[:page_req]
      @page_chosen = template_choose(sub, con, page_req)
      render :text => "Something needs to be rendered"
    end
  end
  
  class FooControllerTest < ActionController::TestCase

    context "the admin function" do
      
      context "when nobody is logged in" do
        setup do
          @controller.current_user = nil
          get :testadmin
        end
        
        should_not respond_with :success
      end
      
      context "when a non-admin is logged in" do
        setup do
          @controller.current_user = User.new(:role => 'notadmin')  
          get :testadmin
        end
        
        should_not respond_with :success
      end
      
      context "when an admin is logged in" do
        setup do
          @controller.current_user = User.new(:role => 'admin')  
          get :testadmin
        end
        
        should respond_with :success
      end
    end
    
    context "template choose function" do
      setup do
        @controller.current_user = User.new(:role => 'admin')  
      end
      
      context "when a subdomain is requested which exists" do
        setup do
          get :testpagechoose, :sub => "lter", :cont => "datatables", :page_req => "index"
        end
        
        should respond_with(:success)
        should assign_to(:page_chosen).with("app/views/datatables/lter_index.html.erb")
      end
      
      context "when a subdomain is requested which does not exist" do
        setup do
          get :testpagechoose, :sub => "lter", :cont => "people", :page_req => "index"
        end

        should respond_with(:success)
        should assign_to(:page_chosen).with("app/views/people/index.html.erb")
      end
      
      context "when a template is in the database" do
        setup do
          lter_website = Factory.create(:website, :name => 'lter')
          index_layout = Factory.create(:template, 
                    :website_id => lter_website.id,
                    :controller => 'datatables',
                    :action     => 'index',
                    :layout     => '<h3 id="correct">testpagechoose</h3>')
          get :testpagechoose, :sub => "lter", :cont => "datatables", :page_req => "index"
        end

        should respond_with(:success)
        should assign_to(:page_chosen).with("app/views/datatables/liquid_index.html.erb")
      end
    end
  end
end

