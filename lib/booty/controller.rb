require "#{RAILS_ROOT}/app/controllers/application.rb"

module Booty
  class Controller < ApplicationController
    before_filter :ensure_valid_key

  private

    def ensure_valid_key
      redirect_to '/404.html' if !Booty::BootyMap.booty_map.exists?(params[:controller], params[:action], params[:id])
    end
    
  end
end

