using Toybox.Application as App;
using Toybox.System as System;
using Toybox.Background as BackGrnd;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;

class JBWatchApp extends App.AppBase {

var isDebug=false;
var view=null;
var delegate=null;
var menu=null;

static var eventName=null;
static var eventDate=null;
static var showEvent=false;
static var faceForegroundColor=null;
static var faceBackgroundColor=null;
static var ringColor=null;
static var handColor=null;
static var hourDotsColor=null;
static var monthDotsColor=null;
static var sleepColor=null;
static var springColor=null;
static var summerColor=null;
static var autumnColor=null;
static var winterColor=null;
static var sleepStart=22;
static var sleepEnd=6;

static var showMinutes=false;
static var showSeason=false;
static var showMonth=false;
static var showRings=true;
static var showDate=true;

static var hourStyle=null;

static var enableNightScreen=true;
static var anyMessage="";
static var chartData=null;
static var receiveAnyMessage=false;
static var messageURL=null;

static var sleepStartTime=null;
static var sleepEndTime=null;

   function initialize() {
      AppBase.initialize();
      readConfig();
      calcSleepTime();
  	  if (isDebug) {  System.println("JBWatchApp.initialize"); }
   }

    function onStart(state) {
  		if (isDebug) {  System.println("JBWatchApp.onStart"); }
    }

    function onStop(state) {
   		if (isDebug) {  System.println("JBWatchApp.onStop"); }
    }

    function onSettingsChanged() {
    if (isDebug) {  System.println("JBWatchApp.onSettingsChanged"); }
        readConfig();
        Ui.requestUpdate();
    }

    function getInitialView() {
    	if (isDebug) {  System.println("JBWatchApp.getInitialView"); }
      	if (view == null ) {
        	view=new JBWatchView();
     	}
 		return [view];
    }
    
    function getServiceDelegate() {  
    	if (isDebug) {  System.println("JBWatchApp.getServiceDelegate"); }
		if (delegate == null) {
	   		delegate = new JBWatchDelegate();
		}
		return [delegate];    
    }
    
   function onBackgroundData(data) {
 	if (isDebug) {	System.println("JBWatchApp.onBackgroundData"+data); }
 	anyMessage=data.get("message");
 	chartData=data.get("data");
 	Ui.requestUpdate();
    }
    
  function readConfig() {

     try {
     App.Properties.setValue("deviceId",System.getDeviceSettings().uniqueIdentifier);
     } catch (e) {} 
     var defaultColor=App.Properties.getValue("defaultColor");
     if (defaultColor) {
     	resetColors();
     } 
     receiveAnyMessage=App.Properties.getValue("receiveAnyMessage");
     messageURL=App.Properties.getValue("messageURL");
     eventName=Application.Properties.getValue("eventName");
     eventDate=Application.Properties.getValue("eventDate");
     showEvent=Application.Properties.getValue("showEvent");
     faceForegroundColor=App.Properties.getValue("faceForegroundColor");
     faceBackgroundColor=App.Properties.getValue("faceBackgroundColor");
     ringColor=App.Properties.getValue("ringColor");
     handColor=App.Properties.getValue("handColor");
     hourDotsColor=App.Properties.getValue("hourDotsColor");
     monthDotsColor=App.Properties.getValue("monthDotsColor");
     sleepColor=App.Properties.getValue("sleepColor");
     
     springColor=App.Properties.getValue("springColor");
     summerColor=App.Properties.getValue("summerColor");
     autumnColor=App.Properties.getValue("autumnColor");
     winterColor=App.Properties.getValue("winterColor");
         
     sleepStart=App.Properties.getValue("sleepStart");
     sleepEnd=App.Properties.getValue("sleepEnd");
     if (sleepStart<0 || sleepStart >24 || sleepEnd<0 || sleepEnd >24 ) {
 		sleepStart=22;
		sleepEnd=6;
      } 
      
      showRings=App.Properties.getValue("showRings");
      showDate=App.Properties.getValue("showDate");
      showMinutes=App.Properties.getValue("showMinutes");
      showMonth=App.Properties.getValue("showMonth");
      showSeason=App.Properties.getValue("showSeason");
      
      hourStyle=(App.Properties.getValue("hourStyle")==1 ? "dots" : "lines");
      enableNightScreen=App.Properties.getValue("enableNightScreen");
      
      anyMessage=App.Properties.getValue("anyMessage");
               
  }
  function resetColors() {
     try {
      	App.Properties.setValue("faceForegroundColor",0xFFFFFF);
     	App.Properties.setValue("faceBackgroundColor",0x000000);
     	App.Properties.setValue("ringColor",0xFFFFFF);
     	App.Properties.setValue("handColor",0xFFFFFF);
     	App.Properties.setValue("hourDotsColor",0xFFFFFF);
     	App.Properties.setValue("monthDotsColor",0xFFFFFF);
     	App.Properties.setValue("sleepColor",0xFF0000);
     	
     	App.Properties.setValue("springColor",0x00FF00);
     	App.Properties.setValue("summerColor",0xFF0000);
     	App.Properties.setValue("autumnColor",0xFF5500);
     	App.Properties.setValue("winterColor",0xFFFFFF);
     } catch (ex) {} 
     	    	    	    	    	
  }
  
  static function calcSleepTime() {
  	if (isDebug) {  System.println("JBWatchApp.calcSleepTime"); }  
  	try {
       sleepStartTime=new Time.Moment(Time.today().value()+(JBWatchApp.sleepStart)*3600);
       var sleepHours=0;
       var dayShift=true;
       if (JBWatchApp.sleepStart>JBWatchApp.sleepEnd ) {
         sleepHours=24-JBWatchApp.sleepStart+JBWatchApp.sleepEnd;
       } else {
         sleepHours=JBWatchApp.sleepEnd-JBWatchApp.sleepStart;
         dayShift=false;
       } 
       sleepEndTime=sleepStartTime.add(new Time.Duration(sleepHours*3600));
       if ( dayShift && sleepEndTime.value()>Time.now().value()+24*3600 ) {
          sleepStartTime=sleepStartTime.subtract(new Time.Duration(24*3600));
          sleepEndTime  =sleepEndTime.subtract(new Time.Duration(24*3600));
       }
     } catch (ex) {}
        
  }
   

}
