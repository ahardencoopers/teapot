require 'json'
require 'mongo'
require 'nokogiri'
require 'socket'

def get_root_page_view(page, username)
	html = ''
	pagesize = 10
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	db = Mongo::Client.new([ mongoip ], :database => 'teapot')
	pages = (db[:nodes].find({:username => username}).count / 10.0).ceil
	html = html + '<div><h1>' + "Your collection has #{pages}" + ' pages</h1></div>'
	html = html + '<div id="current-page" data-page="' + page.to_s + '"><h2>' + "Current page: #{page}" + '</h2></div>'
	db[:nodes].find({:username => username}).skip(pagesize * (page-1)).limit(pagesize).each do |doc|
		title = doc['title']
		urlid = doc['url'].gsub(/https:\/\/www\.youtube\.com\/watch\?v=/, "")
		urlembed = doc['url'].gsub(/watch\?v=/, 'embed/')
		embed = '<iframe width="360" height="200" 
			src='+ urlembed +'
			frameborder="0" allowfullscreen></iframe>'
		html = html + '<div><h3><a href=/'+urlid+'>' + title + '</a></h3></div>'
		html = html + '<div><a href=/delete/'+urlid+'>delete</a></div>'
		html = html + '<div>' + embed + '</div>'
	end
	db.close

	nextpage = page + 1
	prevpage = page - 1

	if nextpage > pages
		nextpage = page
	end

	if prevpage <= 0
		prevpage = 1
	end

	html = html + '<div>' + '<a id="prev-link">' + 'prev' + '</a> '
	html = html + '<a id="next-link">' + 'next' + '</a>' + '</div>'
	
	return html
end

def get_detailed_view(urlid, username)
	html = ''
	url = "https://www.youtube.com/watch?v=" + urlid
	
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	db = Mongo::Client.new([ mongoip ], :database => 'teapot')

	html = html + '<div><h1><a href="/collection">Return to collection</a></h1></div>'
	querydoc = {}
	querydoc['url'] = url
	querydoc[:username] = username

	db[:nodes].find(querydoc).each do |doc|

		title = doc['title']
		urlembed = "https://www.youtube.com/embed/" + urlid
		embed = '<iframe width="360" height="200" 
				src='+ urlembed +'
				frameborder="0" allowfullscreen></iframe>'
		html = html + '<div><h2><a href='+url+'>' + title + '</a></h2></div>'
		html = html + '<div><a href=/delete/'+urlid+'>delete</a></div>'
		html = html + '<div>' + embed + '</div>'

		doc['related'].each do |related|
			relatedtitle = related['title']
			relatedurlid = related['url'].gsub(/https:\/\/www\.youtube\.com\/watch\?v=/, "")
			relatedurlembed = "https://www.youtube.com/embed/" + relatedurlid
			relatedembed = '<iframe width="360" height="200" 
			src='+ relatedurlembed +'
			frameborder="0" allowfullscreen></iframe>'
			html = html + '<div><h5><a href='+relatedurlid+'>' + relatedtitle + '</a></h5></div>'
			html = html + '<div>' + relatedembed + '</div>'
		end
	end
	db.close

	return html
end

def get_search_view(text, username)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	client[:nodes].find({:title => /.*#{Regexp.escape(text)}.*/, :username => username}).each do |doc|
		title = doc['title']
		urlid = doc['url'].gsub(/https:\/\/www\.youtube\.com\/watch\?v=/, "")
		urlembed = doc['url'].gsub(/watch\?v=/, 'embed/')
		embed = '<iframe width="360" height="200" 
			src='+ urlembed +'
			frameborder="0" allowfullscreen></iframe>'
		html = html + '<div><h3><a href=/'+urlid+'>' + title + '</a></h3></div>'
		html = html + '<div><a href=/delete/'+urlid+'>delete</a></div>'
		html = html + '<div>' + embed + '</div>'
	end
	client.close

	return html
end

def get_users_page_root(username)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	client[:users].find.each do |doc|
		html = html + '<div class="row"><div class="col-xs-4"><h3><a href="/user/'+doc[:username]+'">'+doc[:username]+'</a></h3></div>'
		if doc[:username] == username
			html = html + '<div clas="col-xs-3"><button class="btn btn-default" disabled>Follow</button></div></div>'
		elsif client[:follows].find({:follows => username, :followed => doc[:username]}).count <= 0
			html = html + '<div clas="col-xs-3">' + follow_button_view(doc[:username]) + '</div></div>'
		else
			html = html + '<div clas="col-xs-3">' + unfollow_button_view(doc[:username]) + '</div></div>'
		end
	end
	client.close

	return html
end

def get_detailed_user_view(username)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	client[:users].find({:username => username}).each do |doc|
		html = html + '<div class="row"><div class="col-xs-4"><h3><a>'+doc[:username]+'</a></h3></div></div>'
		html = html + '<div class="row"><div class="col-xs-4"><a href="/user-collection/'+doc[:username]+'">Browse '+doc[:username]+'\'s collection</a></div></div>'
		html = html + '<div class="row"><div class="col-xs-4">'+doc[:username]+'\'s recently added videos</div></div>'
		i = 0
		client[:nodes].find({:username => username}).sort({_id:-1}).each do |video|
			if i >= 5
				break
			else
				html = html + '<div class="row">'
				title = video['title']
				urlid = video['url'].gsub(/https:\/\/www\.youtube\.com\/watch\?v=/, "")
				urlembed = video['url'].gsub(/watch\?v=/, 'embed/')
				embed = '<iframe width="360" height="200" 
					src='+ urlembed +'
					frameborder="0" allowfullscreen></iframe>'
				html = html + '<div><h3><a href=/'+urlid+'>' + title + '</a></h3></div>'
				html = html + '<div>' + embed + '</div>'
				html = html + '</div>'
			end
			i = i + 1
		end
	end
	client.close
	return html
end

def get_root_page_user_view(username, page)
	html = ''
	pagesize = 10
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	db = Mongo::Client.new([ mongoip ], :database => 'teapot')
	pages = (db[:nodes].find({:username => username}).count / 10.0).ceil
	html = html + '<div><h1>' + "This collection has #{pages}" + ' pages</h1></div>'
	html = html + '<div id="current-page" data-page="' + page.to_s + '"><h2>' + "Current page: #{page}" + '</h2></div>'
	db[:nodes].find({:username => username}).skip(pagesize * (page-1)).limit(pagesize).each do |doc|
		title = doc['title']
		urlid = doc['url'].gsub(/https:\/\/www\.youtube\.com\/watch\?v=/, "")
		urlembed = doc['url'].gsub(/watch\?v=/, 'embed/')
		embed = '<iframe width="360" height="200" 
			src='+ urlembed +'
			frameborder="0" allowfullscreen></iframe>'
		html = html + '<div><h3><a href=/'+urlid+'>' + title + '</a></h3></div>'
		html = html + '<div>' + embed + '</div>'
	end
	db.close

	nextpage = page + 1
	prevpage = page - 1

	if nextpage > pages
		nextpage = page
	end

	if prevpage <= 0
		prevpage = 1
	end

	html = html + '<div>' + '<a id="prev-link">' + 'prev' + '</a> '
	html = html + '<a id="next-link">' + 'next' + '</a>' + '</div>'
	
	return html
end

def get_search_collection_user_view(username, text)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	client[:nodes].find({:title => /.*#{Regexp.escape(text)}.*/, :username => username}).each do |doc|
		title = doc['title']
		urlid = doc['url'].gsub(/https:\/\/www\.youtube\.com\/watch\?v=/, "")
		urlembed = doc['url'].gsub(/watch\?v=/, 'embed/')
		embed = '<iframe width="360" height="200" 
			src='+ urlembed +'
			frameborder="0" allowfullscreen></iframe>'
		html = html + '<div><h3><a href=/'+urlid+'>' + title + '</a></h3></div>'
		html = html + '<div>' + embed + '</div>'
	end
	client.close

	return html
end

def unfollow_button_view(username)
	html = '<button class="btn btn-default unfollow-btn" data-user="'+username+'">Unfollow</button>'
	return html
end

def follow_button_view(username)
	html = '<button class="btn btn-default follow-btn" data-user="'+username+'">Follow</button>'
	return html
end

def search_users_view(username, text)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	client[:users].find({:username => /.*#{Regexp.escape(text)}.*/}).each do |doc|
		html = html + '<div class="row"><div class="col-xs-4"><h3><a href="/user/'+doc[:username]+'">'+doc[:username]+'</a></h3></div>'
		if doc[:username] == username
			html = html + '<div clas="col-xs-3"><button class="btn btn-default" disabled>Follow</button></div></div>'
		elsif client[:follows].find({:follows => username, :followed => doc[:username]}).count <= 0
			html = html + '<div clas="col-xs-3">' + follow_button_view(doc[:username]) + '</div></div>'
		else
			html = html + '<div clas="col-xs-3">' + unfollow_button_view(doc[:username]) + '</div></div>'
		end
	end
	client.close

	return html
end

def get_video_leaderboard_view(username, leaders)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	leaders.each do |leader|
		html = html + '<div class="row"><div class="col-xs-4"><h3><a href="/user/'+leader[:username]+'">'+leader[:username]+'</a> '+leader[:videos].to_s+' videos</h3></div>'
		if leader[:username] == username
			html = html + '<div clas="col-xs-3"><button class="btn btn-default" disabled>Follow</button></div></div>'
		elsif client[:follows].find({:follows => username, :followed => leader[:username]}).count <= 0
			html = html + '<div clas="col-xs-3">' + follow_button_view(leader[:username]) + '</div></div>'
		else
			html = html + '<div clas="col-xs-3">' + unfollow_button_view(leader[:username]) + '</div></div>'
		end
	end
	client.close

	return html
end

def get_follower_leaderboard_view(username, leaders)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	leaders.each do |leader|
		html = html + '<div class="row"><div class="col-xs-4"><h3><a href="/user/'+leader[:username]+'">'+leader[:username]+'</a> '+leader[:followers].to_s+' followers</h3></div>'
		if leader[:username] == username
			html = html + '<div clas="col-xs-3"><button class="btn btn-default" disabled>Follow</button></div></div>'
		elsif client[:follows].find({:follows => username, :followed => leader[:username]}).count <= 0
			html = html + '<div clas="col-xs-3">' + follow_button_view(leader[:username]) + '</div></div>'
		else
			html = html + '<div clas="col-xs-3">' + unfollow_button_view(leader[:username]) + '</div></div>'
		end
	end
	client.close

	return html
end

def get_recently_added_videos_view(username, followed)
	html = ''
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	client = Mongo::Client.new([ mongoip ], :database => 'teapot')
	followed.each do |uname|
		client[:nodes].find({:username => uname}).sort({:_id => -1}).limit(1).each do |doc|
			title = doc['title']
			urlid = doc['url'].gsub(/https:\/\/www\.youtube\.com\/watch\?v=/, "")
			urlembed = doc['url'].gsub(/watch\?v=/, 'embed/')
			embed = '<iframe width="360" height="200" 
				src='+ urlembed +'
				frameborder="0" allowfullscreen></iframe>'
			html = html + '<div><h3><a href=/'+urlid+'>' + title + '</a></h3></div>'
			html = html + '<div><h6>Added by <a href="/user/'+uname+'">'+uname+'</a></h6></div>'
			html = html + '<div>' + embed + '</div>'
		end
	end

	return html
end

def get_followed_users_view(username, followed)
	html = ''
	followed.each do |uname|
		html = html + '<div class="row"><div class="col-xs-4"><h3><a href="/user/'+uname+'">'+uname+'</a></h3></div>'
		html = html + '<div clas="col-xs-3">' + unfollow_button_view(uname) + '</div></div>'
	end

	return html
end
