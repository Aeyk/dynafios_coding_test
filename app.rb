#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'builder'
require 'sinatra'

# Feature 1 - Display WordPress Posts
# The application should display the most recent 10 posts from the REST API on this WordPress site: http://wordpress.org/news/wp-json/ .
# The post should be displayed in a well designed table.
# The columns of the table should be [ id, slug, status, title, creation date ].
# When a user clicks on a table row, the application should display a link to the post and then render the post content.

wp_url = URI.parse "https://wordpress.org/news/wp-json/wp/v2/posts"
wp_request = Net::HTTP.get(wp_url)
wp_result = Net::HTTP.start(wp_url.host, wp_url.port,
                            :use_ssl => wp_url.scheme == 'https') {|http|
  http.request_get(wp_url)
}
fields = %w(id slug status title date)
ten_posts_raw = JSON.parse(wp_result.body)
ten_posts = ten_posts_raw.map {|row| row.select {|k,v| fields.include? k}}
template = File.new("1.html", "w")

html = "<!doctype html><html><script src='./src.js'><head></script></head><body><table><thead><tr>"
ten_posts.map(&:keys)[0].each {|k|  
  html << "<th>" + k.to_s + "</th>"
}
html << "</tr></thead><tbody><tr>"

ten_posts.map {|post|
  html << "<tr" + " class=id id=#{post['id']}>"
  post.each {|k, v|
    if k == 'title'      
      html << "<td>"
      html << v["rendered"].to_s      
      html << "</td>"
    else
      html << "<td>" + v.to_s + "</td>"
    end
  }
  html << "</tr>"
}
html << "</tbody></table></body></html>"

# print html
template.write(html)
template.close

set :public_folder, 'public'
get '/' do
  id = params['id']
  wp_page_url = wp_url = URI.parse  "https://wordpress.org/news/wp-json/wp/v2/posts/#{id}"
  wp_request = Net::HTTP.get(wp_page_url)
  wp_result = Net::HTTP.start(wp_page_url.host, wp_page_url.port,
                              :use_ssl =>
                              wp_page_url.scheme == 'https') {|http|
    http.request_get(wp_page_url)
  }
  if id
    JSON.parse(wp_result.body)['content']['rendered'].to_s
  else
    html
  end
end
