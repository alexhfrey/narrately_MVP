class ActionPagesController < ApplicationController
before_filter :is_page_admin
  def new
	 @user = current_user
	 @project = Project.find(params[:project_id])
     graph = Koala::Facebook::API.new(@user.token)
	 @posts = graph.get_connections("me", "posts") .select {|t| t["message"].present? } [0...5]
	 @newaction = @project.action_pages.build
  end

  def create
  @user = current_user
  @project = Project.find(params[:project_id])
  type = params[:actionable_type]
  link = params[:link]
 
  if type == "tweet"  
	@action = Tweet.new
	@action.link = link
  elsif type == "retweet"
	@action = Retweet.new
	@action.post_id = link.split('/').last
	@action.message = Twitter.status(@action.post_id).text
  elsif type == "like" 
	graph = Koala::Facebook::API.new(@user.token)
	@action = Like.new
	link_split = link.split('https://').last.split('/')
	uid = graph.get_object(link_split.second)["id"] 
	@action.post_id = uid + '_' + link_split.last
	@action.message = graph.get_object(@action.post_id)["message"]
	
  elsif type == "post"
	@action = Post.new
	@action.link = link
  elsif type == "fb_comment"
    graph = Koala::Facebook::API.new(@user.token)
	@action = Fbcomment.new
	link_split = link.split('https://').last.split('/')
	uid = graph.get_object(link_split.second)["id"] 
	@action.post_id = uid + '_' + link_split.last
	@action.message = graph.get_object(@action.post_id)["message"]
  elsif type == "other"
  end
  
    if @action.save 
		action_page = @action.build_action_page(:project_id => @project.id, :prompt => params[:prompt], 
						:title => params[:title])
		action_page.save
		@action.save
		redirect_to backers_project_path(@project)
	end
  end
  def show
  
  end

  def is_page_admin      #right now page admin is just the creator, but could add a field here later
  @project = Project.find(params[:project_id])
  if @project.user != current_user && current_user.id != 7
	redirect_to @project
	flash[:error] = "You must be the project creator in order to create a new action." 
  end
  end
  
end
