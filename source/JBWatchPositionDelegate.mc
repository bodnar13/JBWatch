using Toybox.System;
using Toybox.Background;
using Toybox.Communications;
using Toybox.Time;
using Toybox.WatchUi as Ui;
using Toybox.Position;

 (:background)
class JBWatchPositionDelegate extends System.ServiceDelegate {

var isDebug=false;
static var device=null;
var connected=false;


	function initialize() {
  		ServiceDelegate.initialize();
  		device = System.getDeviceSettings();
  		Background.registerForTemporalEvent(new Time.Duration(3600));
   		if (isDebug) {  System.println("Position ServiceDelegate.initialize"); }
	}

	function onTemporalEvent() {
		if (isDebug) {  System.println("Position onTemporalEvent"); }
		if (JBWatchApp.showSunrise  ) {
			var data = {
				"position" => Position.getInfo().position.toDegrees()
			};
			Background.exit(data);
		   
		}

	}
	
	function onWakeTime() {
		if (isDebug) {  System.println("Position onWakeTime"); }
	}
	
	function onActivityCompleted(activity) {
		if (isDebug) {  System.println("Position activity:"+activity); }

	}

    
}
