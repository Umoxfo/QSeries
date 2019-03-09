# Q100/200/300 EHSI by D-ECHO based on
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

var EHSI_main = nil;
var EHSI_display = nil;
var page = "only";

#All properties used...
#...in fast update:
var IAS_bug1 = props.globals.getNode("/instrumentation/EHSI/ias-bugs/bug1",1);
var IAS_bug1diff = props.globals.getNode("/instrumentation/EHSI/ias-bugs/bug1-diff", 1);
var IAS_bug1 = props.globals.getNode("/instrumentation/EHSI/ias-bugs/bug2",1);
var IAS_bug2diff = props.globals.getNode("/instrumentation/EHSI/ias-bugs/bug2-diff", 1);
var IAS = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1);
var IAS_10 = props.globals.getNode("/instrumentation/pfd/asi-10", 1);
var IAS_100 = props.globals.getNode("/instrumentation/pfd/asi-100", 1);
var Heading_magnetic = props.globals.getNode("/orientation/heading-magnetic-deg", 1);
var ALT_bugdiff = props.globals.getNode("/instrumentation/pfd/alt-bug-diff", 1);
var ALT = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
var ALT_1000 = props.globals.getNode("/instrumentation/EHSI/alt-1000", 1);
var ALT_100 = props.globals.getNode("/instrumentation/EHSI/alt-100", 1);
var ALT_AGL = props.globals.getNode("/position/gear-agl-ft", 1);
var VS = props.globals.getNode("/instrumentation/vertical-speed-indicator/indicated-speed-fpm", 1);
var VS_needle = props.globals.getNode("/instrumentation/pfd/vs-needle", 1);
var AI_pitch = props.globals.getNode("/orientation/pitch-deg", 1);
var AI_roll = props.globals.getNode("/orientation/roll-deg", 1);
var Slip_Skid = props.globals.getNode("/instrumentation/slip-skid-ball/indicated-slip-skid", 1);
var NAV0_isloc = props.globals.getNode("/instrumentation/nav[0]/frequencies/is-localizer-frequency", 1);
var NAV0_hasgs = props.globals.getNode("/instrumentation/nav[0]/has-gs", 1);
var NAV0_gsdefl = props.globals.getNode("/instrumentation/nav[0]/gs-needle-deflection-norm", 1);
var NAV1_isloc = props.globals.getNode("/instrumentation/nav[1]/frequencies/is-localizer-frequency", 1);
var NAV1_hasgs = props.globals.getNode("/instrumentation/nav[1]/has-gs", 1);
var NAV1_gsdefl = props.globals.getNode("/instrumentation/nav[1]/gs-needle-deflection-norm", 1);

#in slow update:
var Ground_Speed = props.globals.getNode("/velocities/groundspeed-kt", 1);
var AP_modelat = props.globals.getNode("/it-autoflight/mode/lat", 1);
var AP_modearm = props.globals.getNode("/it-autoflight/mode/arm", 1);
var AP_modevert = props.globals.getNode("/it-autoflight/mode/vert", 1);
var AP_vs = props.globals.getNode("/it-autoflight/input/vs", 1);
var AP_ias = props.globals.getNode("/it-autoflight/input/spd-kts", 1);
var AP_alt = props.globals.getNode("/it-autoflight/input/alt", 1);
var AP_hdg = props.globals.getNode("/it-autoflight/input/hdg", 1);
var AP_navsource = props.globals.getNode("/it-autoflight/settings/nav-source", 1);
var Heading_bugdiff = props.globals.getNode("/instrumentation/pfd/hdg-bug-diff", 1);
var NAV0_inrange = props.globals.getNode("/instrumentation/nav[0]/in-range", 1);
var NAV0_defl = props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection-norm", 1);
var NAV0_freq = props.globals.getNode("/instrumentation/nav[0]/frequencies/selected-mhz", 1);
var NAV0_rad = props.globals.getNode("/instrumentation/nav[0]/radials/selected-deg", 1);
var NAV0_dme_inrange = props.globals.getNode("/instrumentation/nav[0]/dme-in-range", 1);
var NAV0_dme = props.globals.getNode("/instrumentation/nav[0]/nav-distance", 1);
var NAV0_tofrom = props.globals.getNode("/instrumentation/nav[0]/from-flag", 1);
var NAV1_inrange = props.globals.getNode("/instrumentation/nav[1]/in-range", 1);
var NAV1_defl = props.globals.getNode("/instrumentation/nav[1]/heading-needle-deflection-norm", 1);
var NAV1_freq = props.globals.getNode("/instrumentation/nav[1]/frequencies/selected-mhz", 1);
var NAV1_rad = props.globals.getNode("/instrumentation/nav[1]/radials/selected-deg", 1);
var NAV1_dme_inrange = props.globals.getNode("/instrumentation/nav[1]/dme-in-range", 1);
var NAV1_dme = props.globals.getNode("/instrumentation/nav[1]/nav-distance", 1);
var NAV1_tofrom = props.globals.getNode("/instrumentation/nav[1]/from-flag", 1);
var ADF0_inrange = props.globals.getNode("/instrumentation/adf[0]/in-range", 1);
var ADF0_brg = props.globals.getNode("/instrumentation/adf[0]/indicated-bearing-deg", 1);
var ADF1_inrange = props.globals.getNode("/instrumentation/adf[1]/in-range", 1);
var ADF1_brg = props.globals.getNode("/instrumentation/adf[1]/indicated-bearing-deg", 1);
var DME_dist = props.globals.getNode("/instrumentation/dme[0]/indicated-distance-nm", 1);
var ALT_qnh = props.globals.getNode("/instrumentation/altimeter/setting-hpa", 1);
var DecHei = props.globals.getNode("/instrumentation/EHSI/DH", 1);
var RM_cur_wp = props.globals.getNode("/autopilot/route-manager/current-wp", 1);


var Volts = props.globals.getNode("/systems/electrical/outputs/ehsi[0]", 1);
var MainPage = props.globals.getNode("/instrumentation/mfd[0]/inputs/main-page", 1);


#init
var IAS_bug1 = props.globals.initNode("/instrumentation/EHSI/ias-bugs/bug1", 0.0, "DOUBLE");
var IAS_bug2 = props.globals.initNode("/instrumentation/EHSI/ias-bugs/bug2", 0.0, "DOUBLE");
var IAS_10 = props.globals.initNode("/instrumentation/pfd/asi-10", 0.0, "DOUBLE");
var IAS_100 = props.globals.initNode("/instrumentation/pfd/asi-100", 0.0, "DOUBLE");
var ALT_bugdiff = props.globals.initNode("/instrumentation/pfd/alt-bug-diff", 0.0, "DOUBLE");
var ALT_1000 = props.globals.initNode("/instrumentation/EHSI/alt-1000", 0.0, "DOUBLE");
var ALT_100 = props.globals.initNode("/instrumentation/EHSI/alt-100", 0.0, "DOUBLE");
var VS_needle = props.globals.initNode("/instrumentation/pfd/vs-needle", 0.0, "DOUBLE");
var Heading_bugdiff = props.globals.initNode("/instrumentation/pfd/hdg-bug-diff", 0.0, "DOUBLE");


var NAV0_rad = props.globals.initNode("/instrumentation/nav[0]/radials/selected-deg", 0.0, "DOUBLE");
var NAV1_rad = props.globals.initNode("/instrumentation/nav[1]/radials/selected-deg", 0.0, "DOUBLE");

var Volts = props.globals.initNode("/systems/electrical/outputs/ehsi[0]", 0.0,  "DOUBLE");
var MainPage = props.globals.initNode("/instrumentation/mfd[0]/inputs/main-page","", "STRING");


var canvas_EHSI_base = {
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
				EHSI_main.page.hide();
			}else{
				EHSI_main.page.show();
			}
		} else {
			EHSI_main.page.hide();
		}
		
		settimer(func me.update(), 0.1);
	},
};

var canvas_EHSI_main = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_EHSI_main,canvas_EHSI_base] };
		m.init(canvas_group, file, "main");

		return m;
	},
	getKeys: func() {
		return ["compass","groundspeed","nav.source","nav.dist","nav.crs","heading.bug","heading.bug.text"];
	},
	fast_update: func() {
	
		me["compass"].setRotation(Heading_magnetic.getValue()*-D2R);
		
		
		me["heading.bug"].setRotation(Heading_bugdiff.getValue()*-D2R);
		
		
		settimer(func me.fast_update(), 0.05);
	},
	slow_update: func() {
		
		me["groundspeed"].setText(sprintf("%3d", math.round(Ground_Speed.getValue())));
		
		var navsrc = AP_navsource.getValue();
		me["nav.source"].setText(navsrc);
		if(navsrc=="NAV1"){
			if(NAV0_dme_inrange.getValue()==1){
				var nav0_dist = NAV0_dme.getValue();
				if(nav0_dist>=10){
					me["nav.dist"].setText(sprintf("%3d", nav0_dist));
				}else{
					me["nav.dist"].setText(sprintf("%2.1f", nav0_dist));
				}
			}else{
				me["nav.dist"].setText("---");
			}
			me["nav.crs"].setText(sprintf("%3d", math.round(NAV0_rad.getValue())));
		}else if(navsrc=="NAV2"){
			if(NAV1_dme_inrange.getValue()==1){
				var nav1_dist = NAV1_dme.getValue();
				if(nav0_dist>=10){
					me["nav.dist"].setText(sprintf("%3d", nav1_dist));
				}else{
					me["nav.dist"].setText(sprintf("%2.1f", nav1_dist));
				}
			}else{
				me["nav.dist"].setText("---");
			}
			me["nav.crs"].setText(sprintf("%3d", math.round(NAV1_rad.getValue())));
		}
		
		var hdgbug=AP_hdg.getValue();
		me["heading.bug.text"].setText(sprintf("%3d", math.round(hdgbug)));
	
		settimer(func me.slow_update(), 0.2);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	EHSI_display = canvas.new({
		"name": "EHSI",
		"size": [675, 512],
		"view": [1350, 1024],
		"mipmapping": 1
	});
	EHSI_display.addPlacement({"node": "EHSI.screen"});
	var groupEHSImain = EHSI_display.createGroup();

	EHSI_main = canvas_EHSI_main.new(groupEHSImain, "Aircraft/QSeries/Models/Cockpit/Instruments/EHSI/EHSI.svg");

	EHSI_main.fast_update();
	EHSI_main.slow_update();
	canvas_EHSI_base.update();
});

var showEHSI = func {
	var dlg = canvas.Window.new([675, 512], "dialog").set("resize", 1);
	dlg.setCanvas(EHSI_display);
}
