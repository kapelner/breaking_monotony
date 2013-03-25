# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def rounded_div(&block)
    options = {:radius => RoundedCorner::AlertRadius, :border_color => RoundedCorner::White, :interior_color => RoundedCorner::White}
    rounded_corner = RoundedCorner.generate_rounded_corner(options[:radius], options[:border_color], options[:interior_color])
    rounded_corner.generate_top_html(options[:padding]) + capture(&block) + rounded_corner.generate_bottom_html
  end

  #see http://flash-mp3-player.net/players/maxi/documentation/
  def mp3_pronunciation_player(file, autoplay = false)
    autoplay_text = autoplay ? "1" : "0"
    song_url = "/#{file}"    
    html = <<-ENDL
      <object id="pronunciation" width="25" height="20" data="/player_mp3_maxi.swf" type="application/x-shockwave-flash">
        <param value="/player_mp3_maxi.swf" name="movie"/>
        <param value="mp3=#{song_url}&amp;showslider=0&amp;width=25&amp;autoplay=#{autoplay_text}" name="FlashVars"/>
      </object>
    ENDL
    html.html_safe
  end
  
end
