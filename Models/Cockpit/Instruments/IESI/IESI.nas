# Bombardier Q400 IESI
# D-ECHO based on
# A32X IESI by Joshua Davidson (it0uchpods)

var IESI = nil;
var IESI_display = nil;
var elapsedtime = 0;
var ASI = 0;
var alt = 0;
var altTens = 0;
var pitch = 0;
var roll = 0;
setprop("/test",1);

var canvas_IESI_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();

			foreach (var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);

				var clip_el = canvas_group.getElementById(key ~ "_clip");
				if (clip_el != nil) {
					clip_el.setVisible(0);
					var tran_rect = clip_el.getTransformedBounds();

					var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
					tran_rect[1], # 0 ys
					tran_rect[2], # 1 xe
					tran_rect[3], # 2 ye
					tran_rect[0]); #3 xs
					#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
					me[key].set("clip", clip_rect);
					me[key].set("clip-frame", canvas.Element.PARENT);
				}
			}
		}
		
		me.h_trans = me["horizon"].createTransform();
		me.h_rot = me["horizon"].createTransform();
		
		me.page = canvas_group;
		
		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		if ((getprop("/systems/electrical/outputs/stby-att") or 0) >= 10) {
			IESI.page.show();
			IESI.update();
		} else {
			IESI.page.hide();
		}
	},
};

var canvas_IESI = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_IESI, canvas_IESI_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["horizon","asi.tape","qnh.text","rollpointer","rollpointer2","metricalt","alt.tape","alt.1","alt.2","alt.3","alt.4","alt.5","alt.text"];
	},
	update: func() {
		# Airspeed
		var IAS=getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0;
		if(IAS<420){
			me["asi.tape"].setTranslation(0,IAS*2.381);
		}else{
			me["asi.tape"].setTranslation(0,420*2.381);
		}
		
		var pitch = (getprop("orientation/pitch-deg") or 0);
		var roll =  getprop("orientation/roll-deg") or 0;
		
		me.h_trans.setTranslation(0,pitch*4.23);
		me.h_rot.setRotation(-roll*D2R,me["horizon"].getCenter());
		
		me["rollpointer"].setRotation(roll*(-D2R));
		me["rollpointer2"].setTranslation(math.round(getprop("/instrumentation/slip-skid-ball/indicated-slip-skid") or 0)*5, 0);
		
		
		# QNH
		var settinghPa=getprop("/instrumentation/altimeter/setting-hpa") or 0;
		var settinginHg=getprop("/instrumentation/altimeter/setting-inhg") or 0;
		me["qnh.text"].setText(sprintf("%4.0f", settinghPa) ~ "hPa / " ~ sprintf("%2.2f", settinginHg));
		
		var altitude_ft=getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0;
		me["metricalt"].setText(sprintf("%4d", altitude_ft*FT2M));
		altOffset = altitude_ft / 500 - int(altitude_ft / 500);
		middleAltText = roundaboutAlt(altitude_ft / 100);
		middleAltOffset = nil;
		if (altOffset > 0.5) {
			middleAltOffset = -(altOffset - 1) * 87;
		} else {
			middleAltOffset = -altOffset * 87;
		}
		me["alt.tape"].setTranslation(0, -middleAltOffset);
		#me["ALT_scale"].update();
		me["alt.5"].setText(sprintf("%03d", abs(middleAltText+10)));
		me["alt.4"].setText(sprintf("%03d", abs(middleAltText+5)));
		me["alt.3"].setText(sprintf("%03d", abs(middleAltText)));
		me["alt.2"].setText(sprintf("%03d", abs(middleAltText-5)));
		me["alt.1"].setText(sprintf("%03d", abs(middleAltText-10)));
		me["alt.text"].setText(sprintf("%5d", altitude_ft));
		
	},
};

setlistener("sim/signals/fdm-initialized", func {
	IESI_display = canvas.new({
		"name": "IESI",
		"size": [1024, 1024],
		"view": [270,270],
		"mipmapping": 1
	});
	IESI_display.addPlacement({"node": "IESI.screen"});
	var group_IESI = IESI_display.createGroup();
	
	IESI = canvas_IESI.new(group_IESI, "Aircraft/QSeries/Models/Cockpit/Instruments/IESI/IESI.svg");
	
	IESI_update.start();
});

var IESI_update = maketimer(0.05, func {
	canvas_IESI_base.update();
});

var showIESI = func {
	var dlg = canvas.Window.new([256, 256], "dialog").set("resize", 1);
	dlg.setCanvas(IESI_display);
}

var roundabout = func(x) {
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x);
};

var roundaboutAlt = func(x) {
	var y = x * 0.2 - int(x * 0.2);
	return y < 0.5 ? 5 * int(x*0.2) : 5 + 5 * int(x*0.2);
};

