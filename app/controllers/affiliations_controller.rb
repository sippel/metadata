class AffiliationsController < ApplicationController
 
  # GET /affiliations/new
  def new
    @affiliation = Affiliation.new
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'affiliations', :partial => "new"
        end
      end
    end
  end

end
