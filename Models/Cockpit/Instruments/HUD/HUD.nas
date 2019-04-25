# A3XX HUD
# Joshua Davidson (it0uchpods)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

var HUD_1 = nil;
var HUD_2 = nil;
var HUD_1_test = nil;
var HUD_2_test = nil;
var HUD_1_mismatch = nil;
var HUD_2_mismatch = nil;
var HUD1_display = nil;
var HUD2_display = nil;
var updateL = 0;
var updateR = 0;
var elapsedtime = 0;
var ASI = 0;
var ASItrgt = 0;
var ASItrgtdiff = 0;
var ASImax = 0;
var ASItrend = 0;
var altTens = 0;

# Fetch nodes:
var state1 = props.globals.getNode("/systems/thrust/state1", 1);
var state2 = props.globals.getNode("/systems/thrust/state2", 1);
var throttle_mode = props.globals.getNode("/modes/pfd/fma/throttle-mode", 1);
var pitch_mode = props.globals.getNode("/modes/pfd/fma/pitch-mode", 1);
var pitch_mode_armed = props.globals.getNode("/modes/pfd/fma/pitch-mode-armed", 1);
var pitch_mode2_armed = props.globals.getNode("/modes/pfd/fma/pitch-mode2-armed", 1);
var pitch_mode_armed_box = props.globals.getNode("/modes/pfd/fma/pitch-mode-armed-box", 1);
var pitch_mode2_armed_box = props.globals.getNode("/modes/pfd/fma/pitch-mode2-armed-box", 1);
var roll_mode = props.globals.getNode("/modes/pfd/fma/roll-mode", 1);
var roll_mode_armed = props.globals.getNode("/modes/pfd/fma/roll-mode-armed", 1);
var roll_mode_box = props.globals.getNode("/modes/pfd/fma/roll-mode-box", 1);
var roll_mode_armed_box = props.globals.getNode("/modes/pfd/fma/roll-mode-armed-box", 1);
var thr1 = props.globals.getNode("/controls/engines/engine[0]/throttle-pos", 1);
var thr2 = props.globals.getNode("/controls/engines/engine[1]/throttle-pos", 1);
var wow0 = props.globals.getNode("/gear/gear[0]/wow");
var wow1 = props.globals.getNode("/gear/gear[1]/wow");
var wow2 = props.globals.getNode("/gear/gear[2]/wow");
var pitch = props.globals.getNode("/orientation/pitch-deg", 1);
var roll = props.globals.getNode("/orientation/roll-deg", 1);
var elapsedtime = props.globals.getNode("/sim/time/elapsed-sec", 1);
var acess = props.globals.getNode("/systems/electrical/bus/ac-ess", 1);
var ac2 = props.globals.getNode("/systems/electrical/bus/ac2", 1);
var du1_lgt = props.globals.getNode("/controls/lighting/DU/du1", 1);
var du6_lgt = props.globals.getNode("/controls/lighting/DU/du6", 1);
var acconfig = props.globals.getNode("/systems/acconfig/autoconfig-running", 1);
var acconfig_mismatch = props.globals.getNode("/systems/acconfig/mismatch-code", 1);
var cpt_du_xfr = props.globals.getNode("/modes/cpt-du-xfr", 1);
var fo_du_xfr = props.globals.getNode("/modes/fo-du-xfr", 1);
var eng_out = props.globals.getNode("/systems/thrust/eng-out", 1);
var eng0_state = props.globals.getNode("/engines/engine[0]/state", 1);
var eng1_state = props.globals.getNode("/engines/engine[1]/state", 1);
var alpha_floor = props.globals.getNode("/systems/thrust/alpha-floor", 1);
var toga_lk = props.globals.getNode("/systems/thrust/toga-lk", 1);
var thrust_limit = props.globals.getNode("/controls/engines/thrust-limit", 1);
var flex = props.globals.getNode("/FMGC/internal/flex", 1);
var lvr_clb = props.globals.getNode("/systems/thrust/lvrclb", 1);
var throt_box = props.globals.getNode("/modes/pfd/fma/throttle-mode-box", 1);
var pitch_box = props.globals.getNode("/modes/pfd/fma/pitch-mode-box", 1);
var ap_box = props.globals.getNode("/modes/pfd/fma/ap-mode-box", 1);
var fd_box  = props.globals.getNode("/modes/pfd/fma/fd-mode-box", 1);
var at_box = props.globals.getNode("/modes/pfd/fma/athr-mode-box", 1);
var fbw_law = props.globals.getNode("/it-fbw/law", 1);
var ap_mode = props.globals.getNode("/modes/pfd/fma/ap-mode", 1);
var fd_mode = props.globals.getNode("/modes/pfd/fma/fd-mode", 1);
var at_mode = props.globals.getNode("/modes/pfd/fma/at-mode", 1);
var alt_std_mode = props.globals.getNode("/modes/altimeter/std", 1);
var alt_inhg_mode = props.globals.getNode("/modes/altimeter/inhg", 1);
var alt_hpa = props.globals.getNode("/instrumentation/altimeter/setting-hpa", 1);
var alt_inhg = props.globals.getNode("/instrumentation/altimeter/setting-inhg", 1);
var altitude = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
var altitude_pfd = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft-pfd", 1);
var alt_diff = props.globals.getNode("/instrumentation/pfd/alt-diff", 1);
var ap_alt = props.globals.getNode("/it-autoflight/internal/alt", 1);
var vs = props.globals.getNode("/instrumentation/vertical-speed-indicator/indicated-speed-fpm", 1);
var ap_vs_pfd = props.globals.getNode("/it-autoflight/internal/vert-speed-fpm-pfd", 1);
var athr_arm = props.globals.getNode("/modes/pfd/fma/athr-armed", 1);
var FMGC_max_spd = props.globals.getNode("/FMGC/internal/maxspeed", 1);
var ind_spd_kt = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1);
var ind_spd_mach = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-mach", 1);
var at_mach_mode = props.globals.getNode("/it-autoflight/input/kts-mach", 1);
var at_input_spd_mach = props.globals.getNode("/it-autoflight/input/spd-mach", 1);
var at_input_spd_kts = props.globals.getNode("/it-autoflight/input/spd-kts", 1);
var fd_roll = props.globals.getNode("/it-autoflight/fd/roll-bar", 1);
var fd_pitch = props.globals.getNode("/it-autoflight/fd/pitch-bar", 1);
var decision = props.globals.getNode("/instrumentation/mk-viii/inputs/arinc429/decision-height", 1);
var skid_slip = props.globals.getNode("/instrumentation/slip-skid-ball/indicated-slip-skid", 1);
var FMGCphase = props.globals.getNode("/FMGC/status/phase", 1);
var loc = props.globals.getNode("/instrumentation/nav[0]/heading-needle-deflection-norm", 1);
var gs = props.globals.getNode("/instrumentation/nav[0]/gs-needle-deflection-norm", 1);
var show_hdg = props.globals.getNode("/it-autoflight/custom/show-hdg", 1);
var ap_hdg = props.globals.getNode("/it-autoflight/input/hdg", 1);
var ap_trk_sw = props.globals.getNode("/it-autoflight/custom/trk-fpa", 1);
var ap_ils_mode = props.globals.getNode("/modes/pfd/ILS1", 1);
var ap_ils_mode2 = props.globals.getNode("/modes/pfd/ILS2", 1);
var loc_in_range = props.globals.getNode("/instrumentation/nav[0]/in-range", 1);
var gs_in_range = props.globals.getNode("/instrumentation/nav[0]/gs-in-range", 1);
var nav0_signalq = props.globals.getNode("/instrumentation/nav[0]/signal-quality-norm", 1);
var hasloc = props.globals.getNode("/instrumentation/nav[0]/nav-loc", 1);
var hasgs = props.globals.getNode("/instrumentation/nav[0]/has-gs", 1);
var pfdrate = props.globals.getNode("/systems/acconfig/options/pfd-rate", 1);
var managed_spd = props.globals.getNode("/it-autoflight/input/spd-managed", 1);
var at_tgt_ias = props.globals.getNode("/FMGC/internal/target-ias-pfd", 1);
var ap1 = props.globals.getNode("/it-autoflight/output/ap1", 1);
var ap2 = props.globals.getNode("/it-autoflight/output/ap2", 1);
var fd1 = props.globals.getNode("/it-autoflight/output/fd1", 1);
var fd2 = props.globals.getNode("/it-autoflight/output/fd2", 1);
var athr = props.globals.getNode("/it-autoflight/output/athr", 1);
var gear_agl = props.globals.getNode("/position/gear-agl-ft", 1);
var heading = props.globals.getNode("/orientation/heading-deg", 0.0, "DOUBLE");
var athr_mode = props.globals.getNode("/it-autoflight/mode/thr", "");
var lat_mode = props.globals.getNode("/it-autoflight/mode/lat", "");
var vert_mode = props.globals.getNode("/it-autoflight/mode/vert", "");

# Create Nodes:
var vs_needle = props.globals.initNode("/instrumentation/pfd/vs-needle", 0.0, "DOUBLE");
var alt_diff = props.globals.initNode("/instrumentation/pfd/alt-diff", 0.0, "DOUBLE");
var horizon_pitch = props.globals.initNode("/instrumentation/pfd/horizon-pitch", 0.0, "DOUBLE");
var horizon_ground = props.globals.initNode("/instrumentation/pfd/horizon-ground", 0.0, "DOUBLE");
var hdg_diff = props.globals.initNode("/instrumentation/pfd/hdg-diff", 0.0, "DOUBLE");
var hdg_scale = props.globals.initNode("/instrumentation/pfd/heading-scale", 0.0, "DOUBLE");
var track = props.globals.initNode("/instrumentation/pfd/track-deg", 0.0, "DOUBLE");
var track_diff = props.globals.initNode("/instrumentation/pfd/track-hdg-diff", 0.0, "DOUBLE");
var speed_pred = props.globals.initNode("/instrumentation/pfd/speed-lookahead", 0.0, "DOUBLE");


#roundToNearest function used for alt tape, thanks @Soitanen (737-800)!
var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}


var canvas_HUD_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
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
		
		me.horizon_trans = me["horizon"].createTransform();
		me.horizon_rot = me["horizon"].createTransform();

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return ["AI_center","horizon","rollpointer","rollpointer2","asi.100","asi.10","asi.rollingdigits","asi.tape","asi.trend.up","asi.trend.down","alt.10000","alt.1000","alt.100","alt.rollingdigits","altTextHigh1","altTextHigh2","altTextHigh3","altTextHigh4","altTextHigh5","altTextHigh6","altTextHigh7","altTextHighSmall1","altTextHighSmall2","altTextHighSmall3","altTextHighSmall4","altTextHighSmall5","altTextHighSmall6","altTextHighSmall7","altTextLow1","altTextLowSmall1","altTextLow2","altTextLowSmall2","altTextLow3","altTextLowSmall3","altTextLow4","altTextLowSmall4","altTextLow5","altTextLowSmall5","altTapeScale","compass","vs.text","radar.alt","radar.alt.box","gs","wind","selected.heading","qnh","adfL.freq","adfR.freq","heading.bug","heading.text","loc.complete","loc.needle","gs.complete","gs.needle","ap.alt.1","ap.alt.10000","ap.ann","athr.mode","lat.mode","vert.mode","hdg.scale","hdg.1","hdg.2","hdg.3","hdg.4","hdg.5"];
	},
	update: func() {
		if(getprop("systems/electrical/outputs/pfd[0]") >= 9){
			HUD_1.page.show();
			HUD_1.updateFast();
			HUD_1.update();
		}else{
			HUD_1.page.hide();
		}
	},
	updateSlow: func() {
		if (updateL) {
			HUD_1.update();
		}
		if (updateR) {
			HUD_2.update();
		}
	},
	updateCommon: func () {
		#Compass
		var hdg = heading.getValue();
		me["compass"].setRotation(-hdg*D2R);
		me["heading.text"].setText("H"~sprintf("%3d", math.round(hdg)));
		
		var hdg_bug=ap_hdg.getValue();
		me["heading.bug"].setRotation((hdg-hdg_bug)*-D2R);
		me["selected.heading"].setText(sprintf("%3d", math.round(hdg_bug)));
		
		#QNH
		var qnh = getprop("/instrumentation/altimeter/setting-hpa") or 0;
		me["qnh"].setText(sprintf("%4d", math.round(qnh)));
		
		#AP ALT
		var set_alt = ap_alt.getValue();
		
		if(set_alt<10000){
			me["ap.alt.10000"].hide();
		}else{
			me["ap.alt.10000"].show();
			me["ap.alt.10000"].setText(sprintf("%1d", math.floor(set_alt/10000, 10000)));
		}	
		me["ap.alt.1"].setText(sprintf("%04d", math.round(10000*math.mod(set_alt/10000,1))));
		
		#AP announcer
		var apon = getprop("/it-autoflight/output/ap1") == 1 or getprop("/it-autoflight/output/ap2") == 2 ;
		var fdon = getprop("/it-autoflight/output/fd1") == 1 or getprop("/it-autoflight/output/fd2") == 2 ;
		if(apon){
			me["ap.ann"].setText("A/P");
		}else if(fdon){
			me["ap.ann"].setText("FLT DIR");
		}else{
			me["ap.ann"].setText("");
		}
		
		me["athr.mode"].setText(athr_mode.getValue());
		me["lat.mode"].setText(lat_mode.getValue());
		me["vert.mode"].setText(vert_mode.getValue());
		
			
		
		
	},
	updateCommonFast: func() {
		# Airspeed
		ind_spd = ind_spd_kt.getValue() or 0;
		me["asi.100"].setText(sprintf("%1d", math.floor(ind_spd/100, 100)));
		me["asi.10"].setText(sprintf("%1d", math.round(10*math.mod(math.floor(ind_spd/10, 10)/10,1))));
		me["asi.rollingdigits"].setTranslation(0,math.round((10*math.mod(ind_spd/10,1))*49, 0.1));
		me["asi.tape"].setTranslation(0,ind_spd*7.27);
		#ASI Trend
		ASItrend = speed_pred.getValue() - ind_spd;
		me["asi.trend.up"].setTranslation(0, math.clamp(ASItrend, 0, 61) * -7.27);
		me["asi.trend.down"].setTranslation(0, math.clamp(ASItrend, -61, 0) * -7.27);
		
		if (ASItrend >= 2) {
			me["asi.trend.up"].show();
			me["asi.trend.down"].hide();
		} else if (ASItrend <= -2) {
			me["asi.trend.down"].show();
			me["asi.trend.up"].hide();
		} else {
			me["asi.trend.up"].hide();
			me["asi.trend.down"].hide();
		}
		
		#Altitude
		var alt = altitude.getValue();
		if(alt<1000){
			me["alt.1000"].hide();
			me["alt.10000"].hide();
		}else{
			if(alt<10000){
				me["alt.10000"].hide();
			}else{
				me["alt.10000"].show();
				me["alt.10000"].setText(sprintf("%1d", math.floor(alt/10000, 10000)));
			}
			me["alt.1000"].show();
			me["alt.1000"].setText(sprintf("%1d", math.round(10*math.mod(math.floor(alt/1000, 1000)/10,1))));
		}	
		me["alt.100"].setText(sprintf("%1d", math.round(10*math.mod(math.floor(alt/100, 100)/10,1))));
		me["alt.rollingdigits"].setTranslation(0,math.round((100*math.mod(alt/100,1))*3.73, 0.1));
		#3.73
		
		#Alt Tape
		
		me["altTapeScale"].setTranslation(0,(alt - roundToNearest(alt, 1000))*1.08);
		
		if (roundToNearest(alt, 1000) == 0) {
			me["altTextLowSmall1"].setText(sprintf("%3d",800));
			me["altTextLowSmall2"].setText(sprintf("%3d",600));
			me["altTextLowSmall3"].setText(sprintf("%3d",400));
			me["altTextLowSmall4"].setText(sprintf("%3d",200));
			me["altTextLowSmall5"].setText(sprintf("%3d",000));
			me["altTextHighSmall2"].setText(sprintf("%3d",200));
			me["altTextHighSmall3"].setText(sprintf("%3d",400));
			me["altTextHighSmall4"].setText(sprintf("%3d",600));
			me["altTextHighSmall5"].setText(sprintf("%3d",800));
			me["altTextHighSmall6"].setText(sprintf("%3d",000));
			me["altTextHighSmall7"].setText(sprintf("%3d",200));
			var altNumLow = "-";
			var altNumHigh = "";
			var altNumCenter = altNumHigh;
		} elsif (roundToNearest(alt, 1000) > 0) {
			me["altTextLowSmall1"].setText(sprintf("%3d",800));
			me["altTextLowSmall2"].setText(sprintf("%3d",600));
			me["altTextLowSmall3"].setText(sprintf("%3d",400));
			me["altTextLowSmall4"].setText(sprintf("%3d",200));
			me["altTextLowSmall5"].setText(sprintf("%3d",000));
			me["altTextHighSmall2"].setText(sprintf("%3d",200));
			me["altTextHighSmall3"].setText(sprintf("%3d",400));
			me["altTextHighSmall4"].setText(sprintf("%3d",600));
			me["altTextHighSmall5"].setText(sprintf("%3d",800));
			me["altTextHighSmall6"].setText(sprintf("%3d",000));
			me["altTextHighSmall7"].setText(sprintf("%3d",200));
			var altNumLow = roundToNearest(alt, 1000)/1000 - 1;
			var altNumHigh = roundToNearest(alt, 1000)/1000;
			var altNumCenter = altNumHigh;
		} elsif (roundToNearest(alt, 1000) < 0) {
			me["altTextLowSmall1"].setText(sprintf("%3d",200));
			me["altTextLowSmall2"].setText(sprintf("%3d",400));
			me["altTextLowSmall3"].setText(sprintf("%3d",600));
			me["altTextLowSmall4"].setText(sprintf("%3d",800));
			me["altTextLowSmall5"].setText(sprintf("%3d",000));
			me["altTextHighSmall2"].setText(sprintf("%3d",800));
			me["altTextHighSmall3"].setText(sprintf("%3d",600));
			me["altTextHighSmall4"].setText(sprintf("%3d",400));
			me["altTextHighSmall5"].setText(sprintf("%3d",200));
			me["altTextHighSmall6"].setText(sprintf("%3d",000));
			me["altTextHighSmall7"].setText(sprintf("%3d",800));
			var altNumLow = roundToNearest(alt, 1000)/1000;
			var altNumHigh = roundToNearest(alt, 1000)/1000 + 1;
			var altNumCenter = altNumLow;
		}
		if ( altNumLow == 0 ) {
			altNumLow = "";
		}
		if ( altNumHigh == 0 and alt < 0) {
			altNumHigh = "-";
		}
		me["altTextLow1"].setText(sprintf("%s", altNumLow));
		me["altTextLow2"].setText(sprintf("%s", altNumLow));
		me["altTextLow3"].setText(sprintf("%s", altNumLow));
		me["altTextLow4"].setText(sprintf("%s", altNumLow));
		me["altTextLow5"].setText(sprintf("%s", altNumLow));
		me["altTextHigh1"].setText(sprintf("%s", altNumCenter));
		me["altTextHigh2"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh3"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh4"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh5"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh6"].setText(sprintf("%s", altNumHigh));
		me["altTextHigh7"].setText(sprintf("%s", altNumHigh));
		
		
		# Attitude Indicator
		pitch_cur = pitch.getValue();
		roll_cur =  roll.getValue();
		
		me.horizon_trans.setTranslation(0, pitch_cur * 61.6);
		me.horizon_rot.setRotation(-roll_cur * D2R, me["AI_center"].getCenter());
		
		me["rollpointer2"].setTranslation(math.clamp(skid_slip.getValue(), -7, 7) * -15, 0);
		me["rollpointer"].setRotation(-roll_cur * D2R);
		
		#Heading on AI
		var hdg = heading.getValue();
		me.headOffset = hdg / 10 - int(hdg / 10);
		me.middleText = roundabout(hdg / 10);
		me.middleOffset = nil;
		if(me.middleText == 36) {
			me.middleText = 0;
		}
		me.leftText1 = me.middleText == 0?35:me.middleText - 1;
		me.rightText1 = me.middleText == 35?0:me.middleText + 1;
		me.leftText2 = me.leftText1 == 0?35:me.leftText1 - 1;
		me.rightText2 = me.rightText1 == 35?0:me.rightText1 + 1;
		me.leftText3 = me.leftText2 == 0?35:me.leftText2 - 1;
		me.rightText3 = me.rightText2 == 35?0:me.rightText2 + 1;
		if (me.headOffset > 0.5) {
			me.middleOffset = -(me.headOffset - 1) * 613;
		} else {
			me.middleOffset = -me.headOffset * 613;
		}
		me["hdg.scale"].setTranslation(me.middleOffset, 0);
		me["hdg.scale"].update();
		me["hdg.3"].setText(sprintf("%d", me.middleText));
		me["hdg.4"].setText(sprintf("%d", me.rightText1));
		me["hdg.2"].setText(sprintf("%d", me.leftText1));
		me["hdg.5"].setText(sprintf("%d", me.rightText2));
		me["hdg.1"].setText(sprintf("%d", me.leftText2));
		
		me["hdg.3"].setFontSize(fontSizeHDG(me.middleText), 1);
		me["hdg.4"].setFontSize(fontSizeHDG(me.rightText1), 1);
		me["hdg.2"].setFontSize(fontSizeHDG(me.leftText1), 1);
		me["hdg.5"].setFontSize(fontSizeHDG(me.rightText2), 1);
		me["hdg.1"].setFontSize(fontSizeHDG(me.leftText2), 1);
		
		#Vertical Speed
		var vertspeed = vs.getValue();
		me["vs.text"].setText(sprintf("%4d", math.round(vertspeed,10))~"VS");
		#me["vs.needle"].setRotation(vs_needle.getValue() * D2R);
		
		#Radar alt
		var gear_agl_cur = gear_agl.getValue();
		if(gear_agl_cur>2500){
			me["radar.alt"].hide();
		}else{
			me["radar.alt"].show();
			me["radar.alt"].setText(sprintf("%4d", math.round(gear_agl_cur)));
		}
		
		#ILS
		if(loc_in_range.getValue()==1){
			me["loc.complete"].show();
			me["loc.needle"].setTranslation(loc.getValue()*192,0);
		}else{
			me["loc.complete"].hide();
		}
		if(gs_in_range.getValue()==1){
			me["gs.complete"].show();
			me["gs.needle"].setTranslation(gs.getValue()*192,0);
		}else{
			me["gs.complete"].hide();
		}
		
		
	},
};

var canvas_HUD_1 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_HUD_1, canvas_HUD_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		me.updateCommon();
	},
	updateFast: func() {
		me.updateCommonFast();
	},
};

var canvas_HUD_2 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_HUD_2, canvas_HUD_base]};
		m.init(canvas_group, file);

		return m;
	},
	update: func() {
		
		me.updateCommon();
	},
	updateFast: func() {
		me.updateCommonFast();
	},
};

var canvas_HUD_1_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_HUD_1_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		et = elapsedtime.getValue() or 0;
		if ((du1_test_time.getValue() + 1 >= et) and cpt_du_xfr.getValue() != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du2_test_time.getValue() + 1 >= et) and cpt_du_xfr.getValue() != 0) {
			print(du2_test_time.getValue());
			print(elapsedtime.getValue());
			print(cpt_du_xfr.getValue());
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

var canvas_HUD_2_test = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_HUD_2_test]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["Test_white","Test_text"];
	},
	update: func() {
		et = elapsedtime.getValue() or 0;
		if ((du6_test_time.getValue() + 1 >= et) and fo_du_xfr.getValue() != 1) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else if ((du5_test_time.getValue() + 1 >= et) and fo_du_xfr.getValue() != 0) {
			me["Test_white"].show();
			me["Test_text"].hide();
		} else {
			me["Test_white"].hide();
			me["Test_text"].show();
		}
	},
};

var canvas_HUD_1_mismatch = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_HUD_1_mismatch]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ERRCODE"];
	},
	update: func() {
		me["ERRCODE"].setText(acconfig_mismatch.getValue());
	},
};

var canvas_HUD_2_mismatch = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});
		
		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
		}

		me.page = canvas_group;

		return me;
	},
	new: func(canvas_group, file) {
		var m = {parents: [canvas_HUD_2_mismatch]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ERRCODE"];
	},
	update: func() {
		me["ERRCODE"].setText(acconfig_mismatch.getValue());
	},
};

setlistener("sim/signals/fdm-initialized", func {
	HUD1_display = canvas.new({
		"name": "HUD1",
		"size": [2048, 1740],
		"view": [2048, 1740],
		"mipmapping": 1
	});
	#HUD2_display = canvas.new({
	#	"name": "HUD2",
	#	"size": [1024, 1024],
	#	"view": [1024, 1024],
	#	"mipmapping": 1
	#});
	HUD1_display.addPlacement({"node": "HUD1.screen"});
	#HUD2_display.addPlacement({"node": "pfd2.screen"});
	var group_pfd1 = HUD1_display.createGroup();
	#var group_pfd1_test = HUD1_display.createGroup();
	#var group_pfd1_mismatch = HUD1_display.createGroup();
	#var group_pfd2 = HUD2_display.createGroup();
	#var group_pfd2_test = HUD2_display.createGroup();
	#var group_pfd2_mismatch = HUD2_display.createGroup();

	HUD_1 = canvas_HUD_1.new(group_pfd1, "Aircraft/787-9/Models/Instruments/HUD/HUD.svg");
	#HUD_1_test = canvas_HUD_1_test.new(group_pfd1_test, "Aircraft/IDG-A32X/Models/Instruments/Common/res/du-test.svg");
	#HUD_1_mismatch = canvas_HUD_1_mismatch.new(group_pfd1_mismatch, "Aircraft/IDG-A32X/Models/Instruments/Common/res/mismatch.svg");
	#HUD_2 = canvas_HUD_2.new(group_pfd2, "Aircraft/IDG-A32X/Models/Instruments/HUD/res/pfd.svg");
	#HUD_2_test = canvas_HUD_2_test.new(group_pfd2_test, "Aircraft/IDG-A32X/Models/Instruments/Common/res/du-test.svg");
	#HUD_2_mismatch = canvas_HUD_2_mismatch.new(group_pfd2_mismatch, "Aircraft/IDG-A32X/Models/Instruments/Common/res/mismatch.svg");
	
	HUD_update.start();
	HUD_update_fast.start();
	
	if (pfdrate.getValue() == 1) {
		rateApply();
	}
});

var rateApply = func {
	HUD_update.restart(0.15 * pfdrate.getValue());
	HUD_update_fast.restart(0.05 * pfdrate.getValue());
}

var HUD_update = maketimer(0.15, func {
	canvas_HUD_base.updateSlow();
});

var HUD_update_fast = maketimer(0.05, func {
	canvas_HUD_base.update();
});

var showHUD1 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(HUD1_display);
}

var showHUD2 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(HUD2_display);
}

var roundabout = func(x) {
	var y = x - int(x);
	return y < 0.5 ? int(x) : 1 + int(x);
};

var roundaboutAlt = func(x) {
	var y = x * 0.2 - int(x * 0.2);
	return y < 0.5 ? 5 * int(x * 0.2) : 5 + 5 * int(x * 0.2);
};

var fontSizeHDG = func(input) {
	var test = input / 3;
	if (test == int(test)) {
		return 42;
	} else {
		return 32;
	}
};
