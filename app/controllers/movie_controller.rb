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
    tags = Tag.arel_table

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
    playtime_cond = nil
    if !@playtime.blank? then
      playtime_cond = movies[:playtime].gteq(@playtime.to_i * 60)
      movies_chain = movies_chain.blank? ? playtime_cond : movies_chain.and(playtime_cond)
    end

    user_cond = nil
    if !@user.blank? then
      @user.delete('')
      if @user.size > 0 then
        user_cond = movies[:user].not_in(@user)
        movies_chain = movies_chain.blank? ? user_cond : movies_chain.and(user_cond)
      end
    end

    keyword_cond = nil
    if !@keyword.blank? then
      keyword_cond = movies[:title].matches("%#{@keyword}%").or(tags.project(Arel.star).where(tags[:movieid].eq(movies[:movieid])).where(tags[:tag].matches("%#{@keyword}%")).exists)
      movies_chain = movies_chain.blank? ? keyword_cond : movies_chain.and(keyword_cond)
      puts movies_chain.to_sql
    end

    order_cond = nil
    case @sort
    when '0' #指定なし
      order_cond = movies[:upload_at].desc
    when '1' #再生数
      order_cond = movies[:playcount].desc
    when '2' #アルバム数
      order_cond = movies[:albumcount].desc
    when '3' #コメント数
      order_cond = movies[:commentcount].desc
    when '4' #再生時間
      order_cond = movies[:playtime].desc
    end

    if @page.blank? then
      @page = 1
    else
      @page = @page.to_i
    end

    # @movies = Movie.where(keyword_cond).where(playtime_cond).where(scope_cond).where(user_cond).order(order_cond).all
    # Movie.where(keyword_cond).to_sql
    @movies = movies_chain == nil ? Movie.order(order_cond).all : Movie.where(movies_chain).order(order_cond).all
    
    @total_num = @movies.size
    @total_page = (@total_num.to_f/50.0).ceil

    if @total_page > 0 and (@page > @total_page) then
      flash.now[:alert] = {page: "ページは存在しません"}
      render 'index'
      return
    end

    skip_num = (@page - 1) * 50
    limit_num = @total_num < (@page * 50) ? @total_num : @page * 50

    @movies = @movies.to_a.slice(skip_num..(limit_num - 1))
    @request_uri = request.fullpath.gsub(/\&page=\d*/,"")

    respond_to do |format|
      format.html # search.html.erb
    end
  end
end
