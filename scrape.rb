require 'open-uri'
require 'nokogiri'
require 'json'
require 'htmlentities'
require 'mongo'
require 'socket'


def add_video_scrape(url, username)
	html = Nokogiri::HTML(open(url))

	title = html.css("#eow-title").attribute("title").value

	root = {}
	root["title"] = title
	root["url"] = url
	root[:username] = username

	related = []

	breadth = 18

	breadth.times do |i|
		if i == 0
			next
		end
		if i%2 == 0
			relatednode = {}
			relatednode["title"] = html.css("#watch-related li .content-wrapper a")[i].attribute("title").value
			relatednode["url"] = "https://www.youtube.com" + html.css("#watch-related li .content-wrapper a")[i].attribute("href").value
			relatedjson = JSON.generate(relatednode)
			related.push(relatednode)
		end
	end

	root["related"] = related

	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	db = Mongo::Client.new([ mongoip ], :database => 'teapot')

	querydoc = {}
	querydoc["url"] = url
	querydoc[:username] = username
	if db[:nodes].find(querydoc).count() <= 0
		db[:nodes].insert_one(root)
	end

	db.close
end

def delete_video_scrape(url, username)
	mongoip = Socket.ip_address_list[1].inspect_sockaddr + ':27017'
	db = Mongo::Client.new([ mongoip ], :database => 'teapot')

	querydoc = {}
	querydoc["url"] = url
	querydoc[:username] = username

	db[:nodes].delete_one(querydoc)

	db.close
end
