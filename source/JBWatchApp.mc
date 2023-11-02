import Toybox.Application;
import Toybox.System;
import Toybox.Time;
import Toybox.Position;
import Toybox.WatchUi;


// Configuration
var eventName = null;
var eventDate = null;
var showEvent = false;
var faceForegroundColor = null;
var faceBackgroundColor = null;
var ringColor = null;
var handColor = null;
var hourDotsColor = null;
var monthDotsColor = null;
var sleepColor = null;
var springColor = null;
var summerColor = null;
var autumnColor = null;
var winterColor = null;
var sleepStart = 22;
var sleepEnd = 6;

var showMinutes = false;
var showSeason = false;
var showSunrise = false;
var showMonth = false;
var showRings = true;
var showDate = true;

var hourStyle = null;

var enableNightScreen = true;

var sleepStartTime = null;
var sleepEndTime = null;

// Astronomy and other data
var astroData = null;

class JBWatchApp extends AppBase {

  const device = System.getDeviceSettings();
  const monkeyVersion = Lang.format("$1$.$2$$3$", device.monkeyVersion).toFloat();

  var logLevel = 2; 
  var view = null;
  var menu = null;



  var delegate = [];


  function initialize() {
    AppBase.initialize();
    readConfig();
    self.astroData = new AstroData();
    calcSleepTime();
  }
  
  function onStart(state) {
      calcAstroData(Position.getInfo().position.toDegrees());
  }

  function onStop(state) {
  }

  function onSettingsChanged() {
    readConfig();
    WatchUi.requestUpdate();
  }

    function getInitialView() {
      if (view == null ) {
        view=new JBWatchView();
      }
      return [view];
    }
    
    function getServiceDelegate() { 
      if (showSunrise && self.delegate.size() == 0) {
          self.delegate.add( new JBWatchPositionDelegate() );
      }
      return self.delegate;
    }
    
    function onBackgroundData(data) {
      if (data.get("position") != null) {
          calcAstroData(data.get("position"));
      }
       WatchUi.requestUpdate();
    }
    
    function readConfig() {
      try {
        Properties.setValue("deviceId",System.getDeviceSettings().uniqueIdentifier);
      } catch (e) {
      } 
      var defaultColor=Properties.getValue("defaultColor");
      if (defaultColor) {
         resetColors();
      } 
      eventName = Application.Properties.getValue("eventName");
      eventDate = Application.Properties.getValue("eventDate");
      showEvent = Application.Properties.getValue("showEvent");
      faceForegroundColor = Properties.getValue("faceForegroundColor");
      faceBackgroundColor = Properties.getValue("faceBackgroundColor");
      ringColor = Properties.getValue("ringColor");
      handColor = Properties.getValue("handColor");
      hourDotsColor = Properties.getValue("hourDotsColor");
      monthDotsColor = Properties.getValue("monthDotsColor");
      sleepColor = Properties.getValue("sleepColor");
     
      springColor = Properties.getValue("springColor");
      summerColor = Properties.getValue("summerColor");
      autumnColor = Properties.getValue("autumnColor");
      winterColor = Properties.getValue("winterColor");
         
      sleepStart = Properties.getValue("sleepStart");
      sleepEnd = Properties.getValue("sleepEnd");
      if (sleepStart <0 || sleepStart >24 || sleepEnd <0 || sleepEnd >24) {
         sleepStart = 22;
        sleepEnd = 6;
      } 
      showRings = Properties.getValue("showRings");
      showDate = Properties.getValue("showDate");
      showMinutes = Properties.getValue("showMinutes");
      showMonth = Properties.getValue("showMonth");
      showSeason = Properties.getValue("showSeason");
      showSunrise = Properties.getValue("showSunrise");
      
      hourStyle = (Properties.getValue("hourStyle")==1 ? "dots" : "lines");
      enableNightScreen = Properties.getValue("enableNightScreen");
    }
  
    function resetColors() {
      try {
        Properties.setValue("faceForegroundColor", 0xFFFFFF);
        Properties.setValue("faceBackgroundColor", 0x000000);
        Properties.setValue("ringColor", 0xFFFFFF);
        Properties.setValue("handColor", 0xFFFFFF);
        Properties.setValue("hourDotsColor", 0xFFFFFF);
        Properties.setValue("monthDotsColor", 0xFFFFFF);
        Properties.setValue("sleepColor", 0xFF0000);
      
        Properties.setValue("springColor", 0x00FF00);
        Properties.setValue("summerColor", 0xFF0000);
        Properties.setValue("autumnColor", 0xFF5500);
        Properties.setValue("winterColor", 0xFFFFFF);
      } catch (ex) {
      } 
                               
  }
  
  function calcSleepTime() {
    try {
      sleepStartTime = new Moment(Time.today().value() + (sleepStart) * 3600);
      var sleepHours = 0;
      var dayShift = true;
      if (sleepStart > sleepEnd ) {
        sleepHours = 24 - sleepStart + sleepEnd;
      } else {
        sleepHours = sleepEnd - sleepStart;
        dayShift = false;
      } 
      sleepEndTime = sleepStartTime.add(new Duration(sleepHours * 3600));
      if ( dayShift && sleepEndTime.value() > Time.now().value() + 24 * 3600 ) {
        sleepStartTime = sleepStartTime.subtract(new Duration(24 * 3600));
        sleepEndTime  = sleepEndTime.subtract(new Duration(24 * 3600));
      }
      } catch (ex) {
      }
        
  }
 
   /**
   * @param {array} location as latitude,longitude
   * @param {DateAndTime} dateNow
   * @return {SunRiseSunSet}
   */
  function dayLight(location,dateNow) {
    var year = dateNow.year;
    var month = dateNow.month;
    var day = dateNow.day;
    var timezone = dateNow.timezone;

    var latitude = location.latitude;
    var longitude = location.longitude;
    var zenith = 90.833333;
      /* other options
        var zenith_civil = 96;
        var zenith_nautical = 102;
        var zenith_astronomical = 108;
      */
    var dayLightSaving = 0; // included in timezone 
    var sunRiseTimes = calcSunTime(true, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving);
    var sunSetTimes = calcSunTime(false, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving);
    return new SunRiseSunSet({:sunRise => sunRiseTimes, :sunSet => sunSetTimes});
  
  }

  function calcSunTime(rising, year, month, day, latitude, longitude, zenith, timezone, dayLightSaving) {

    // 1. calculate the day of the year

    var N1 = Math.floor(275 * month / 9);
    var N2 = Math.floor((month + 9) / 12);
    var N3 = (1 + Math.floor((year - 4 * Math.floor(year / 4) + 2) / 3));
    var dayOfTherYear = N1 - (N2 * N3) + day - 30;
    
    // 2. convert the longitude to hour value and calculate an approximate time (days and time)

    var lngHour = longitude / 15;
    var approxTime;
    if (rising) {
        approxTime = dayOfTherYear + ((6 - lngHour) / 24);
    } else {
        approxTime = dayOfTherYear + ((18 - lngHour) / 24);
    }
    

    // 3. calculate the Sun's mean anomaly (degree)

    var meanAnomaly = (0.9856 * approxTime) - 3.289;
    
    // 4. calculate the Sun's true longitude

    var trueLongitude = meanAnomaly
        + (1.916 * Math.sin( dToR(meanAnomaly) ))
        + (0.020 * Math.sin( dToR(2 * meanAnomaly) ))
        + 282.634;

    trueLongitude = toRange(trueLongitude, 360);

    // 5a.calculate the Sun's right ascension

    var rightAscension = rToD(Math.atan(0.91764 * Math.tan( dToR(trueLongitude) )));
    //rightAscension = toRange(rightAscension,360);
  
    // 5b.right ascension value needs to be in the same quadrant as trueLongitude

    var Lquadrant = (Math.floor(trueLongitude / 90)) * 90;
    var RAquadrant = (Math.floor(rightAscension / 90)) * 90;
    rightAscension = rightAscension + (Lquadrant - RAquadrant);

    // 5c.right ascension value needs to be converted into hours

    rightAscension = rightAscension / 15;

    // 6. calculate the Sun's declination

    var sinDec = 0.39782 * Math.sin( dToR(trueLongitude) );
    var cosDec = Math.cos(Math.asin(sinDec));

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

    // 8. calculate local mean time of rising / setting

    var localMeanTime = hourAngle + rightAscension - (0.06571 * approxTime) - 6.622;

    //9. adjust back to UTC

    var UTC = localMeanTime - lngHour;
    //NOTE: UT potentially needs to be adjusted into the range[0, 24) by adding / subtracting 24
    UTC = toRange(UTC, 24);

    // 10. convert UT value to local time zone of latitude / longitude

    var localTime = UTC + timezone + dayLightSaving;
    var localHour = Math.floor(localTime).toLong();
    var localMinutes = Math.floor((localTime - localHour) * 60).toLong();
    
    return new DayTime({:hour => localHour, :minute => localMinutes});
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


  function getEquinoxOrSolstice(eventNr,year) {
    
    var Y = (year - 2000) / 1000.0;
  
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
    
    return equinoxOrSolstice;
  }

  function jdeToDate(jde) {
    // jde = 2436116.31;
    // 1957 October 4.81.
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
    year = year.toNumber();
    month = month.toNumber();
    day = day.toNumber();
    hour = hour.toNumber();
    minute = minute.toNumber();

    return new DateAndTime({ :year => year, :month => month, :day => day, :hour => hour, :minute => minute});
  }

  function getDateFromTime(moment) {
    var gregorianInfo = Gregorian.info(moment, Time.FORMAT_SHORT);
    var year = gregorianInfo.year;
    var month = gregorianInfo.month;
    var day = gregorianInfo.day;
    var hour = gregorianInfo.hour;
    var minute = gregorianInfo.min;
    var dst = System.getClockTime().dst;
    var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var timezone  = Gregorian.info(moment, Time.FORMAT_SHORT).hour - Gregorian.utcInfo(moment, Time.FORMAT_SHORT).hour;
    if (monkeyVersion < 3.3 ) {   // No LocalMoment supported , guess ...
      if (now.month == month && now.day == day) {  // today
        timezone = timezone + dst/3600;
      } else if (moment.greaterThan(astroData.springEquinox.toMoment()) && moment.lessThan(astroData.fallEquinox.toMoment())) {
        timezone++;
      }
    } else {
      var lMoment = Time.Gregorian.localMoment(astroData.location, moment);
      if (lMoment != null ) {
        timezone = lMoment.getOffset()/3600;
      }
    }

    return new DateAndTime({:timezone => timezone, :year => year, :month => month, :day => day, :hour => hour, :minute => minute});
  }

  /**
  *   Calculate 
  *   summerSolsticeDaylight
  *   winterSolsticeDaylight
  */
  function getSolsticeSunriseSunset() {
    var dateSummer = getDateFromTime(Gregorian.moment({
        :year => astroData.summerSolstice.year,
        :month => astroData.summerSolstice.month,
        :day => astroData.summerSolstice.day,
        :hour => astroData.summerSolstice.hour,
        :minute => astroData.summerSolstice.minute
        }
      )
    );
    var dateWinter = getDateFromTime(Gregorian.moment({
        :year => astroData.winterSolstice.year,
        :month => astroData.winterSolstice.month,
        :day => astroData.winterSolstice.day,
        :hour => astroData.winterSolstice.hour,
        :minute => astroData.winterSolstice.minute
        }
      )
    );
    
    astroData.summerSolsticeDaylight = dayLight(astroData.geoLocation,dateSummer);
    astroData.winterSolsticeDaylight = dayLight(astroData.geoLocation,dateWinter);
  }

  function calcAstroData(coordinates) {
    self.astroData = new AstroData();
    self.astroData.geoLocation = new GeoLocation({ :latitude => coordinates[0], :longitude => coordinates[1] });
    self.astroData.location = new Position.Location({
        :latitude => coordinates[0],
        :longitude => coordinates[1],
        :format => :degrees
    });
    var year = Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;
    // seasons starts
    self.astroData.springEquinox = getEquinoxOrSolstice(0,year);
    self.astroData.summerSolstice = getEquinoxOrSolstice(1,year);
    self.astroData.fallEquinox = getEquinoxOrSolstice(2,year);
    self.astroData.winterSolstice = getEquinoxOrSolstice(3,year);
    if (self.showSunrise) {
      var dateNow = getDateFromTime(Time.now());
      // sunrise sunset now
      self.astroData.dayLight = dayLight( self.astroData.geoLocation , dateNow);
      // sunrise sunset on season starts
      getSolsticeSunriseSunset();
    }
  }

}

(:background)
class DayTime {
  public var hour = null;
  public var minute = null;
  function initialize(options) {
    self.hour = options[:hour];
    self.minute = options[:minute];
  }
}

(:background)
class DateAndTime {
  public var timezone = null;
  public var year = null;
  public var month = null;
  public var day = null;
  public var hour = null;
  public var minute = null;
  function initialize(options) {
    self.timezone = options[:timezone];
    self.year = options[:year];
    self.month = options[:month];
    self.day = options[:day];
    self.hour = options[:hour];
    self.minute = options[:minute];
  }

  function toMoment() {
    return Gregorian.moment({
      :year => self.year,
      :month => self.month,
      :day => self.day,
      :hour => self.hour,
      :minute => self.minute
      }
    );

  }
}

(:background)
class SunRiseSunSet {
  public var sunRise as DayTime = null;
  public var sunSet as DayTime= null;
  function initialize(options) {
    self.sunRise = options[:sunRise];
    self.sunSet = options[:sunSet];
  }

}

(:background)
class GeoLocation {
  public var latitude = null;
  public var longitude = null;
  function initialize(options) {
    latitude = options[:latitude];
    longitude = options[:longitude];
  }
}

(:background)
class AstroData {
  public var geoLocation as GeoLocation = null;
  public var location as Position.Location = null;
  public var dayLight as SunRiseSunSet = null;
  
  public var springEquinox as DateAndTime = null;
  public var summerSolstice as DateAndTime = null;
  public var fallEquinox as DateAndTime = null;
  public var winterSolstice as DateAndTime = null;

  public var summerSolsticeDaylight as SunRiseSunSet = null;
  public var winterSolsticeDaylight as SunRiseSunSet = null;
  public var anyMessage = null;
}

