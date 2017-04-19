require 'mongo'

def add_user_data(username, hash, salt)
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	client[:users].insert_one({:username => username, :hash => hash, :salt => salt})
	client.close
end

def search_user_data(username)
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	user = ""
	client[:users].find({:username => username}).each {|doc| user = doc}
	if user != ""
		return user
	else
		return nil
	end
end

def get_user_data(username)
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	user = ""
	client[:users].find({:username => username}).each {|doc| user = doc}
	if user == ""
		return nil
	else
		return user
	end
end

def follow_user_data(follows, followed)
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	if client[:follows].find({:follows => follows, :followed => followed}).count <= 0
		client[:follows].insert_one({:follows => follows, :followed => followed})
	end
	client.close
end

def unfollow_user_data(follows, followed)
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	if client[:follows].find({:follows => follows, :followed => followed}).count == 1
		client[:follows].delete_one({:follows => follows, :followed => followed})
	end
	client.close
end

def video_leaderboard_data()
	leaderboard = []
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	client[:users].find.each do |doc|
		leaderboard.push(
			{
				:username => doc[:username],
				:videos => client[:nodes].find({:username => doc[:username]}).count
			}
		)
	end
	client.close
	return leaderboard.sort_by {|leader| leader[:videos]}.reverse[0, 5]
end

def follower_leaderboard_data()
	leaderboard = []
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	client[:users].find.each do |doc|
		leaderboard.push(
			{
				:username => doc[:username],
				:followers => client[:follows].find({:followed => doc[:username]}).count
			}
		)
	end
	client.close
	return leaderboard.sort_by {|leader| leader[:followers]}.reverse[0, 5]
end

def get_followed_data(username)
	followed = []
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	client[:follows].find({:follows => username}).each do |doc|
		followed.push(doc[:followed])
	end

	return followed
end

def delete_user_data(username)
	client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'teapot')
	client[:follows].delete_many({:followed => username})
	client[:follows].delete_many({:follows => username})
	client[:nodes].delete_many({:username => username})
	client[:users].delete_many({:username => username})
end
