using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Background extends Ui.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {

        dc.setColor(JBWatchApp.faceForegroundColor, JBWatchApp.faceBackgroundColor);
        dc.clear();
        
    }

}
