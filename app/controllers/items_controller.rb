class ItemsController < ApplicationController
    
    def new
    end
    
    def show
        render "items"
    end
    
    def index
        @parts = Participant.all
        @votes = Vote.all
    end
    
    def vote
        number = params[:num].to_i
        Vote.create(num: number)
        redirect_to :action => "finish"
    end
    
    def finish
        
    end
    
    def add
        Participant.create(
            name: params[:name],
            img: params[:img])
        redirect_to :action => "index"
    end
    
end
