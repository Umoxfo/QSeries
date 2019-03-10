# Q400 EADI by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Autoflight.pdf http://www.smartcockpit.com/docs/Q400-Navigation_1.pdf http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}

var EADI_main = nil;
var EADI_display = nil;
var page = "only";

#All properties used...
#...in fast update:
var VREF_diff = props.globals.getNode("/instrumentation/EADI/vref_diff_norm",1);
var AI_pitch = props.globals.getNode("/orientation/pitch-deg", 1);
var AI_roll = props.globals.getNode("/orientation/roll-deg", 1);
var ALT_AGL = props.globals.getNode("/position/gear-agl-ft", 1);

var NAV0_isloc = props.globals.getNode("/instrumentation/nav[0]/frequencies/is-localizer-frequency", 1);
var NAV0_hasgs = props.globals.getNode("/instrumentation/nav[0]/has-gs", 1);
var NAV0_locdefl = props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection-norm", 1);
var NAV0_gsdefl = props.globals.getNode("/instrumentation/nav[0]/gs-needle-deflection-norm", 1);

#in slow update:
var AP_modelat = props.globals.getNode("/it-autoflight/mode/lat", 1);
var AP_modevert = props.globals.getNode("/it-autoflight/mode/vert", 1);


var Volts = props.globals.getNode("/systems/electrical/outputs/eadi[0]", 1);
var MainPage = props.globals.getNode("/instrumentation/mfd[0]/inputs/main-page", 1);


#init
var Volts = props.globals.initNode("/systems/electrical/outputs/eadi[0]", 0.0,  "DOUBLE");
var MainPage = props.globals.initNode("/instrumentation/mfd[0]/inputs/main-page","", "STRING");
var VREF_diff = props.globals.initNode("/instrumentation/EADI/vref_diff_norm", 0.0, "DOUBLE");
var NAV0_locdefl = props.globals.initNode("/instrumentation/nav[0]/heading-needle-deflection-norm", 0.0, "DOUBLE");
var NAV0_gsdefl = props.globals.initNode("/instrumentation/nav[0]/gs-needle-deflection-norm", 0.0, "DOUBLE");


setprop("/it-autoflight/input/alt", 100000);

setprop("/test-value", 1);

var canvas_EADI_base = {
	init: func(canvas_group, file, screen) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {'font-mapper': font_mapper});

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
		
		if(screen=="main"){
			me.h_trans = me["horizon"].createTransform();
			me.h_rot = me["horizon"].createTransform();
		}
			
		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		if (Volts.getValue() >= 10) {
			var main_page=MainPage.getValue();
			if(main_page=="pfd"){
				EADI_main.page.hide();
			}else{
				EADI_main.page.show();
			}
		} else {
			EADI_main.page.hide();
		}
		
		settimer(func me.update(), 0.1);
	},
};

var canvas_EADI_main = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EADI_main,canvas_EADI_base] };
		m.init(canvas_group, file, "main");

		return m;
	},
	getKeys: func() {
		return ["horizon","rollpointer","vref.assist","radioalt.group","radioalt","rising_runway","ap.lat","ap.vert","loc.scale","loc.ind","gs.scale","gs.ind"];
	},
	fast_update: func() {
		
		#Attitude Indicator
		var pitch = AI_pitch.getValue();
		var roll =  AI_roll.getValue();
		
		me.h_trans.setTranslation(0,pitch*10.63);
		me.h_rot.setRotation(-roll*D2R,me["horizon"].getCenter());
		
		if(roll<-60){
			me["rollpointer"].setRotation(60*D2R);
		}else if(roll>60){
			me["rollpointer"].setRotation(-60*D2R);
		}else{
			me["rollpointer"].setRotation(-roll*D2R);
		}
			
		
		var vd = VREF_diff.getValue();
		me["vref.assist"].setTranslation(0,vd*150);
		
		var radio_alt = ALT_AGL.getValue();
		if(radio_alt>2500){
			me["radioalt.group"].hide();
		}else{
			me["radioalt.group"].show();
			me["radioalt"].setText(sprintf("%4d", radio_alt));
			if(radio_alt>200){
				me["rising_runway"].hide();
			}else{
				me["rising_runway"].show();
				me["rising_runway"].setTranslation(0,radio_alt*1.22);
			}
		}
		
		#Localizer and Glideslope (ILS)
		if(NAV0_isloc.getValue()==0){
			me["loc.scale"].hide();
			me["gs.scale"].hide();
		}else{
			me["loc.scale"].show();
			var loc_dev = NAV0_locdefl.getValue();
			me["loc.ind"].setTranslation(loc_dev*121,0);
			if(NAV0_hasgs.getValue()==0){
				me["gs.scale"].hide();
			}else{
				me["gs.scale"].show();
				var gs_dev = NAV0_gsdefl.getValue();
				me["gs.ind"].setTranslation(0,-gs_dev*149);
			}
		}
			
		
		
		settimer(func me.fast_update(), 0.05);
	},
	slow_update: func() {
		var ap_mode_lat = AP_modelat.getValue();
		me["ap.lat"].setText(ap_mode_lat);
		
		var ap_mode_vert = AP_modevert.getValue();
		me["ap.vert"].setText(ap_mode_vert);
		

	
		settimer(func me.slow_update(), 0.2);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	EADI_display = canvas.new({
		"name": "EADI",
		"size": [675, 512],
		"view": [1350, 1024],
		"mipmapping": 1
	});
	EADI_display.addPlacement({"node": "EADI.screen"});
	var groupEADImain = EADI_display.createGroup();

	EADI_main = canvas_EADI_main.new(groupEADImain, "Aircraft/QSeries/Models/Cockpit/Instruments/EADI/EADI.svg");

	EADI_main.fast_update();
	EADI_main.slow_update();
	canvas_EADI_base.update();
});

var showEADI = func {
	var dlg = canvas.Window.new([675, 512], "dialog").set("resize", 1);
	dlg.setCanvas(EADI_display);
}
