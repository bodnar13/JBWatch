using Toybox.System;
using Toybox.Background;
using Toybox.Time;
using Toybox.WatchUi as Ui;
using Toybox.Position;

(:background)
class JBWatchPositionDelegate extends System.ServiceDelegate {

var logLevel = 2;
static var device=null;
var connected=false;

  function initialize() {
    ServiceDelegate.initialize();
    device = System.getDeviceSettings();
    Background.registerForTemporalEvent(new Time.Duration(600));
  }

  function onTemporalEvent() {
    if (JBWatchApp.showSunrise  ) {
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
