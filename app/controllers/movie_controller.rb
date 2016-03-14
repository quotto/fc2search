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

    condition_a = Array.new
    params_a = Array.new
    if !@playtime.blank? then
      condition_a.push("movies.playtime >= ?")
      params_a.push(@playtime.to_i * 60)
    end

    if !@user.blank? then
      @user.delete('')
      if @user.size > 0 then
        user_condition = Array.new(@user.size, '?').join(',')
        user_condition = "(movies.user not in(#{user_condition}))"
        condition_a.push(user_condition)
        params_a.concat(@user)
      end
    end

    if !@keyword.blank? then
      keyword_a = @keyword.split(' ')
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
      order_cond = "upload_at desc"
    when '1' #再生数
      order_cond = "playcount desc"
    when '2' #アルバム数
      order_cond = "albumcount desc"
    when '3' #コメント数
      order_cond = "commentcount desc"
    when '4' #再生時間
      order_cond = "playtime desc"
    end

    if @page.blank? then
      @page = 1
    else
      @page = @page.to_i
    end

    condition = ''
    if !condition_a.blank? then
      condition = condition_a.shift
      condition_a.each do |cond|
        condition = "#{condition} and #{cond}"
      end
    end

    @total_num = condition.blank? ? Movie.all.count : Movie.where(condition,*params_a).count
    @total_page = (@total_num.to_f/50.0).ceil

    if @total_page > 0 and (@page > @total_page) then
      flash.now[:alert] = {page: "ページは存在しません"}
      render 'index'
      return
    end

    offset = (@page - 1) * 50
    @movies = condition.blank? ? Movie.all.order(order_cond).limit(50).offset(offset) : Movie.where(condition,*params_a).order(order_cond).limit(50).offset(offset)


    @request_uri = request.fullpath.gsub(/\&page=\d*/,"")

    respond_to do |format|
      format.html # search.html.erb
    end
  end
end
