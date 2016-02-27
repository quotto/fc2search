#coding:utf-8

require 'nokogiri'
require 'net/http'
require 'uri'
require 'cgi'
require 'movie'
require 'tag'

class Tasks::MovieCroller
  LIST_URL = 'http://video.fc2.com/a/movie_search.php?timestart=0&timeend=0&timemin=分&perpage=50&usetime=0&page='
  MOVIE_BASE_URL = 'http://video.fc2.com/a/content/'
  def self.execute_all
    puts "start #{DateTime.now}"
    response = fetch_list(1)
    total_num = Nokogiri::HTML(response.body).css('div.pagetitle_under_renew > h3').text.match(/\d*/)[0]
    total_page = (total_num.to_f / 50.0).ceil
    puts "#{total_num} movies/#{total_page}page"

    for i in 1..10 do  
      puts "page:#{i}"

      response = fetch_list(i)
      movie_list = Nokogiri::HTML(response.body).css('/html/body/div#wrap/div#container/div#main/div#content_ad_head_wide/div#video_list_1column/div[class*="video_list_renew"]')
      movie_list.each do |m|
        Thread.fork m do |movie| 
          movie_data = fetch_movie(movie)
          if !movie_data.blank? then
            ActiveRecord::Base.connection_pool.with_connection do
              begin
                movie_data[0].save
                movie_data[1].each do |tag|
                  tag.save
                end
              rescue => e
                puts "database error #{movie_data[0].movieid}"
                puts e
              end
            end
          end
        end
      end
      (Thread.list - [Thread.current]).each &:join
    end
    puts "end #{DateTime.now}"
  end

  def self.execute_day
    response = fetch_list(1)
    total_num = Nokogiri::HTML(response.body).css('div.pagetitle_under_renew > h3').text.match(/\d*/)[0]
    total_page = (total_num.to_f / 50.0).ceil

    today = DateTime.now
    puts "today:#{today}"

    for i in 1..total_page do
      puts "page:#{i}"

      response = fetch_list(i)
      movie_list = Nokogiri::HTML(response.body).css('/html/body/div#wrap/div#container/div#main/div#content_ad_head_wide/div#video_list_1column/div[class*="video_list_renew"]')
      movie_list.each do |movie|
        movie_data = fetch_movie(movie)
        if movie_data != nil then
          upload_at = movie_data[0].upload_at

          date_sub = (today - upload_at.to_datetime).to_i
          if date_sub == 1 then
            begin 
              ActiveRecord::Base.connection_pool.with_connection do
                movie_data[0].save
                movie_data[1].each do |new_tag|
                  new_tag.save
                end
              end
            rescue => e
              puts "database erro #{movie_data[0].movieid}"
              puts e
            end
          elsif date_sub >= 2 then
            return
          end
        end
      end
    end
  end

  def self.execute_update
    base_url = "http://video.fc2.com/a/content/"
    #一度に処理する件数
    per =  50
    total_num = Movie.count
    total_req = (total_num.to_f / per.to_f).ceil
    for i in 1..total_req do
      movies = Movie.limit(per).offset(((i-1)*per) + 1)
      movies.each do |m|
          Thread.fork m do |movie|
            begin
              #個別ページヘアクセスして再生数、アルバム追加数、コメント数を取得
              response = Net::HTTP.get_response(URI.parse(URI.escape(base_url + movie.movieid + '/')))
              response_movie_page = Nokogiri::HTML(response.body)
              if response.code == '302' then
                puts "#{movie.movieid} remove"
                movie.destroy
              else
                puts "#{movie.movieid}" 
                movie_info = response_movie_page.css('#wrap_cont_v2_info_movie > ul:first > li')
                if !movie_info.blank? then
                  playcount = movie_info[0].css('strong').text.to_i
                  albumcount = movie_info[1].css('strong').text.to_i
                  comment = response_movie_page.css('#js-content-comment > div:first > h3 > span').text.match(/\d+/)
                  commentcount = comment==nil ? 0 : comment[0].to_i
                else
                  movie_info = response_movie_page.css('#wrap_cont_v2_info_sales > div[class*=cont_v2_info_sales01] > table > tr')
                  puts "#{movie.movieid} #{movie_info}"
                  playcount = movie_info[7].css('td').text.to_i 
                  albumcount = movie_info[8].css('td').text.to_i 
                  commentcount = movie_info.css('#hlo_comment_reviewnum').text.to_i
                end

                movie.playcount = playcount
                movie.albumcount = albumcount
                movie.commentcount = commentcount

                movie.save
              end
            rescue => e
              puts "error: #{m.movieid}"
              puts e
            end
          end
      end
      (Thread.list - [Thread.current]).each &:join
    end
    puts "end #{DateTime.now}"
  end

  def self.fetch_movie(movie_div)
    movie_thumb = movie_div.css('div.video_list_renew_thumb > div')
    movieid = movie_thumb.attr('upid').text
    movie_url = movie_thumb.css('a').attr('href').text
    thumbnail = movie_thumb.css('a > img').attr('src').text

    #公開種別を取得
    movie_info_right = movie_div.css('div.video_info_right')
    scope = ""
    scope_class = movie_info_right.css('ul[class*="video_info_upper_renew"] > li:nth-child(1)').attr('class').text
    if scope_class.index('all') != nil then
      scope = "0"
    elsif scope_class.index('pay') != nil then
      scope = "1"
    else
      scope = "2"
    end

    playcount = movie_info_right.css('ul[class*="video_info_upper_renew"] > li:nth-child(2)').text
    albumcount = movie_info_right.css('ul[class*="video_info_upper_renew"] > li:nth-child(3)').text
    commentcount = movie_info_right.css('ul[class*="video_info_upper_renew"] > li:nth-child(4)').text
    username = movie_info_right.css('p.user_name > a').text

    begin
      #個別ページヘアクセスして各情報を取得
      response_movie_page = Nokogiri::HTML(Net::HTTP.get_response(URI.parse(URI.escape(MOVIE_BASE_URL + movieid + '/'))).body)

      title = response_movie_page.css('meta[property="og:title"]').attr('content').text
      playtime = response_movie_page.css('meta[property="video:duration"]').attr('content').text
      upload_date = response_movie_page.css('meta[property="video:release_date"]').attr('content').text


      new_movie = Movie.new
      new_movie.movieid = movieid
      new_movie.url = movie_url
      new_movie.title = title
      new_movie.thumbnail = thumbnail
      new_movie.playtime = playtime
      new_movie.playcount = playcount.to_i
      new_movie.albumcount = albumcount.to_i
      new_movie.commentcount = commentcount.to_i
      new_movie.user = username
      new_movie.scope = scope
      new_movie.upload_at = upload_date


      #タグを取得
      movie_tags = response_movie_page.css('ul[class*="cont_v2_info_tag_list"] > li')
      tag_a = Array.new
      movie_tags.each do |movie_tag|
        tag_name = movie_tag.css('a > span').text
        new_tag = Tag.new
        new_tag.movieid = movieid 
        new_tag.tag = tag_name
        tag_a.push(new_tag)
      end

      return [new_movie,tag_a]
    rescue => e
      puts "error:#{movieid}"
      puts e
      return nil
    end
  end

  def self.fetch_list(page)
    response = Net::HTTP.get_response(URI.parse(URI.escape("#{LIST_URL}#{page}")))
  end
end