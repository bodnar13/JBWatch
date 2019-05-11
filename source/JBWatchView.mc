using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System;
using Toybox.Lang as Lang;
using Toybox.Time;

class JBWatchView extends Ui.WatchFace {

  var device=System.getDeviceSettings();
  
  var zoom=1;
  var rel_sleep_ring  = 3;
  var rel_hour_ring   = 10;
  var rel_month_ring  = 26;
  var rel_season_ring = 32;
  
  var rel_cross_in   = 5;
  var rel_cross_out  = 3;
  
  var isDebug=false;
    
  var center_x=device.screenWidth/2; 
  var center_y=device.screenHeight/2; 
  var radial=center_x;
  var fontHeight=Gfx.getFontHeight(Gfx.FONT_XTINY);
  
  var txtLine2=radial-radial*0.4;      
  var txtLine1=txtLine2-fontHeight;
  var txtLine3=radial-fontHeight/2;			 // center
  var txtLine5=radial+radial*0.4;
  var txtLine4=txtLine5-fontHeight;
      
  

  var sleep_ring  = zoom*(radial-rel_sleep_ring);  // 117;
  var hour_ring   = zoom*(radial-rel_hour_ring);   // 110;
  var month_ring  = zoom*(radial-rel_month_ring);  // 94;
  var season_ring = zoom*(radial-rel_season_ring); // 88;
  
  var minute_size= 10;
  
  var month_hand  = month_ring/2;         // 40;
  var minute_hand = hour_ring-20;   // 110;
  
  var progress= 20;
  
  var day_size= 3;
  var hour_size_dots= 3;
  var hour_size_lines= 12;
  // var minute_size= 3;
  var month_size= 3;
  
  var time_hour_size= 6;
  var time_minute_size= 6;
  var time_month_size= 5;
  
  var penWidthWide=2;
  var season_ring_width= 5;
  var sleep_ring_width= 5;
  
    
  var clockTime;
  var monthName;
  var month;         
  var now;  
  var sleepHours=0;
   
  
    function initialize() {
        WatchFace.initialize();
        
    }

    function onLayout(dc) {
    	setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {
      if (isDebug) {  System.println("onShow"); }    
    }

    function onUpdate(dc) {   
       if (isDebug) {  System.println("onUpdate start"); } 
       
       View.onUpdate(dc);

       clockTime = System.getClockTime();
       
       var slpStart=new Time.Moment(Time.today().value()+(JBWatchApp.sleepStart)*3600);
       sleepHours=0;
       var dayShift=true;
       if (JBWatchApp.sleepStart>JBWatchApp.sleepEnd ) {
         sleepHours=24-JBWatchApp.sleepStart+JBWatchApp.sleepEnd;
       } else {
         sleepHours=JBWatchApp.sleepEnd-JBWatchApp.sleepStart;
         dayShift=false;
       } 
       var slpEnd=slpStart.add(new Time.Duration(sleepHours*3600));
       if ( dayShift && slpEnd.value()>Time.now().value()+24*3600 ) {
          slpStart=slpStart.subtract(new Time.Duration(24*3600));
          slpEnd  =slpEnd.subtract(new Time.Duration(24*3600));
       }
       if ( JBWatchApp.enableNightScreen && slpStart.lessThan(Time.now())  && slpEnd.greaterThan(Time.now()) )  {
            sleep(dc,true);
            minuteHand(dc);
            cross(dc);
            return; 
          }          
       

// DateTime variables
	   now=Time.now();
   	   monthName=Time.Gregorian.info(now,Time.FORMAT_LONG).month;
   	   month=Time.Gregorian.info(now,Time.FORMAT_SHORT).month;
   	   
   	   
   	   var today=Time.Gregorian.info(now,Time.FORMAT_LONG);
       var year=Time.Gregorian.info(now,Time.FORMAT_LONG).year;
   	            
     
        showMessage(dc);
        showEvent(dc);      
//		sleep(dc,false);
		monthFace(today,dc);
		hoursFace(today,dc);
		seasons(dc);
		cross(dc);
		
		
		
		
		if (isDebug) {  System.println("onUpdate end Mem :"+System.getSystemStats().freeMemory); }
		
}         

    function onHide() {
    	if (isDebug) {  System.println("onHide"); }
    }

    function onExitSleep() {
    	if (isDebug) {  System.println("onExitSleep"); }
    }

    function onEnterSleep() {
    	if (isDebug) {  System.println("onEnterSleep"); }
    }
    


//	MONTH
   function monthFace(today,dc) {
       	if (isDebug) {  System.println("month start"); }
       	if ( !JBWatchApp.showMonth ) { return; }
   
                    
		 var mo=0;
 		 if ( JBWatchApp.showRings ) {
 		    dc.setColor(JBWatchApp.ringColor, JBWatchApp.JBWatchApp.ringColor);
          	dc.drawCircle(center_x,center_y, month_ring);
          }
         dc.setColor(JBWatchApp.monthDotsColor, JBWatchApp.JBWatchApp.monthDotsColor);
         for (var i = (Math.PI/180)*-240; i <Math.PI*0.5 ; i += Math.PI/6 ) {
         	var x=center_x+Math.cos(i)*month_ring;
         	var y=center_y+Math.sin(i)*month_ring;
         	var xh=center_x+Math.cos(i)*(month_ring-month_hand);
         	var yh=center_y+Math.sin(i)*(month_ring-month_hand);
         	var xmp=Math.cos(i)*(time_month_size*2);
         	var ymp=Math.sin(i)*(time_month_size*2);
         	dc.fillCircle(x, y, month_size);
         	dc.setPenWidth(1);
         	mo++;
         }
         dc.setColor(JBWatchApp.faceForegroundColor, JBWatchApp.JBWatchApp.faceBackgroundColor);
         mo=0;
         var mox=Time.Gregorian.moment({:month =>1, :day => 1}).subtract(now).value()/86400;         
         for (var i = (Math.PI/180)*-240; i <(Math.PI/180)*120 ; i += Math.PI/183 ) {
         	var x=center_x+Math.cos(i)*(month_ring);
         	var y=center_y+Math.sin(i)*(month_ring);
         	var xh=center_x+Math.cos(i)*(month_ring-month_hand);
         	var yh=center_y+Math.sin(i)*(month_ring-month_hand);
         	var xmp=Math.cos(i)*(time_month_size*2);
         	var ymp=Math.sin(i)*(time_month_size*2);
         	if ( mox == mo ) {
        	  dc.setPenWidth(penWidthWide);
        	  dc.setColor(JBWatchApp.handColor, JBWatchApp.handColor);
        	  dc.drawLine(x,y,xh,yh);
        	  dc.setColor(JBWatchApp.faceForegroundColor, JBWatchApp.faceBackgroundColor);
         	  dc.drawArc(center_x, center_y, month_ring, Gfx.ARC_CLOCKWISE, 240, 360-((i/Math.PI)*180) );
         	  dc.setPenWidth(1);
         	}
         	mo++;
         }
         
         if (isDebug) {  System.println("month end"); }
         
}

// HOURS
function hoursFace(today,dc) {
   if (isDebug) {  System.println("hours start"); }
   

   var q=Math.round(clockTime.min/12.0);
//         var h=0;         
         if ( JBWatchApp.showRings ) {
            dc.setColor(JBWatchApp.ringColor, JBWatchApp.JBWatchApp.ringColor);
         	dc.drawCircle(center_x,center_y, hour_ring);
         	dc.setColor(JBWatchApp.hourDotsColor, JBWatchApp.hourDotsColor);
         }
         showHourMarks(dc,0,24,hour_ring,(JBWatchApp.hourStyle.equals("dots") ? hour_size_dots : hour_size_lines) , JBWatchApp.hourStyle) ;
         
         var j=5;
         var m=0;
         // 12 minutes
         for (var i = Math.PI*-1.5; i <Math.PI*0.5 ; i += Math.PI/60) {
         	var xh=center_x+Math.cos(i)*(hour_ring-minute_hand);
         	var yh=center_y+Math.sin(i)*(hour_ring-minute_hand);
         	
         	var xms=center_x+Math.cos(i)*(hour_ring-minute_size);
         	var yms=center_y+Math.sin(i)*(hour_ring-minute_size);
         	var xme=center_x+Math.cos(i)*(hour_ring);
         	var yme=center_y+Math.sin(i)*(hour_ring);
         	if (j<5) {
         	   if (JBWatchApp.showMinutes ) {
         			dc.drawLine(xms, yms, xme, yme);
         		}
         	} else {
         	 j=0;
         	}
         	if ( m == clockTime.hour*5 + q) {
         	   if ( JBWatchApp.showRings ) {
         	    dc.setColor(JBWatchApp.ringColor, JBWatchApp.JBWatchApp.ringColor);
        	   	dc.drawArc(center_x, center_y, hour_ring, Gfx.ARC_CLOCKWISE, 270, 360-((i/Math.PI)*180) );
        	   	dc.setColor(JBWatchApp.faceForegroundColor, JBWatchApp.faceBackgroundColor);
        	   }
        	   if ( JBWatchApp.showDate ) {
        	   	dc.drawText(center_x , txtLine2, Gfx.FONT_XTINY , today.year+"."+ today.month+" ."+today.day, Gfx.TEXT_JUSTIFY_CENTER);
           	   	dc.drawText(center_x , txtLine1, Gfx.FONT_XTINY , today.day_of_week, Gfx.TEXT_JUSTIFY_CENTER);
           	   }
         	}
         	m++;
         	j++;
         
         }
         var stats= System.getSystemStats();
         dc.drawText(center_x , txtLine5, Gfx.FONT_XTINY ,stats.battery.format("%2d")+"%" , Gfx.TEXT_JUSTIFY_CENTER);
         minuteHand(dc);
         if (isDebug) {  System.println("hours end"); }
    }
// Minute Hand
function minuteHand(dc) {
   if (isDebug) {  System.println("minute hand start"); }
   
   var q=Math.ceil(clockTime.min/6);
        
         var m=0;
         // 6 minutes resolution
         for (var i = Math.PI*-1.5; i <Math.PI*0.5 ; i += Math.PI/120) {
  //          if (isDebug) {  System.println("minute hand (i,q,m)"+"("+i+","+q+","+m+") "+(Math.round(clockTime.hour*10 + q))); }
         	if ( m == Math.round(clockTime.hour*10 + q) ) {
         	    var x=center_x+Math.cos(i)*(hour_ring);
         		var y=center_y+Math.sin(i)*(hour_ring);
         		var xh=center_x+Math.cos(i)*(hour_ring-minute_hand);
         		var yh=center_y+Math.sin(i)*(hour_ring-minute_hand);
         	
            	var xhp=Math.cos(i)*(time_minute_size);
         		var yhp=Math.sin(i)*(time_minute_size);
         	
         	   dc.setColor(JBWatchApp.handColor, JBWatchApp.handColor);
        	   dc.setPenWidth(penWidthWide);
        	   dc.drawLine(xh,yh,x-xhp,y-yhp);
        	   dc.setPenWidth(1);
        	   dc.setColor(JBWatchApp.faceForegroundColor, JBWatchApp.faceBackgroundColor);
        	   if (isDebug) {  System.println("minute hand exit"); }
        	   break;
         	}
         	m++;
       
         }
         if (isDebug) {  System.println("hours handend"); }
}

// SLEEP
   function sleep(dc,withHours) { 
         if (isDebug) {  System.println("sleep start"); }
	   	 dc.setPenWidth(sleep_ring_width);
         dc.setColor(JBWatchApp.sleepColor,JBWatchApp.sleepColor);
         dc.drawArc(center_x, center_y, sleep_ring, Gfx.ARC_CLOCKWISE,270+15*(24-JBWatchApp.sleepStart),270+15*(24-JBWatchApp.sleepEnd));

		if (withHours) {         
         showHourMarks(dc,JBWatchApp.sleepStart,sleepHours,sleep_ring,(JBWatchApp.hourStyle.equals("dots") ? hour_size_dots : hour_size_lines),JBWatchApp.hourStyle);
         }
         dc.setPenWidth(1);
         dc.setColor(JBWatchApp.faceForegroundColor,JBWatchApp.faceBackgroundColor);
         if (isDebug) {  System.println("sleep end"); }
    
   }
   function seasons(dc) {
   		if ( !JBWatchApp.showSeason ) { return; }
   // SEASONS
         if (isDebug) {  System.println("seasons start"); }
         dc.setPenWidth(season_ring_width);
          // Winter
         dc.setColor(JBWatchApp.winterColor,JBWatchApp.faceBackgroundColor);
         dc.drawArc(center_x, center_y, season_ring, Gfx.ARC_CLOCKWISE, 270, 180 );
		 // Spring
		 dc.setColor(JBWatchApp.springColor,JBWatchApp.faceBackgroundColor);
         dc.drawArc(center_x, center_y, season_ring, Gfx.ARC_CLOCKWISE, 180, 90 );
		 // Summer         
         dc.setColor(JBWatchApp.summerColor,JBWatchApp.faceBackgroundColor);
         dc.drawArc(center_x, center_y, season_ring, Gfx.ARC_CLOCKWISE, 90, 0 );
		 // Fall         
         dc.setColor(JBWatchApp.autumnColor,JBWatchApp.faceBackgroundColor);
         dc.drawArc(center_x, center_y, season_ring, Gfx.ARC_CLOCKWISE, 360, 270 );
         
         dc.setColor(JBWatchApp.faceForegroundColor,JBWatchApp.faceBackgroundColor);
         dc.setPenWidth(1);
         
          if (isDebug) {  System.println("seasons end"); }
   }
   
   function cross(dc) {
         dc.setPenWidth(1);
         dc.setColor(Gfx.COLOR_WHITE,JBWatchApp.faceBackgroundColor);
         // left
         dc.drawLine(center_x-sleep_ring-rel_cross_out,  center_y,center_x-season_ring+rel_cross_in , center_y);
         // right
         dc.drawLine(center_x+season_ring-rel_cross_in, center_y,center_x+sleep_ring+rel_cross_out , center_y);
		 // top
         dc.drawLine(center_x-1,center_y-sleep_ring-rel_cross_out, center_x-1,center_y-season_ring+rel_cross_in);
		 // bottom
         dc.drawLine(center_x-1,center_y+season_ring-rel_cross_in, center_x-1,center_y+sleep_ring+rel_cross_out);
   }
   
   
   
   function showHourMarks(dc,fromHour,nrOfHours,radius,size, style) {
  
   	 dc.setColor(JBWatchApp.hourDotsColor, JBWatchApp.JBWatchApp.hourDotsColor);
   	 dc.setPenWidth(2);
   	 for (var i = Math.PI/2+(fromHour*Math.PI/12); i <= Math.PI/2+(fromHour*Math.PI/12)+nrOfHours*Math.PI/12 ; i += Math.PI/12) {
   	 	if ( style.equals("dots") ) {
         		var x=center_x+Math.cos(i)*radius;
         		var y=center_y+Math.sin(i)*radius;
         	 	dc.fillCircle(x, y, size);
         } else if ( style.equals("lines") ) {
         		var x1=center_x+Math.cos(i)*(radius);
         		var y1=center_y+Math.sin(i)*(radius);
         		var x2=center_x+Math.cos(i)*(radius-size);
         		var y2=center_y+Math.sin(i)*(radius-size);
         		dc.drawLine(x1,y1,x2,y2);
         }
       }
         	dc.setColor(JBWatchApp.faceForegroundColor, JBWatchApp.JBWatchApp.faceBackgroundColor);
         	dc.setPenWidth(1);
	}
	function showMessage(dc) {
	   if ( JBWatchApp.anyMessage.length()>0 ) {
        	dc.drawText(center_x , txtLine3, Gfx.FONT_XTINY , JBWatchApp.anyMessage, Gfx.TEXT_JUSTIFY_CENTER);
        }
	}

	function showEvent(dc) {
		var eventDays=Math.round(new Time.Moment(JBWatchApp.eventDate).subtract(now).value()/Time.Gregorian.SECONDS_PER_DAY);
		
		if (JBWatchApp.showEvent && eventDays >= 0 ) {
		  var daysString=Ui.loadResource(Rez.Strings.daysTitle);
		  dc.setColor(JBWatchApp.faceForegroundColor, JBWatchApp.JBWatchApp.faceBackgroundColor);
		  dc.drawText(center_x ,txtLine4, Gfx.FONT_XTINY , JBWatchApp.eventName+" "+eventDays+" "+daysString,Gfx.TEXT_JUSTIFY_CENTER);
		}
	
	}
}