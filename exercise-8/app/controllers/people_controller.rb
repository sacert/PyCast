class PeopleController < ApplicationController
	
	
	def index
		@contacts = Person.all
	end

	def show
    	@contact = Person.find(params[:id])
  	end

	def new
		@contact = Person.new
	end

	def edit 
		@contact = Person.find(params[:id])
	end 

	def create
		@contact = Person.new(contact_params)
  		
  		if @contact.save
  			redirect_to @contact
  		else
  			render 'new'
  		end
	end

	def update
		@contact = Person.find(params[:id])
  		
  		if @contact.update(contact_params)
  			redirect_to @contact
  		else
  			render 'edit'
  		end
	end


  def destroy
    @contact = Person.find(params[:id])
    @contact.destroy
 
    redirect_to people_path
  end

private
  	
  	def contact_params
    params.require(:contact).permit(:FirstName, :LastName, :Email, :Phone)
  	end

end
