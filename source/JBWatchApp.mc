using Toybox.Application as App;
using Toybox.System as System;
using Toybox.Background as BackGrnd;
using Toybox.Time as Time;
using Toybox.WatchUi as Ui;

class JBWatchApp extends App.AppBase {

  var logLevel = 2; 
  var view = null;
  var delegate = null;
  var positionDelegate = null;
  var delegates= [];
  var menu = null;

  static var eventName = null;
  static var eventDate = null;
  static var showEvent = false;
  static var faceForegroundColor = null;
  static var faceBackgroundColor = null;
  static var ringColor = null;
  static var handColor = null;
  static var hourDotsColor = null;
  static var monthDotsColor = null;
  static var sleepColor = null;
  static var springColor = null;
  static var summerColor = null;
  static var autumnColor = null;
  static var winterColor = null;
  static var sleepStart = 22;
  static var sleepEnd = 6;

  static var showMinutes = false;
  static var showSeason = false;
  static var showSunrise = false;
  static var showMonth = false;
  static var showRings = true;
  static var showDate = true;

  static var hourStyle = null;

  static var enableNightScreen = true;
  static var messageURL = null;

  static var sleepStartTime = null;
  static var sleepEndTime = null;

  static var dayLightCalc = [];
  static var equinoxAndSolstice = [];
  static var anyMessage = null;

  function initialize() {
    AppBase.initialize();
    readConfig();
    calcSleepTime();
    initPosInfo();
    equinoxAndSolstice.add(getEquinoxAndSolstice(0));
    equinoxAndSolstice.add(getEquinoxAndSolstice(1));
    equinoxAndSolstice.add(getEquinoxAndSolstice(2));
    equinoxAndSolstice.add(getEquinoxAndSolstice(3));
    if (logLevel > 2) {
      System.println("JBWatchApp.initialize"); 
    }
  }

  function onStart(state) {
    if (logLevel > 2) {
      System.println("JBWatchApp.onStart");
    }
  }

  function onStop(state) {
    if (logLevel > 2) {
      System.println("JBWatchApp.onStop");
    }
  }

  function onSettingsChanged() {
    if (logLevel > 2) {  System.println("JBWatchApp.onSettingsChanged"); }
      readConfig();
        Ui.requestUpdate();
    }

    function getInitialView() {
      if (logLevel > 2) {
        System.println("JBWatchApp.getInitialView"); 
      }
      if (view == null ) {
        view=new JBWatchView();
       }
       return [view];
    }
    
    function getServiceDelegate() {  
      if (delegates.size() == 0 ) {
        if (JBWatchApp.showSunrise) {
          positionDelegate = new JBWatchPositionDelegate();
          delegates.add(positionDelegate);
        }
      }
      if (logLevel > 2) {
        System.println("JBWatchApp.getServiceDelegate" + delegates);
      }
      return delegates;    
    }
    
    function onBackgroundData(data) {
       if (logLevel > 2) {
        System.println("JBWatchApp.onBackgroundData"+data);
      }
      if (data.get("position") != null) {
        dayLight(data.get("position"));
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
      eventName = Application.Properties.getValue("eventName");
      eventDate = Application.Properties.getValue("eventDate");
      showEvent = Application.Properties.getValue("showEvent");
      faceForegroundColor = App.Properties.getValue("faceForegroundColor");
      faceBackgroundColor = App.Properties.getValue("faceBackgroundColor");
      ringColor = App.Properties.getValue("ringColor");
      handColor = App.Properties.getValue("handColor");
      hourDotsColor = App.Properties.getValue("hourDotsColor");
      monthDotsColor = App.Properties.getValue("monthDotsColor");
      sleepColor = App.Properties.getValue("sleepColor");
     
      springColor = App.Properties.getValue("springColor");
      summerColor = App.Properties.getValue("summerColor");
      autumnColor = App.Properties.getValue("autumnColor");
      winterColor = App.Properties.getValue("winterColor");
         
      sleepStart = App.Properties.getValue("sleepStart");
      sleepEnd = App.Properties.getValue("sleepEnd");
      if (sleepStart <0 || sleepStart >24 || sleepEnd <0 || sleepEnd >24) {
         sleepStart = 22;
        sleepEnd = 6;
      } 
      showRings = App.Properties.getValue("showRings");
      showDate = App.Properties.getValue("showDate");
      showMinutes = App.Properties.getValue("showMinutes");
      showMonth = App.Properties.getValue("showMonth");
      showSeason = App.Properties.getValue("showSeason");
      showSunrise = App.Properties.getValue("showSunrise");
      
      hourStyle = (App.Properties.getValue("hourStyle")==1 ? "dots" : "lines");
      enableNightScreen = App.Properties.getValue("enableNightScreen");
    }
  
    function resetColors() {
      try {
        App.Properties.setValue("faceForegroundColor", 0xFFFFFF);
         App.Properties.setValue("faceBackgroundColor", 0x000000);
         App.Properties.setValue("ringColor", 0xFFFFFF);
         App.Properties.setValue("handColor", 0xFFFFFF);
         App.Properties.setValue("hourDotsColor", 0xFFFFFF);
         App.Properties.setValue("monthDotsColor", 0xFFFFFF);
         App.Properties.setValue("sleepColor", 0xFF0000);
       
         App.Properties.setValue("springColor", 0x00FF00);
         App.Properties.setValue("summerColor", 0xFF0000);
         App.Properties.setValue("autumnColor", 0xFF5500);
         App.Properties.setValue("winterColor", 0xFFFFFF);
      } catch (ex) {
      } 
                               
  }
  
  static function calcSleepTime() {
    if (logLevel > 2) {  
      System.println("JBWatchApp.calcSleepTime"); 
    }  
    try {
      sleepStartTime = new Time.Moment(Time.today().value() + (JBWatchApp.sleepStart) * 3600);
      var sleepHours = 0;
      var dayShift = true;
      if (JBWatchApp.sleepStart > JBWatchApp.sleepEnd ) {
        sleepHours = 24 - JBWatchApp.sleepStart + JBWatchApp.sleepEnd;
      } else {
        sleepHours = JBWatchApp.sleepEnd - JBWatchApp.sleepStart;
        dayShift = false;
      } 
      sleepEndTime = sleepStartTime.add(new Time.Duration(sleepHours * 3600));
      if ( dayShift && sleepEndTime.value() > Time.now().value() + 24 * 3600 ) {
        sleepStartTime = sleepStartTime.subtract(new Time.Duration(24 * 3600));
        sleepEndTime  = sleepEndTime.subtract(new Time.Duration(24 * 3600));
      }
      } catch (ex) {
      }
        
  }

  function dayLight(location) {
    var year = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;
    var month = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).month;
    var day = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;
    var timezone = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).hour - Time.Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT).hour;
    var latitude = location[0];
    var longitude = location[1];
    var zenith = 90.833333;
      /* other options
        var zenith_civil = 96;
        var zenith_nautical = 102;
        var zenith_astronomical = 108;
      */
    var dayLightSaving = 0; // included in timezone 
    if(logLevel > 2) {
      System.println("Timezone: " + timezone);
      System.println("Position :" + location);
    }
    var sunRiseTimes = calcSunTime(true, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving);
    var sunSetTimes = calcSunTime(false, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving);
    dayLightCalc = [];
    dayLightCalc.add(sunRiseTimes);
    dayLightCalc.add(sunSetTimes);
  }

  function calcSunTime(rising, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving) {
    var info = {};
    if (logLevel > 2) {
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
    
    info.put("1. dayOfTherYear", dayOfTherYear);

    // 2. convert the longitude to hour value and calculate an approximate time (days and time)

    var lngHour = longitude / 15;
    var approxTime;
    if (rising) {
        approxTime = dayOfTherYear + ((6 - lngHour) / 24);
    } else {
        approxTime = dayOfTherYear + ((18 - lngHour) / 24);
    }
    
    info.put("2. approxTime",approxTime);

    // 3. calculate the Sun's mean anomaly (degree)

    var meanAnomaly = (0.9856 * approxTime) - 3.289;

    info.put("3. meanAnomaly", meanAnomaly);
    
    // 4. calculate the Sun's true longitude

    var trueLongitude = meanAnomaly
        + (1.916 * Math.sin( dToR(meanAnomaly) ))
        + (0.020 * Math.sin( dToR(2 * meanAnomaly) ))
        + 282.634;

    trueLongitude = toRange(trueLongitude, 360);

    info.put("4. trueLongitude", trueLongitude);

    // 5a.calculate the Sun's right ascension

    var rightAscension = rToD(Math.atan(0.91764 * Math.tan( dToR(trueLongitude) )));
    //rightAscension = toRange(rightAscension,360);
  
    // 5b.right ascension value needs to be in the same quadrant as trueLongitude

    var Lquadrant = (Math.floor(trueLongitude / 90)) * 90;
    var RAquadrant = (Math.floor(rightAscension / 90)) * 90;
    rightAscension = rightAscension + (Lquadrant - RAquadrant);

    // 5c.right ascension value needs to be converted into hours

    rightAscension = rightAscension / 15;

    info.put("5. rightAscension", rightAscension);

    // 6. calculate the Sun's declination

    var sinDec = 0.39782 * Math.sin( dToR(trueLongitude) );
    var cosDec = Math.cos(Math.asin(sinDec));

    info.put("6. sinDec", sinDec);
    info.put("6. cosDec", cosDec);

    // 7a.calculate the Sun's local hour angle

    var cosLocalHourAngle = (Math.cos( dToR(zenith) ) - (sinDec * Math.sin( dToR(latitude) ))) / (cosDec * Math.cos( dToR(latitude) ));

    if (cosLocalHourAngle > 1) {
        // the sun never rises on this location(on the specified date)
    }
    if (cosLocalHourAngle < -1) {
        // the sun never sets on this location(on the specified date)
    }

    // 7b. finish calculating hour angle and convert into hours

    var hourAngle;
    if (rising) {
        hourAngle = 360 - rToD( Math.acos(cosLocalHourAngle) );
    } else {
        hourAngle = rToD( Math.acos(cosLocalHourAngle) );
    }

    hourAngle = hourAngle / 15;

    info.put("7. hourAngle", hourAngle);

    // 8. calculate local mean time of rising / setting

    var localMeanTime = hourAngle + rightAscension - (0.06571 * approxTime) - 6.622;

    info.put("8. localMeanTime", localMeanTime);

    //9. adjust back to UTC

    var UTC = localMeanTime - lngHour;
    //NOTE: UT potentially needs to be adjusted into the range[0, 24) by adding / subtracting 24
    UTC = toRange(UTC, 24);
  
    info.put("9. UTC", UTC);

    // 10. convert UT value to local time zone of latitude / longitude

    var localTime = UTC + timezone + dayLightSaving;
    var localHour = Math.floor(localTime).toLong();
    var localMinutes = Math.floor((localTime - localHour) * 60).toLong();
    var localClockTime = localHour + localMinutes.toFloat() / 100;

    info.put("10. localClockTime", localClockTime);
    
    if (logLevel > 2) {   
      var keys = info.keys();
      System.println("calc : {");
      for ( var i = 0 ; i < keys.size(); i ++) {
        System.println("  " + keys[i] + ":" + info.get(keys[i]));
      }
      System.println("  }\n}");    
    }
    return [localHour, localMinutes];
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
    dayLight( Position.getInfo().position.toDegrees() );
  }

  function getEquinoxAndSolstice(eventNr) {
    var info = {};
    var thisYear = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT).year;
    var Y = (thisYear - 2000) / 1000.0;
  
    var JDEMarch  = 2451623.80984d + 365242.37404 * Y + 0.05169 * Math.pow(Y, 2) - 0.00411 * Math.pow(Y, 3) - 0.00057 * Math.pow(Y, 4);
    var JDEJune   = 2451716.56767d + 365241.62603 * Y + 0.00325 * Math.pow(Y, 2) + 0.00888 * Math.pow(Y, 3) - 0.00030 * Math.pow(Y, 4);
    var JDESept   = 2451810.21715d + 365242.01767 * Y - 0.11575 * Math.pow(Y, 2) + 0.00337 * Math.pow(Y, 3) + 0.00078 * Math.pow(Y, 4);
    var JDEDec    = 2451900.05952d + 365242.74049 * Y - 0.06223 * Math.pow(Y, 2) - 0.00823 * Math.pow(Y, 3) + 0.00032 * Math.pow(Y, 4);
    var eventJDE = [JDEMarch, JDEJune, JDESept, JDEDec];

    var JDE0 = eventJDE[eventNr];
 
    var T = (JDE0 - 2451545.0) / 36525;
    var W = 35999.373 * T - 2.47;
    var deltaLambda = 1 + 0.0334d * Math.cos( dToR(W) ) + 0.0007 * Math.cos( dToR(2 * W) );

    var sElements=[
      [485, 324.96, 1934.136], 
      [203, 337.23, 32964.467],
      [199, 342.08, 20.186],
      [182, 27.85, 445267.112],
      [156, 73.14, 45036.886],
      [136, 171.52, 22518.443],
      [77, 222.54, 65928.934],
      [74, 296.72, 3034.906],
      [70, 243.58, 9037.513],
      [58, 119.81, 33718.147],
      [52, 297.17, 150.678],
      [50, 21.02, 2281.226],
      [45, 247.54, 29929.562],
      [44, 325.15, 31555.956],
      [29, 60.93, 4443.417],
      [18, 155.12, 67555.328],
      [17, 288.79, 4562,452],
      [16, 198.04, 62894.029],
      [14, 199.76, 31436.921],
      [12, 95.39, 14577.848],
      [12, 287.11, 31931.756],
      [12, 320.81, 34777.259],
      [9, 227.73, 1222.114],
      [8, 15.45, 16859.074]
    ];

    var S = 0;
    for (var i = 0; i < sElements.size(); i++) {
       S = S + sElements[i][0] * Math.cos( dToR(sElements[i][1] + sElements[i][2] * T) );
    }
    S = Math.floor(S);

    var JDE = JDE0 + 0.00001d * S / deltaLambda;
    var equinoxOrSolstice=jdeToDate(JDE);
    if (logLevel > 2) {
      info.put("Y", Y);
      info.put("JDE0", JDE0);
      info.put("JDE", JDE);
      info.put("T", T);
      info.put("W", W);
      info.put("deltaLambda", deltaLambda);
      info.put("S", S);
      info.put("equinoxOrSolstice", equinoxOrSolstice);
      printInfo("equinoxOrSolstice", info);
    }
    return equinoxOrSolstice;
  }

  function jdeToDate(jde) {
    // jde = 2436116.31;
    // 1957 October 4.81.
    var info = {};
    var za = jde + 0.5d;
    var Z = Math.floor(za);
    var F = za - Z;
    var A;
    if (Z < 2299161) {
      A = Z;
    } else {
      var alfa = Math.floor((Z - 1867216.25d) / 36524.25);
      A = Z + 1 + alfa - Math.floor(alfa / 4);
    }
    var B = A + 1524;
    var C = Math.floor((B-122.1) / 365.25);
    var D = Math.floor(365.25 * C);
    var E = Math.floor((B - D) / 30.6001);
    var day = B - D - Math.floor(30.6001 * E) + F;
    var hour = (day - Math.floor(day)) * 24; 
    var minute = (hour - Math.floor(hour)) * 60;
    var month;
    if (E < 14) {
      month = E - 1;
    } else {
      month = E - 13;
    }
    var year;
    if ( month > 2) {
      year = C - 4716;
    } else {
      year = C - 4715;
    }
    month = month.toNumber();
    day = day.toNumber();
    hour = hour.toNumber();
    minute = minute.toNumber();

    if (logLevel > 2) {
        info.put("jde", jde);
        info.put("A", A);
        info.put("B", B);
        info.put("C" , C);
        info.put("D" , D);
        info.put("E", E);    
        info.put("F" , F);
        info.put("Z", Z);
        info.put("year", year);
        info.put("month", month);
        info.put("day", day);
        info.put("minute", minute);
        printInfo("jdeToDate",info); 
    }
    return [month, day, hour, minute];
  }

  function printInfo(tag, info){
    var keys = info.keys();
    System.println(tag + ": {");
    for ( var i =0 ; i<keys.size(); i ++) {
      System.println("  " + keys[i] + ":" + info.get(keys[i]));
    }
    System.println("}\n}"); 
  }

}
