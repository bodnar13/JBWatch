import Toybox.System;
import Toybox.Background;
import Toybox.Time;
import Toybox.Position;

(:background)
class JBWatchPositionDelegate extends ServiceDelegate {

var logLevel = 2;
static var device=null;
var connected=false;

  function initialize() {
    ServiceDelegate.initialize();
    device = System.getDeviceSettings();
    Background.registerForTemporalEvent(new Duration(600));
  }

  function onTemporalEvent() {
    if (showSunrise) {
      var data = {
        "position" => Position.getInfo().position.toDegrees()
      };
      Background.exit(data);
       
    }
  }

  
  function onWakeTime() {

  }
  
  function onActivityCompleted(activity) {

  }

    
}
