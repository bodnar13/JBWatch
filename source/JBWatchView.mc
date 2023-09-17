import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;


class JBWatchView extends WatchFace {

  var device=System.getDeviceSettings();
  
  var zoom=1;
  var rel_sleep_ring  = 3;
  var rel_hour_ring   = 10;
  var rel_month_ring  = 26;
  var rel_season_ring = 32;
  var rel_dayLight_ring = 34;
  
  var rel_cross_in   = 5;
  var rel_cross_out  = 3;
  
  var logLevel = 2;
  var seconds = 0;
    
  var center_x = device.screenWidth / 2; 
  var center_y = device.screenHeight / 2; 
  var radius = center_x;
  var fontHeight = Graphics.getFontHeight(Graphics.FONT_XTINY);
  
  var txtLine2 = radius - radius * 0.4;      
  var txtLine1 = txtLine2 - fontHeight;
  var txtLine3 = radius - fontHeight / 2;       // center
  var txtLine5 = radius + radius * 0.4;
  var txtLine4 = txtLine5 - fontHeight;
      
  var chartBlockWidth = 7;
  var chartBlockHeight = 6;
  var chartY=device.screenHeight / 2 - chartBlockHeight / 2;

  var sleep_ring  = zoom*(radius - rel_sleep_ring);  // 117;
  var hour_ring   = zoom*(radius - rel_hour_ring);   // 110;
  var month_ring  = zoom*(radius - rel_month_ring);  // 94;
  var season_ring = zoom*(radius - (showMonth ? rel_season_ring  : rel_month_ring)); ;
  
  var minute_size = 10;
  
  var month_hand  = month_ring / 2;         // 40;
  var minute_hand = hour_ring - 20;   // 110;

  var dayLight_hand = season_ring / 8;
  var season_ring_width = 5;
  var dayLight_ring = zoom*((showSeason ? radius - rel_dayLight_ring : season_ring));
  
  var progress = 20;
  
  var day_size = 3;
  var hour_size_dots = 3;
  var hour_size_lines = 12;
  // var minute_size= 3;
  var month_size = 3;
  
  var time_hour_size = 6;
  var time_minute_size = 6;
  var time_month_size = 5;
  
  var penWidthWide = 2;
  var sleep_ring_width = 5;
  
    
  var clockTime;
  var monthName;
  var month;         
  var now;  
  var sleepHours = 0;

  var refreshrate = 10;
  
  function initialize() {
    WatchFace.initialize();
  }

  function onLayout(dc) {
    setLayout( Rez.Layouts.WatchFace(dc) );
  }

  function onShow() {
  }

  function onUpdate(dc) {
    /*
      if (seconds % refreshrate != 0) {
        seconds++;
        return;
      } else {
        seconds = 1;
      }
    */
    View.onUpdate(dc);
    clockTime = System.getClockTime();
    sleepHours = 0;
    if (sleepStart > sleepEnd ) {
      sleepHours = 24 - sleepStart + sleepEnd;
    } else {
      sleepHours = sleepEnd - sleepStart;
    }
      if (enableNightScreen 
          && sleepStartTime.lessThan( Time.now() )  
          && sleepEndTime.greaterThan( Time.now() ) )  {
        sleep(dc, true);
        minuteHand(dc);
        cross(dc);
        return; 
      }          
      // DateTime variables
      now = Time.now();
      monthName = Gregorian.info(now, Time.FORMAT_LONG).month;
      month = Gregorian.info(now, Time.FORMAT_SHORT).month;
         
      var today = Gregorian.info(now, Time.FORMAT_LONG);
       
      message(dc);   
      event(dc);      
      monthFace(today, dc);
      hoursFace(today, dc);
      seasons(dc);
      cross(dc);
      dayLight(dc);
    
  }         

  function onHide() {

  }

  function onExitSleep() {

  }

  function onEnterSleep() {

  }
    


  //  MONTH
  function monthFace(today,dc) {

    if ( !showMonth ) {
      return;
    }                
    var mo = 0;
     if ( showRings ) {
        dc.setColor(ringColor, ringColor);
        dc.drawCircle(center_x,center_y, month_ring);
    }
    dc.setColor(monthDotsColor, monthDotsColor);
    for (var i = (Math.PI / 180) *-240; i < Math.PI * 0.5 ; i += Math.PI / 6 ) {
      var x = center_x + Math.cos(i) * month_ring;
      var y = center_y + Math.sin(i) * month_ring;
      dc.fillCircle(x, y, month_size);
      dc.setPenWidth(1);
      mo++;
    }
    dc.setColor(faceForegroundColor, faceBackgroundColor);
    mo = 0;
    var mox = Gregorian.moment({:month =>1, :day => 1}).subtract(now).value() / 86400;         
    for (var i = (Math.PI / 180) *-270; i <(Math.PI / 180) * 90 ; i += Math.PI / 183 ) {
      var x=center_x + Math.cos(i) * (month_ring);
      var y=center_y + Math.sin(i) * (month_ring);
      var xh=center_x + Math.cos(i) * (month_ring - month_hand);
      var yh=center_y + Math.sin(i) * (month_ring - month_hand);
      if ( mox == mo ) {
        dc.setPenWidth(penWidthWide);
        dc.setColor(handColor, handColor);
        dc.drawLine(x, y, xh, yh);
        dc.setColor(faceForegroundColor, faceBackgroundColor);
        dc.drawArc(center_x, center_y, month_ring, Graphics.ARC_CLOCKWISE, 270, 359 - ( (i / Math.PI) * 180) );
        dc.setPenWidth(1);
      }
      mo++;
    }    
    
}

// HOURS
function hoursFace(today,dc) {

  var q = Math.round(clockTime.min / 12.0);
  if ( showRings ) {
    dc.setColor(ringColor, ringColor);
    dc.drawCircle(center_x,center_y, hour_ring);
    dc.setColor(hourDotsColor, hourDotsColor);
  }
  showHourMarks(dc, 0, 24, hour_ring, (hourStyle.equals("dots") ? hour_size_dots : hour_size_lines) , hourStyle) ;       
  var j = 5;
  var m = 0;
  // 12 minutes
  for (var i = Math.PI * -1.5; i < Math.PI * 0.5 ; i += Math.PI / 60) {     
    var xms = center_x+Math.cos(i) * (hour_ring - minute_size);
    var yms = center_y+Math.sin(i) * (hour_ring - minute_size);
    var xme = center_x+Math.cos(i) * (hour_ring);
    var yme = center_y+Math.sin(i) * (hour_ring);
    if (j < 5) {
      if (showMinutes ) {
        dc.drawLine(xms, yms, xme, yme);
      }
    } else {
      j = 0;
    }
    if ( m == clockTime.hour * 5 + q) {
      if ( showRings ) {
        dc.setColor(ringColor, ringColor);
        dc.drawArc(center_x, center_y, hour_ring, Graphics.ARC_CLOCKWISE, 270, 360- ( (i / Math.PI) * 180) );
        dc.setColor(faceForegroundColor, faceBackgroundColor);
      }
      if ( showDate ) {
        dc.drawText(center_x , txtLine2, Graphics.FONT_XTINY , today.year + "." + today.month + " ." + today.day, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(center_x , txtLine1, Graphics.FONT_XTINY , today.day_of_week, Graphics.TEXT_JUSTIFY_CENTER);
      }
    }
      m++;
      j++;   
  }
  var stats= System.getSystemStats();
  dc.drawText(center_x , txtLine5, Graphics.FONT_XTINY ,stats.battery.format("%2d") + "%" , Graphics.TEXT_JUSTIFY_CENTER);
  minuteHand(dc);

}

  // Minute Hand
  function minuteHand(dc) {
   
    var q = Math.ceil(clockTime.min / 6);
    var m = 0;
    
    // 6 minutes resolution
    for (var i = Math.PI * -1.5; i <Math.PI * 0.5 ; i += Math.PI / 120) {
      if ( m == Math.round(clockTime.hour * 10 + q) ) {
        var x = center_x+Math.cos(i) * (hour_ring);
        var y = center_y+Math.sin(i) * (hour_ring);
        var xh = center_x+Math.cos(i) * (hour_ring - minute_hand);
        var yh = center_y+Math.sin(i) * (hour_ring - minute_hand);
           
        var xhp=Math.cos(i) * (time_minute_size);
        var yhp=Math.sin(i) * (time_minute_size);
           
        dc.setColor(handColor, handColor);
        dc.setPenWidth(penWidthWide);
        dc.drawLine(xh, yh, x - xhp, y - yhp);
        dc.setPenWidth(1);
        dc.setColor(faceForegroundColor, faceBackgroundColor);
        break;
      }
        m++; 
    }
  }

  // SLEEP
  function sleep(dc, withHours) { 
    dc.setPenWidth(sleep_ring_width);
    dc.setColor(sleepColor, sleepColor);
    dc.drawArc(center_x, center_y, sleep_ring, Graphics.ARC_CLOCKWISE, 270 + 15 * (24 - sleepStart), 270 + 15 * (24 - sleepEnd));

    if (withHours) {         
      showHourMarks(dc, sleepStart, sleepHours, sleep_ring, (hourStyle.equals("dots") ? hour_size_dots : hour_size_lines), hourStyle);
    }
    dc.setPenWidth(1);
    dc.setColor(faceForegroundColor, faceBackgroundColor);
  }

  function seasons(dc) {
    try {
    if ( !showSeason || astroData.springEquinox == null || astroData.summerSolstice == null || astroData.fallEquinox == null || astroData.winterSolstice == null) {
      return; 
    }
      // SEASONS
    dc.setPenWidth(season_ring_width);
    var startSpring = - 90 - ((astroData.springEquinox.month -1 ) / 12d * 360 + astroData.springEquinox.day / 365d * 360);
    var startSummer = - 90 - ((astroData.summerSolstice.month -1 ) / 12d * 360 + astroData.summerSolstice.day / 365d * 360);
    var startFall = - 90 - ((astroData.fallEquinox.month -1 ) / 12d * 360 + astroData.fallEquinox.day / 365d * 360);
    var startWinter = - 90 - ((astroData.winterSolstice.month -1 ) / 12d * 360 + astroData.winterSolstice.day / 365d * 360);

    // Winter
    dc.setColor(winterColor, faceBackgroundColor);
    dc.drawArc(center_x, center_y, season_ring, Graphics.ARC_CLOCKWISE, startWinter, startSpring );
    // Spring
    dc.setColor(springColor, faceBackgroundColor);
    dc.drawArc(center_x, center_y, season_ring, Graphics.ARC_CLOCKWISE, startSpring, startSummer );
    // Summer         
    dc.setColor(summerColor, faceBackgroundColor);
    dc.drawArc(center_x, center_y, season_ring, Graphics.ARC_CLOCKWISE, startSummer, startFall);
    // Fall         
    dc.setColor(autumnColor, faceBackgroundColor);
    dc.drawArc(center_x, center_y, season_ring, Graphics.ARC_CLOCKWISE, startFall, startWinter);
         
    dc.setColor(faceForegroundColor, faceBackgroundColor);
    dc.setPenWidth(1);
    } catch (ex) {
      
    }
         
  }
   
  function cross(dc) {
    dc.setPenWidth(1);
    dc.setColor(Graphics.COLOR_WHITE, faceBackgroundColor);
    // left
    dc.drawLine(center_x - sleep_ring - rel_cross_out,  center_y,center_x - season_ring + rel_cross_in , center_y);
    // right
    dc.drawLine(center_x + season_ring - rel_cross_in, center_y,center_x + sleep_ring + rel_cross_out , center_y);
    // top
    dc.drawLine(center_x - 1,center_y - sleep_ring - rel_cross_out, center_x -1 ,center_y-season_ring + rel_cross_in);
    // bottom
    dc.drawLine(center_x - 1,center_y+season_ring - rel_cross_in, center_x - 1 ,center_y + sleep_ring + rel_cross_out);
  }
    
  function showHourMarks(dc, fromHour, nrOfHours, radius, size, style) {
    dc.setColor(hourDotsColor, hourDotsColor);
     dc.setPenWidth(2);
     for (var i = Math.PI / 2 + (fromHour*Math.PI / 12); i <= Math.PI / 2 + (fromHour * Math.PI / 12) + nrOfHours * Math.PI / 12 ; i += Math.PI / 12) {
       if ( style.equals("dots") ) {
        var x = center_x + Math.cos(i) * radius;
        var y = center_y + Math.sin(i) * radius;
        dc.fillCircle(x, y, size);
      } else if (style.equals("lines") ) {
        var x1 = center_x + Math.cos(i) * (radius);
        var y1 = center_y + Math.sin(i) * (radius);
        var x2 = center_x + Math.cos(i) * (radius - size);
        var y2 = center_y + Math.sin(i) * (radius - size);
        dc.drawLine(x1, y1, x2, y2);
      }
    }
    dc.setColor(faceForegroundColor, faceBackgroundColor);
    dc.setPenWidth(1);
  }


  function message(dc) {
    if ( astroData.anyMessage != null && astroData.anyMessage.length() > 0  ) {
      dc.drawText(center_x , txtLine3, Graphics.FONT_XTINY , astroData.anyMessage, Graphics.TEXT_JUSTIFY_CENTER);
    }
  }

  function event(dc) {
    var eventDays = Math.round(new Moment(eventDate).subtract(now).value() / Gregorian.SECONDS_PER_DAY);
    if (showEvent && eventDays >= 0 ) {
      var daysString = WatchUi.loadResource(Rez.Strings.daysTitle);
      dc.setColor(faceForegroundColor, faceBackgroundColor);
      dc.drawText(center_x ,txtLine4, Graphics.FONT_XTINY , eventName + " " + eventDays + " " + daysString, Graphics.TEXT_JUSTIFY_CENTER);
    }
  }

  function dayLight(dc) {
    if (!showSunrise) {
      return;
    }
    var markerHight = 0.05;
    if (astroData.dayLight != null ) {
      drawDayLight(dc, astroData.dayLight.sunRise.hour, astroData.dayLight.sunRise.minute, markerHight);
      drawDayLight(dc, astroData.dayLight.sunSet.hour, astroData.dayLight.sunSet.minute, markerHight);
    }
    if (astroData.summerSolsticeDaylight != null && astroData.summerSolsticeDaylight != null) {
      // Summer Solstice Daylight
      drawDayRange(dc, astroData.summerSolsticeDaylight.sunRise.hour, astroData.summerSolsticeDaylight.sunRise.minute, markerHight);
      drawDayRange(dc, astroData.summerSolsticeDaylight.sunSet.hour, astroData.summerSolsticeDaylight.sunSet.minute, markerHight);
      // Winter Solstice Daylight
      drawDayRange(dc, astroData.winterSolsticeDaylight.sunRise.hour, astroData.winterSolsticeDaylight.sunRise.minute, markerHight);
      drawDayRange(dc, astroData.winterSolsticeDaylight.sunSet.hour, astroData.winterSolsticeDaylight.sunSet.minute, markerHight);
    }
  }

  function drawDayLight(dc, dlHour, dlMinutes, markerHight) {
    dc.setColor(faceForegroundColor, faceBackgroundColor);
    var radius = Math.PI * -1.5 + Math.toRadians(dlHour * 15) + Math.toRadians(dlMinutes * 15 / 60);
    var x= center_x + Math.cos(radius) * (dayLight_ring);
    var y= center_y + Math.sin(radius) * (dayLight_ring);
    var xh= center_x + Math.cos(radius + markerHight) * (dayLight_ring - dayLight_hand);
    var yh= center_y + Math.sin(radius + markerHight) * (dayLight_ring - dayLight_hand);
    var xi= center_x + Math.cos(radius - markerHight) * (dayLight_ring - dayLight_hand);
    var yi= center_y + Math.sin(radius - markerHight) * (dayLight_ring - dayLight_hand);
    dc.fillPolygon([[x, y], [xh, yh],[xi, yi]]);
  }

   function drawDayRange(dc, dlHour, dlMinutes, markerHight) {

    dc.setColor(faceForegroundColor, faceBackgroundColor);
    var radius = Math.PI * -1.5 + Math.toRadians(dlHour * 15) + Math.toRadians(dlMinutes * 15 / 60);
    var x= center_x + Math.cos(radius) * (sleep_ring - rel_sleep_ring -1);
    var y= center_y + Math.sin(radius) * (sleep_ring - rel_sleep_ring -1);
    var xh= center_x + Math.cos(radius + markerHight / 2) * (sleep_ring);
    var yh= center_y + Math.sin(radius + markerHight / 2) * (sleep_ring);
    var xi= center_x + Math.cos(radius - markerHight / 2) * (sleep_ring);
    var yi= center_y + Math.sin(radius - markerHight / 2) * (sleep_ring);
    dc.fillPolygon([[x, y], [xh, yh],[xi, yi]]);
  }
}