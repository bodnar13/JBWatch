using Toybox.Application as App;
using Toybox.System as System;
using Toybox.Background as BackGrnd;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;

class JBWatchApp extends App.AppBase {

  var isDebug = false;
  var view = null;
  var delegate = null;
  var positionDelegate = null;
  var delegates= [];
  var menu = null;

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
  static var showSunrise=false;
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

  static var dayLightCalc=[];

  function initialize() {
    AppBase.initialize();
    readConfig();
    calcSleepTime();
    initPosInfo();
  	if (isDebug) {
      System.println("JBWatchApp.initialize"); 
    }
  }

  function onStart(state) {
    if (isDebug) {
      System.println("JBWatchApp.onStart");
    }
  }

  function onStop(state) {
    if (isDebug) {
      System.println("JBWatchApp.onStop");
    }
  }

  function onSettingsChanged() {
    if (isDebug) {  System.println("JBWatchApp.onSettingsChanged"); }
      readConfig();
        Ui.requestUpdate();
    }

    function getInitialView() {
      if (isDebug) {
        System.println("JBWatchApp.getInitialView"); 
      }
      if (view == null ) {
        view=new JBWatchView();
     	}
 		  return [view];
    }
    
    function getServiceDelegate() {  
		  if (delegates.size() == 0 ) {
        if (JBWatchApp.receiveAnyMessage) {
	   	    delegate = new JBWatchDelegate();
          delegates.add(delegate);
        }
        if (JBWatchApp.showSunrise) {
          positionDelegate = new JBWatchPositionDelegate();
          delegates.add(positionDelegate);
        }
      }
      if (isDebug) {
        System.println("JBWatchApp.getServiceDelegate" + delegates);
      }
		  return delegates;    
    }
    
    function onBackgroundData(data) {
 	    if (isDebug) {
        System.println("JBWatchApp.onBackgroundData"+data);
      }
      if (data.get("position") != null) {
        dayLight(data.get("position"));
      }
      if (data.get("message") != null) {
 	      anyMessage=data.get("message");
 	      chartData=data.get("data");
      }
 	    Ui.requestUpdate();
    }
    
    function readConfig() {
      try {
        App.Properties.setValue("deviceId",System.getDeviceSettings().uniqueIdentifier);
      } catch (e) {
      } 
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
      showSunrise=App.Properties.getValue("showSunrise");
      
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
      } catch (ex) {
      } 
     	    	    	    	    	
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
      } catch (ex) {
      }
        
  }

  function dayLight(location) {
    var year = Time.Gregorian.info(Time.now(),Time.FORMAT_SHORT).year;
    var month = Time.Gregorian.info(Time.now(),Time.FORMAT_SHORT).month;
    var day = Time.Gregorian.info(Time.now(),Time.FORMAT_SHORT).day;
    var timezone = Time.Gregorian.info(Time.now(),Time.FORMAT_SHORT).hour-Time.Gregorian.utcInfo(Time.now(),Time.FORMAT_SHORT).hour;
    var latitude = location[0];
    var longitude = location[1];
    var zenith = 90.833333;
      /* other options
        var zenith_civil = 96;
        var zenith_nautical = 102;
        var zenith_astronomical = 108;
      */
      var rising = true;
      var dayLightSaving = 0; // included in timezone 
      if(isDebug) {
        System.println("Timezone: " + timezone);
        System.println("Position :" + location);
      }
      var dayLightTimes = calcSunTime(rising, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving);
      dayLightCalc=dayLightTimes;
  }

  function calcSunTime(rising, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving) {
    var dayLightCalcInfo = {};
    if (isDebug) {
      System.println("{\ninput: {");
      System.println(
          "  rising: " + rising + "\n"
          + "  year: " + year + "\n"
          + "  month: " + month + "\n"
          + "  day: " + day + "\n"
          + "  latitude: " + latitude + "\n"
          + "  longitude: " + longitude + "\n"
          + "  zenith: " + zenith + "\n"
          + "  timezone: " + timezone + "\n"
          + "  dayLightSaving: " + dayLightSaving + "\n"
      );
      System.println("}");
    }

    // 1. calculate the day of the year

    var N1 = Math.floor(275 * month / 9);
    var N2 = Math.floor((month + 9) / 12);
    var N3 = (1 + Math.floor((year - 4 * Math.floor(year / 4) + 2) / 3));
    var dayOfTherYear = N1 - (N2 * N3) + day - 30;
    
    dayLightCalcInfo.put("1. dayOfTherYear",dayOfTherYear);

    // 2. convert the longitude to hour value and calculate an approximate time (days and time)

    var lngHour = longitude / 15;
    var approxTime;
    if (rising) {
        approxTime = dayOfTherYear + ((6 - lngHour) / 24);
    } else {
        approxTime = dayOfTherYear + ((18 - lngHour) / 24);
    }
    
    dayLightCalcInfo.put("2. approxTime",approxTime);

    // 3. calculate the Sun's mean anomaly (degree)

    var meanAnomaly = (0.9856 * approxTime) - 3.289;

    dayLightCalcInfo.put("3. meanAnomaly",meanAnomaly);
    
    // 4. calculate the Sun's true longitude

    var trueLongitude = meanAnomaly
        + (1.916 * Math.sin(dToR(meanAnomaly)))
        + (0.020 * Math.sin(dToR(2 * meanAnomaly)))
        + 282.634;

    trueLongitude = toRange(trueLongitude, 360);

    dayLightCalcInfo.put("4. trueLongitude",trueLongitude);

    // 5a.calculate the Sun's right ascension

    var rightAscension = rToD(Math.atan(0.91764 * Math.tan(dToR(trueLongitude))));
    //rightAscension = toRange(rightAscension,360);
  
    // 5b.right ascension value needs to be in the same quadrant as trueLongitude

    var Lquadrant = (Math.floor(trueLongitude / 90)) * 90;
    var RAquadrant = (Math.floor(rightAscension / 90)) * 90;
    rightAscension = rightAscension + (Lquadrant - RAquadrant);

    // 5c.right ascension value needs to be converted into hours

    rightAscension = rightAscension / 15;

    dayLightCalcInfo.put("5. rightAscension",rightAscension);

    // 6. calculate the Sun's declination

    var sinDec = 0.39782 * Math.sin(dToR(trueLongitude));
    var cosDec = Math.cos(Math.asin(sinDec));

    dayLightCalcInfo.put("6. sinDec",sinDec);
    dayLightCalcInfo.put("6. cosDec",cosDec);

    // 7a.calculate the Sun's local hour angle

    var cosLocalHourAngle = (Math.cos(dToR(zenith)) - (sinDec * Math.sin(dToR(latitude)))) / (cosDec * Math.cos(dToR(latitude)));

    if (cosLocalHourAngle > 1) {
        // the sun never rises on this location(on the specified date)
    }
    if (cosLocalHourAngle < -1) {
        // the sun never sets on this location(on the specified date)
    }

    // 7b. finish calculating hour angle and convert into hours

    var hourAngle;
    if (rising) {
        hourAngle = 360 - rToD(Math.acos(cosLocalHourAngle));
    } else {
        hourAngle = rToD(Math.acos(cosLocalHourAngle));
    }

    hourAngle = hourAngle / 15;

    dayLightCalcInfo.put("7. hourAngle",hourAngle);

    // 8. calculate local mean time of rising / setting

    var localMeanTime = hourAngle + rightAscension - (0.06571 * approxTime) - 6.622;

    dayLightCalcInfo.put("8. localMeanTime",localMeanTime);

    //9. adjust back to UTC

    var UTC = localMeanTime - lngHour;
    //NOTE: UT potentially needs to be adjusted into the range[0, 24) by adding / subtracting 24
    UTC = toRange(UTC, 24);
  
    dayLightCalcInfo.put("9. UTC",UTC);

    // 10. convert UT value to local time zone of latitude / longitude

    var localTime = UTC + timezone + dayLightSaving;
    var localHour = Math.floor(localTime).toLong();
    var localMinutes = Math.floor((localTime - localHour) * 60).toLong();
    var localClockTime = localHour + localMinutes.toFloat() / 100;

    dayLightCalcInfo.put("10. localClockTime",localClockTime);
    
    if (isDebug) {   
      var keys = dayLightCalcInfo.keys();
      System.println("calc : {");
      for ( var i =0 ; i<keys.size(); i ++) {
        System.println("  " + keys[i] + ":" + dayLightCalcInfo.get(keys[i]));
      }
      System.println("  }\n}");    
    }

    if (rising) {
        var sunSetAt = calcSunTime(false, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving);
        return [[localHour,localMinutes],sunSetAt] ; // { sunRise: clockTime, sunSet: sunSetAt }
    } else {
        return [localHour,localMinutes];
    }
  }

  function dToR(degree) {
    return degree / 180 * Math.PI;
  }
  function rToD(radians) {
    return radians / Math.PI * 180;
  }
  function toRange(val, maxVal) {
    if (val < 0) { val += maxVal; }
    if (val > maxVal) { val -= maxVal; }
    return val;
  }
  function initPosInfo(){
    dayLight(Position.getInfo().position.toDegrees());
  }
}
