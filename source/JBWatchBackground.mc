import Toybox.WatchUi;

class JBWatchBackground extends Drawable {

  function initialize() {
    var dictionary = {
      :identifier => "Background"
    };
    Drawable.initialize(dictionary);
  }

  function draw(dc) {
    dc.setColor(faceForegroundColor, faceBackgroundColor);
    dc.clear();    
  }

}
