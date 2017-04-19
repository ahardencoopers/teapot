require 'sinatra'
require 'json'
require 'bcrypt'
require './data.rb'
require './scrape.rb'
require './view.rb'

set(:port, 4000)

enable :sessions

get '/' do
	send_file 'public/index.html'
end

get '/register' do
	send_file 'public/register.html'
end

get '/login' do
	send_file 'public/login.html'
end

get '/home' do
	send_file 'public/home.html'
end

get '/logout' do
	session.delete(:username)
	redirect '/'
end

get '/add-video' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/add_video.html'
	end
end

get '/collection' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/collection.html'
	end
end

get '/delete/:urlid' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		url = 'https://www.youtube.com/watch?v=' + params[:urlid]
		delete_video_scrape(url, session[:username])
		redirect '/collection'
	end
end

get '/browse-users' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/browse_users.html'
	end
end

get '/user/:username' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/user_detailed.html'
	end
end

get '/user-collection/:username' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/user_collection.html'
	end
end

get '/video-leaderboard' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/video_leaderboard.html'
	end
end

get '/follower-leaderboard' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/follower_leaderboard.html'
	end
end

get '/recently-added' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/recently-added.html'
	end
end

get '/browse-followed' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/browse_followed.html'
	end
end

get '/edit-profile' do
	if session[:username] == nil
		send_file 'public/error.html'
	else
		send_file 'public/edit_profile.html'
	end
end

post '/request' do
	content_type :json

	case params[:action]
	when 'register'
		if search_user_data(params[:username]) != nil
			user = search_user_data(params[:username])
			return user['username']
		else
			salt = BCrypt::Engine.generate_salt
			hash = BCrypt::Engine.hash_secret(params[:password], salt)
			add_user_data(params[:username], hash, salt)
			session[:username] = params[:username]
			return {:result => session[:username]}.to_json
		end
	when 'login'
		user = get_user_data(params[:username])
		password = BCrypt::Engine.hash_secret(params[:password], user[:salt])
		if password == user[:hash]
			session[:username] = params[:username]
			return {:result => 'ok'}.to_json
		else
			return 'error'
		end
	when 'load-home'
		return {:username => session[:username]}.to_json
	when 'add_video'
		if session[:username] == nil
			return 'error'
		else
			add_video_scrape(params[:url], session[:username])
			return {:result => 'ok'}.to_json
		end
	when 'get_root_page'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_root_page_view(params[:page].to_i, session[:username])}.to_json
		end
	when 'get_detailed_view'
		if session[:username] == nil
			send_file 'public_error.html'
		else
			return {:html => get_detailed_view(params[:urlid], session[:username])}.to_json
		end
	when 'search_collection'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_search_view(params[:text], session[:username])}.to_json
		end
	when 'get_users_root'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_users_page_root(session[:username])}.to_json
		end
	when 'get_detailed_view_user'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_detailed_user_view(params[:username])}.to_json
		end
	when 'get_root_page_user'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_root_page_user_view(params[:username], params[:page].to_i)}.to_json
		end
	when 'search_collection_user'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_search_collection_user_view(params[:username], params[:text])}.to_json
		end
	when 'follow_user'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			follow_user_data(session[:username], params[:username])
			return {:html => unfollow_button_view(params[:username])}.to_json
		end
	when 'unfollow_user'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			unfollow_user_data(session[:username], params[:username])
			return {:html => follow_button_view(params[:username])}.to_json
		end
	when 'search_users'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => search_users_view(session[:username], params[:text])}.to_json
		end
	when 'get_video_leaderboard'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_video_leaderboard_view(session[:username], video_leaderboard_data)}.to_json
		end
	when 'get_follower_leaderboard'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_follower_leaderboard_view(session[:username], follower_leaderboard_data)}.to_json
		end
	when 'get_recently_added_videos'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_recently_added_videos_view(session[:username], get_followed_data(session[:username]))}.to_json
		end
	when 'get_followed_users'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			return {:html => get_followed_users_view(session[:username], get_followed_data(session[:username]))}.to_json
		end
	when 'delete_account'
		if session[:username] == nil
			send_file 'public/error.html'
		else
			user = get_user_data(session[:username])
			password = BCrypt::Engine.hash_secret(params[:password], user[:salt])
			if password == user[:hash]
				delete_user_data(session[:username])
				return {:result => 'ok'}.to_json
			else
				return 'error'
			end
		end
	end
end

get '/:urlid' do
	if session[:username] == nil 
		send_file 'public/error.html'
	else
		url = 'https://www.youtube.com/watch?v=' + params[:urlid]
		add_video_scrape(url, session[:username])
		send_file 'public/detailed.html'
	end
end

