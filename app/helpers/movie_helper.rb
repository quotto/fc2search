module MovieHelper
  def search_validate(params)
    return false if !valid_playtime(params[:playtime])
    return true
  end

  def valid_playtime(playtime)
    if !playtime.blank? then
      begin
        playtime.to_i 
      rescue
        puts "exception"
        flash.now[:alert] = {playtime: "再生時間は1から999の間で入力してください"}
        return false
      end

      if playtime.to_i < 1 or playtime.to_i > 999 then
        puts "range error"
        flash.now[:alert] = {playtime: "再生時間は1から999の間で入力してください"}
        return false
      end
    end
    return true
  end
end
