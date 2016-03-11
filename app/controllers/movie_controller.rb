class MovieController < ApplicationController
  include MovieHelper

  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def search
    @keyword = params[:keyword]
    @scope0 = params[:scope0]
    @scope1 = params[:scope1]
    @scope2 = params[:scope2]
    @playtime = params[:playtime]
    @sort = params[:sort]
    @user = params[:user]
    @page = params[:page]

    if !search_validate(params) then
      render 'index'
      return
    end

    movies = Movie.arel_table

    movies_chain = nil
    scope_cond = nil
#     if @scope0.blank? or @scope1.blank? or @scope2.blank? then
#         scope_condition = Array.new
#       if !@scope0.blank?  then
#         scope_condition.push('0')
#       end
#       if !@scope1.blank? then
#         scope_condition.push('1')
#       end
#       if !@scope2.blank? then
#         scope_condition.push('2')
#       end
#       scope_cond = movies[:scope].in(scope_condition)
#       movies_chain = movies_chain.blank? ? scope_cond : movies_chain.where(scope_cond)
#     end
#
    condition_a = Array.new
    params_a = Array.new
    playtime_cond = nil
    if !@playtime.blank? then
      # playtime_cond = movies[:playtime].gteq(@playtime.to_i * 60)
      # movies_chain = movies_chain.blank? ? playtime_cond : movies_chain.and(playtime_cond)
      condition_a.push("movies.playtime >= ?")
      params_a.push(@playtime.to_i * 60)
    end

    user_cond = nil
    if !@user.blank? then
      @user.delete('')
      if @user.size > 0 then
        # user_cond = movies[:user].not_in(@user)
        # movies_chain = movies_chain.blank? ? user_cond : movies_chain.and(user_cond)
        user_condition = "(movies.user not in(?"
        params_a.push(@user[0])
        @user.shift
        @user.each_with_index do |user|
          user_condition = ",?"
          params_a.push(user)
        end
        user_condition = "#{user_condition}))"
        condition_a.push(user_condition)
      end
    end

    # keyword_cond = nil
    if !@keyword.blank? then
      keyword_a = @keyword.split(' ')
      puts keyword_a[0]
      # keyword_cond = movies.where("match(ngramtext) against(+#{against_cond} in boolean mode)")
      # keyword_cond = movies[:title].matches("%#{@keyword}%").or(movies[:tags].matches("%#{@keyword}%"))
      # movies_chain = movies_chain.blank? ? keyword_cond : movies_chain.and(keyword_cond)
      ngram = NGram.new({size: 2,word_separeter: ' ',padchar: ''})
      against_param = ""
      if keyword_a.size == 1 then
        against_param = '+"' + ngram.parse(keyword_a[0]).join(' ') + '" '+keyword_a[0]
      else
        keyword_a.each do |keyword|
          puts ngram.parse(keyword)
          against_param = against_param + '+("' + ngram.parse(keyword).join(' ') + '" '+keyword + ')'
        end
      end
      against_condition = "(match(movies.ngramtext) against(?  in boolean mode))"
      condition_a.push(against_condition)
      params_a.push(against_param)
    end

    order_cond = nil
    case @sort
    when '0' #指定なし
      # order_cond = movies[:upload_at].desc
      order_cond = "upload_at"
    when '1' #再生数
      # order_cond = movies[:playcount].desc
      order_cond = "playcount"
    when '2' #アルバム数
      # order_cond = movies[:albumcount].desc
      order_cond = "albumcount"
    when '3' #コメント数
      # order_cond = movies[:commentcount].desc
      order_cond = "commentcount"
    when '4' #再生時間
      # order_cond = movies[:playtime].desc
      order_cond = "playtime"
    end

    if @page.blank? then
      @page = 1
    else
      @page = @page.to_i
    end

    condition = ''
    if !condition_a.blank? then
      condition = "where #{condition_a.shift}"
      condition_a.each do |cond|
        condition = "#{condition} and #{cond}"
      end
    end
    # @total_num = movies_chain == nil ? Movie.order(order_cond).count : Movie.where(movies_chain).order(order_cond).count
    query = "select movies.id as id,movies.movieid as movieid, movies.title as title, movies.thumbnail as thumbnail, movies.url as url, movies.tags as tags, movies.playtime as playtime, movies.playcount as playcount, movies.albumcount as albumcount, movies.commentcount as commentcount, movies.user as user, movies.upload_at as upload_at from movies #{condition}"
    @total_num = Movie.find_by_sql([query].concat(params_a)).count
    @total_page = (@total_num.to_f/50.0).ceil

    if @total_page > 0 and (@page > @total_page) then
      flash.now[:alert] = {page: "ページは存在しません"}
      render 'index'
      return
    end

    offset = (@page - 1) * 50
    query = "#{query} order by #{order_cond} limit 50 offset #{offset}"
    # @movies = movies_chain == nil ? Movie.order(order_cond).limit(50).offset(offset) : Movie.where(movies_chain).order(order_cond).limit(50).offset(offset)
    @movies = Movie.find_by_sql([query].concat(params_a))


    @request_uri = request.fullpath.gsub(/\&page=\d*/,"")

    respond_to do |format|
      format.html # search.html.erb
    end
  end
end
