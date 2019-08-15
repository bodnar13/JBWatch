using Toybox.System;
using Toybox.Background;
using Toybox.Communications;
using Toybox.Time;
using Toybox.WatchUi as Ui;

 (:background)
class JBWatchDelegate extends System.ServiceDelegate {

var isDebug=false;
static var device=null;
var connected=false;


	function initialize() {
  		ServiceDelegate.initialize();
  		device = System.getDeviceSettings();
  		Background.registerForTemporalEvent(new Time.Duration(300));
   		if (isDebug) {  System.println("ServiceDelegate.initialize"); }
	}

	function onTemporalEvent() {
		if (isDebug) {  System.println("onTemporalEvent"); }
		var connected=device.phoneConnected;
		if (JBWatchApp.receiveAnyMessage && connected ) {
		if (isDebug) {
		  System.println("onTemporalEvent :"+JBWatchApp.enableNightScreen);
		  System.println("onTemporalEvent :"+"start:"+JBWatchApp.sleepStartTime.value());
		  System.println("onTemporalEvent :"+"  end:"+JBWatchApp.sleepEndTime.value());
		  System.println("onTemporalEvent :"+"  now:"+Time.now().value());
		}
		  if (JBWatchApp.enableNightScreen && JBWatchApp.sleepStartTime != null && JBWatchApp.sleepEndTime != null && JBWatchApp.sleepStartTime.lessThan(Time.now())  && JBWatchApp.sleepEndTime.greaterThan(Time.now()) ) {
		     if (isDebug) {
		        System.println("onTemporalEvent :sleep time skip web call"); 
		     }
		    return;
		  } 
		  webCall();
		   
		}

	//	Background.exit(null);
	}
	
	function onWakeTime() {
		if (isDebug) {  System.println("onWakeTime"); }
	}
	
	function onActivityCompleted(activity) {
		if (isDebug) {  System.println("activity:"+activity); }
//		Background.exit(activity);
	}
	

	function webCall() {

       var url = JBWatchApp.messageURL;
       var params = {};

       var options = {                    
           :method       => Communications.HTTP_REQUEST_METHOD_GET ,      
           :headers      => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
       };
//       var endPoint=url+device.uniqueIdentifier;
       var endPoint=url;
       if (isDebug) {  System.println("endPoint:"+endPoint); }
       Communications.makeWebRequest(endPoint, params, options, method(:onWebCall));

    }
    
    function onWebCall(responseCode, data) {
        if (isDebug) {  System.println("responseCallback:"+responseCode); }
        if (isDebug) {  System.println("responseCallback:"+data); }
        Background.exit(data);
    }
      
    
    

    
}
