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
    Background.registerForTemporalEvent(new Time.Duration(21600));
     if (logLevel > 2) {
      System.println("Position ServiceDelegate.initialize"); 
    }
  }

  function onTemporalEvent() {
    if (logLevel > 2) { 
      System.println("Position onTemporalEvent"); 
    }
    if (JBWatchApp.showSunrise  ) {
      var data = {
        "position" => Position.getInfo().position.toDegrees()
      };
      Background.exit(data);
       
    }
  }
  
  function onWakeTime() {
    if (logLevel > 2) {
      System.println("Position onWakeTime"); 
    }
  }
  
  function onActivityCompleted(activity) {
    if (logLevel > 2) {
      System.println("Position activity:"+activity);
    }
  }

    
}
