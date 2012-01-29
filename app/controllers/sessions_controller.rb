class SessionsController < ApplicationController
def create
	auth = request.env["omniauth.auth"]
	user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
	
	if user #Direct to Dashboard if an existing user
		session[:user_id] = user.id
		redirect_path = user
	else #Direct to New Project signup if this is a new user
		user = User.create_with_omniauth(auth)
		session[:user_id] = user.id
		redirect_path = new_project_path
	end
	if session[:redirect]
		@project = Project.find(session[:redirect])
		session[:redirect] = nil
		redirect_path = new_project_share_path(@project) 
	end
	redirect_to redirect_path
end

def new
end	

def destroy
	session[:user_id] = nil
	redirect_to root_url, :notice => "Signed out!"
end
end