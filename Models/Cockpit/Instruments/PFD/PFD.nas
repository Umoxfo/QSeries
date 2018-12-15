# Q400 PFD by D-ECHO based on
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

var PFD_main = nil;
var PFD_display = nil;
var page = "only";

#All properties used...
#...in fast update:
var IAS_bug1 = props.globals.getNode("/instrumentation/PFD/ias-bugs/bug1",1);
var IAS_bug1diff = props.globals.getNode("/instrumentation/PFD/ias-bugs/bug1-diff", 1);
var IAS_bug1 = props.globals.getNode("/instrumentation/PFD/ias-bugs/bug2",1);
var IAS_bug2diff = props.globals.getNode("/instrumentation/PFD/ias-bugs/bug2-diff", 1);
var IAS = props.globals.getNode("/instrumentation/airspeed-indicator/indicated-speed-kt", 1);
var IAS_10 = props.globals.getNode("/instrumentation/pfd/asi-10", 1);
var IAS_100 = props.globals.getNode("/instrumentation/pfd/asi-100", 1);
var Heading_magnetic = props.globals.getNode("/orientation/heading-magnetic-deg", 1);
var ALT_bugdiff = props.globals.getNode("/instrumentation/pfd/alt-bug-diff", 1);
var ALT = props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
var ALT_1000 = props.globals.getNode("/instrumentation/PFD/alt-1000", 1);
var ALT_100 = props.globals.getNode("/instrumentation/PFD/alt-100", 1);
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
var AP_ap1 = props.globals.getNode("/it-autoflight/input/ap1", 1);
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
var DecHei = props.globals.getNode("/instrumentation/PFD/DH", 1);
var RM_cur_wp = props.globals.getNode("/autopilot/route-manager/current-wp", 1);


var Volts = props.globals.getNode("/systems/electrical/volts", 1);
var MainPage = props.globals.getNode("/instrumentation/mfd[0]/inputs/main-page", 1);


#init
var IAS_bug1 = props.globals.initNode("/instrumentation/PFD/ias-bugs/bug1", 0.0, "DOUBLE");
var IAS_bug2 = props.globals.initNode("/instrumentation/PFD/ias-bugs/bug2", 0.0, "DOUBLE");
var IAS_10 = props.globals.initNode("/instrumentation/pfd/asi-10", 0.0, "DOUBLE");
var IAS_100 = props.globals.initNode("/instrumentation/pfd/asi-100", 0.0, "DOUBLE");
var ALT_bugdiff = props.globals.initNode("/instrumentation/pfd/alt-bug-diff", 0.0, "DOUBLE");
var ALT_1000 = props.globals.initNode("/instrumentation/PFD/alt-1000", 0.0, "DOUBLE");
var ALT_100 = props.globals.initNode("/instrumentation/PFD/alt-100", 0.0, "DOUBLE");
var VS_needle = props.globals.initNode("/instrumentation/pfd/vs-needle", 0.0, "DOUBLE");
var Heading_bugdiff = props.globals.initNode("/instrumentation/pfd/hdg-bug-diff", 0.0, "DOUBLE");
var DecHei = props.globals.initNode("/instrumentation/PFD/DH", 0.0, "DOUBLE");
var Volts = props.globals.initNode("/systems/electrical/volts", 0.0,  "DOUBLE");
var MainPage = props.globals.initNode("/instrumentation/mfd[0]/inputs/main-page","", "STRING");


setprop("/it-autoflight/input/alt", 100000);
setprop("/test-hdg", 180);
setprop("/engines/engine[1]/thruster/torque", 0);
setprop("/engines/engine[0]/thruster/rpm", 0);
setprop("/engines/engine[1]/thruster/rpm", 0);
setprop("/engines/engine[0]/itt_degc", 0);
setprop("/engines/engine[1]/itt_degc", 0);
setprop("/engines/engine[0]/oil-pressure-psi", 0);
setprop("/MFD/oil-pressure-needle[0]", 0);
setprop("/engines/engine[1]/oil-pressure-psi", 0);
setprop("/MFD/oil-pressure-needle[1]", 0);
setprop("/engines/engine[0]/oil-temperature-degc", 0);
setprop("/MFD/oil-temperature-needle[0]", 0);
setprop("/engines/engine[1]/oil-temperature-degc", 0);
setprop("/MFD/oil-temperature-needle[1]", 0);
setprop("/engines/engine[0]/fuel-flow-pph", 0);
setprop("/engines/engine[1]/fuel-flsow-pph", 0);
setprop("/consumables/fuel/tank[0]/temperature-degc", 0);
setprop("/consumables/fuel/tank[1]/temperature-degc", 0);
setprop("/controls/engines/engine[0]/condition-lever-state", 0);
setprop("/controls/engines/engine[1]/condition-lever-state", 0);
setprop("/controls/engines/engine[0]/throttle-int", 0);
setprop("/controls/engines/engine[1]/throttle-int", 0);

setprop("/test-value", 1);

var canvas_PFD_base = {
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
				PFD_main.page.hide();
			}else{
				PFD_main.page.show();
			}
		} else {
			PFD_main.page.hide();
		}
		
		settimer(func me.update(), 0.1);
	},
};

var canvas_PFD_main = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_PFD_main,canvas_PFD_base] };
		m.init(canvas_group, file, "main");

		return m;
	},
	getKeys: func() {
		return ["ap-alt","ap-alt-capture","IASbug1","IASbug1symbol","IASbug1digit","IASbug2","IASbug2symbol","IASbug2digit","compassrose","IAS.100","IAS.10","ap-hdg","ap-hdg-bug","FMSNAVpointer","FMSNAVdeviation","FMSNAVId","FMSNAVRadial","FMSNAVdeflectionscale","FMSNAVtext","FMSNAVDist","FMSNAVtofrom","dh","radaralt","QNH","alt.1000","alt.100","alt.1","alt.1.top","alt.1.btm","VS","horizon","ladder","rollpointer","rollpointer2","asitape","asitapevmo","asi.trend.up","asi.trend.down","alt.tape","VS.needle","AP","ap.lat.engaged","ap.lat.armed","ap.vert.eng","ap.vert.value","ap.vert.arm","altTextLowSmall1","altTextHighSmall2","altTextLow1","altTextHigh1","altTextHigh2","alt.low.digits","alt.bug","asi.rollingdigits","ADF1symbol","ADF1text","ADF1ind","ADF2text","ADF2symbol","ADF2ind","DMEdist","alt.ground","LOCGroup","GSGroup","loc.pointer","gs.pointer"];
	},
	fast_update: func() {
		#Airspeed Indicator
		#IAS Bugs
		var ias_bug_1=IAS_bug1.getValue();
		var ias_bug_2=IAS_bug2.getValue();
		var ias_bug_1_diff=IAS_bug1diff.getValue();
		var ias_bug_2_diff=IAS_bug2diff.getValue();
		
		if(ias_bug_1<50){
			me["IASbug1symbol"].hide();
			me["IASbug1digit"].hide();
			me["IASbug1"].hide();
		}else{
			me["IASbug1symbol"].show();
			me["IASbug1digit"].show();
			me["IASbug1"].show();
			me["IASbug1"].setTranslation(0,ias_bug_1_diff*6.34);
			me["IASbug1digit"].setText(sprintf("%s", math.round(ias_bug1)));
		}
		if(ias_bug_2<50){
			me["IASbug2symbol"].hide();
			me["IASbug2digit"].hide();
			me["IASbug2"].hide();
		}else{
			me["IASbug2symbol"].show();
			me["IASbug2digit"].show();
			me["IASbug2"].show();
			me["IASbug2"].setTranslation(0,ias_bug_2_diff*6.34);
			me["IASbug2digit"].setText(sprintf("%s", math.round(ias_bug2)));
		}
		var airspeed=IAS.getValue();
		#Airspeed Tape
		me["asitape"].setTranslation(0,airspeed*6.33);
		me["asitapevmo"].setTranslation(0,airspeed*6.33);
		#Airspeed Digital Indication
		var asi10=IAS_10.getValue();
		if(asi10!=0){
			me["IAS.10"].show();
			me["IAS.10"].setText(sprintf("%s", math.round((10*math.mod(asi10/10,1)))));
		}else{
			me["IAS.10"].hide();
		}
		var asi100=IAS_100.getValue();
		if(asi100!=0){
			me["IAS.100"].show();
			me["IAS.100"].setText(sprintf("%s", math.round(asi100)));
		}else{
			me["IAS.100"].hide();
		}
		me["asi.rollingdigits"].setTranslation(0,math.round((10*math.mod(airspeed/10,1))*42.86, 0.1));
		
		var heading=Heading_magnetic.getValue();
		me["compassrose"].setRotation(heading*(-0.01744));
		
		
		#Altimeter
		#Altitude Bug
		var altbugdiff=ALT_bugdiff.getValue();
		if(altbugdiff<-500){
			me["alt.bug"].setTranslation(0,250);
		}else if(altbugdiff>500){
			me["alt.bug"].setTranslation(0,-250);
		}else{
			me["alt.bug"].setTranslation(0,altbugdiff*(-0.5));
		}
		
		#Alt Tape
		var altitude=ALT.getValue();
		me["alt.tape"].setTranslation(0,(altitude - roundToNearest(altitude, 1000))*0.4933);
		if (roundToNearest(altitude, 1000) == 0) {
			var altNumLow = "-5"; props.globals.getNode("/instrumentation/altimeter/indicated-altitude-ft", 1);
			var altNumHigh = "5";
			var altNumCenter = altNumHigh-5;
		} elsif (roundToNearest(altitude, 1000) > 0) {
			var altNumLow = (roundToNearest(altitude, 1000)/1000 - 1)*10+5;
			var altNumHigh = (roundToNearest(altitude, 1000)/1000)*10+5;
			var altNumCenter = altNumHigh-5;
		} elsif (roundToNearest(altitude, 1000) < 0) {
			var altNumLow = roundToNearest(altitude, 1000)/100+5;
			var altNumHigh = (roundToNearest(altitude, 1000)/1000 + 1)*10+5 ;
			var altNumCenter = altNumLow-5;
		}
		if ( altNumLow == 0 ) {
			altNumLow = "";
		}
		if ( altNumHigh == 0 and altitude < 0) {
			altNumHigh = "-";
		}
		
		
		me["altTextLow1"].setText(sprintf("%s", altNumLow));
		me["altTextHigh1"].setText(sprintf("%s", altNumCenter));
		me["altTextHigh2"].setText(sprintf("%s", altNumHigh));
		
		
		#Altitude Digital Indication		
		me["alt.low.digits"].setTranslation(0,math.round((10*math.mod(altitude/100,1))*15, 0.1));
		me["alt.1000"].setText(sprintf("%3d", ALT_1000.getValue()));
		me["alt.100"].setText(sprintf("%1d", int(10*math.mod(ALT_100.getValue()/10,1))));
		
		#Alt above Ground, Radar alt and ground on alt tape
		var agl = ALT_AGL.getValue() + 5.5;
		if(agl<2500){
			me["radaralt"].show();
			me["radaralt"].setText(sprintf("%4d", math.round(agl)));
			if(agl<550){
				me["alt.ground"].show();
				me["alt.ground"].setTranslation(0,agl*0.4933);
			}else{
				me["alt.ground"].hide();
			}
		}else{
			me["radaralt"].hide();
			me["alt.ground"].hide();
		}
		
		
		#Vertical Speed Indicator
		var fpm=VS.getValue();
		me["VS"].setText(sprintf("%.1f", fpm/1000));
		me["VS.needle"].setRotation(VS_needle.getValue()*D2R);
		
		#Attitude Indicator
		var pitch = AI_pitch.getValue();
		var roll =  AI_roll.getValue();
		
		me.h_trans.setTranslation(0,pitch*10.63);
		me.h_rot.setRotation(-roll*D2R,me["horizon"].getCenter());
		
		me["rollpointer"].setRotation(-roll*D2R);
		me["rollpointer2"].setTranslation(math.round(Slip_Skid.getValue()*5), 0);
		
		#ILS
		var navsrc = AP_navsource.getValue();
		if(navsrc=="NAV1"){
			var nav0isloc = NAV0_isloc.getValue() or 0;
			if(nav0isloc==1){
				me["LOCGroup"].show();
				var nav0dev = NAV0_defl.getValue() or 0;
				me["loc.pointer"].setTranslation(nav0dev*88,0);
			}else{
				me["LOCGroup"].hide();
			}
			var nav0isgs = NAV0_hasgs.getValue() or 0;
			if(nav0isgs==1){
				me["GSGroup"].show();
				var nav0gs = NAV0_gsdefl.getValue() or 0;
				me["gs.pointer"].setTranslation(0,nav0gs*129);
			}else{
				me["GSGroup"].hide();
			}
		}else if(navsrc=="NAV2"){
			var nav1isloc = NAV1_isloc.getValue() or 0;
			if(nav1isloc==1){
				me["LOCGroup"].show();
				var nav0dev = NAV1_defl.getValue() or 0;
				me["loc.pointer"].setTranslation(nav0dev*88,0);
			}else{
				me["LOCGroup"].hide();
			}
			var nav1isgs = NAV1_hasgs.getValue() or 0;
			if(nav1isgs==1){
				me["GSGroup"].show();
				var nav0gs = NAV1_gsdefl.getValue() or 0;
				me["gs.pointer"].setTranslation(0,nav1gs*129);
			}else{
				me["GSGroup"].hide();
			}
		}else{
			me["LOCGroup"].hide();
			me["GSGroup"].hide();
		}
		
		
		settimer(func me.fast_update(), 0.05);
	},
	slow_update: func() {
		
		#AUTOPILOT INDICATIONS
		#AP ON
		if(AP_ap1.getValue()==1){
			me["AP"].show();
		}else{
			me["AP"].hide();
		}
		
		var ap_mode_lat=AP_modelat.getValue();
		if(ap_mode_lat=="T/O"){
			me["ap.lat.engaged"].setText("ROLL  HOLD");
		}else if(ap_mode_lat=="HDG"){
			me["ap.lat.engaged"].setText("HDG  HOLD");
		}else if(ap_mode_lat=="LNAV"){
			me["ap.lat.engaged"].setText("LNAV");
		}else if(ap_mode_lat=="ALGN"){
			me["ap.lat.engaged"].setText("LOC*");
		}else if(ap_mode_lat=="LOC"){
			me["ap.lat.engaged"].setText("LOC");
		}else{
			me["ap.lat.engaged"].setText("");
		}
		
		var ap_mode_arm=AP_modearm.getValue();
		if(ap_mode_arm=="HDG"){
			me["ap.lat.armed"].setText("HDG");
		}else if(ap_mode_arm=="LOC" or ap_mode_arm=="ILS"){
			me["ap.lat.armed"].setText("LOC");
		}else{
			me["ap.lat.armed"].setText("");
		}
		
		var ap_mode_vert=AP_modevert.getValue();
		if(ap_mode_vert=="ALT CAP"){
			me["ap.vert.eng"].setText("ALT*");
			me["ap.vert.value"].hide();
		}else if(ap_mode_vert=="FPA"){
			me["ap.vert.eng"].setText("VNAV PATH");
			me["ap.vert.value"].hide();
		}else if(ap_mode_vert=="ALT HLD"){
			me["ap.vert.eng"].setText("ALT");
			me["ap.vert.value"].hide();
		}else if(ap_mode_vert=="G/S"){
			me["ap.vert.eng"].setText("GS");
			me["ap.vert.value"].hide();
		}else if(ap_mode_vert=="V/S"){
			me["ap.vert.eng"].setText("VS");
			me["ap.vert.value"].show();
			me["ap.vert.value"].setText(sprintf("%4d", math.round(AP_vs.getValue())));
		}else if(ap_mode_vert=="G/A CLB"){
			me["ap.vert.eng"].setText("GA");
			me["ap.vert.value"].hide();
		}else if(ap_mode_vert=="SPD CLB" or ap_mode_vert=="SPD DSC"){
			me["ap.vert.eng"].setText("IAS");
			me["ap.vert.value"].show();
			me["ap.vert.value"].setText(sprintf("%3d", math.round(AP_ias.getValue())));
		}else{
			me["ap.vert.eng"].setText("");
			me["ap.vert.value"].hide();
		}
		
			
		me["ap.vert.arm"].hide();
				
		me["ap-alt"].setText(sprintf("%5d", math.round(AP_alt.getValue())));
		
		var heading=Heading_magnetic.getValue();
		
		var hdgbugdiff=Heading_bugdiff.getValue();
		me["ap-hdg-bug"].setRotation(hdgbugdiff*(-D2R));
		
		me["ap-hdg"].setText(sprintf("%s", math.round(AP_hdg.getValue() or 0)));
		
		
	
		var nav_source = AP_navsource.getValue();
		me["FMSNAVtext"].setText(nav_source or "---");
		if(nav_source == "NAV1"){
			me["FMSNAVRadial"].setColor(0,1,1);
			me["FMSNAVId"].setColor(0,1,1);
			me["FMSNAVtofrom"].show();	
			me["FMSNAVId"].setText(sprintf("%3.2f", NAV0_freq.getValue()));
			var trgt_radial0 = NAV0_rad.getValue() or 0;
			me["FMSNAVRadial"].setText(sprintf("%3d", math.round(trgt_radial0)));
			if(NAV0_inrange.getValue()==1){
				me["FMSNAVpointer"].show();
				var nav0_radialdiff=heading-trgt_radial0;
				me["FMSNAVpointer"].setRotation(nav0_radialdiff*(-D2R));
				me["FMSNAVdeflectionscale"].setRotation(nav0_radialdiff*(-D2R));
				me["FMSNAVdeviation"].setTranslation(NAV0_defl.getValue()*130, 0);
				if(NAV0_dme_inrange.getValue()==1){
					var nav0_dist = NAV0_dme.getValue();
					if(nav0_dist>=10){
						me["FMSNAVDist"].setText(sprintf("%3d", nav0_dist));
					}else{
						me["FMSNAVDist"].setText(sprintf("%2.1f", nav0_dist));
					}
				}else{
					me["FMSNAVDist"].setText("---");
				}
				if(NAV0_tofrom.getValue()==1){
					me["FMSNAVtofrom"].setRotation(180*D2R);
				}else{
					me["FMSNAVtofrom"].setRotation(0);
				}
			}else{
				me["FMSNAVpointer"].hide();
				me["FMSNAVDist"].setText("---");
			}
		}else if(nav_source == "NAV2"){
			me["FMSNAVRadial"].setColor(0,1,1);
			me["FMSNAVId"].setColor(0,1,1);
			me["FMSNAVtofrom"].show();
			me["FMSNAVId"].setText(sprintf("%3.2f", NAV1_freq.getValue()));
			var trgt_radial1 = NAV1_rad.getValue() or 0;
			me["FMSNAVRadial"].setText(sprintf("%3d", math.round(trgt_radial1)));
			if(NAV1_inrange.getValue()==1){
				me["FMSNAVpointer"].show();		
				me["FMSNAVdeviation"].setTranslation(NAV1_defl.getValue()*130, 0);
				var nav1_radialdiff=heading-trgt_radial1;
				me["FMSNAVpointer"].setRotation(nav1_radialdiff*(-D2R));
				me["FMSNAVdeflectionscale"].setRotation(nav1_radialdiff*(-D2R));				
				if(NAV1_dme_inrange.getValue()==1){
					var nav1_dist = NAV1_dme.getValue();
					if(nav0_dist>=10){
						me["FMSNAVDist"].setText(sprintf("%3d", nav1_dist));
					}else{
						me["FMSNAVDist"].setText(sprintf("%2.1f", nav1_dist));
					}
				}else{
					me["FMSNAVDist"].setText("---");
				}
				if(NAV1_tofrom.getValue()==1){
					me["FMSNAVtofrom"].setRotation(180*D2R);
				}else{
					me["FMSNAVtofrom"].setRotation(0);
				}
			}else{
				me["FMSNAVpointer"].hide();
				me["FMSNAVDist"].setText("---");			
			}
		}else if(nav_source == "FMS"){
			me["FMSNAVRadial"].setColor(1,0,1);
			me["FMSNAVId"].setColor(1,0,1);
			me["FMSNAVpointer"].show();
			var current_wp = RM_cur_wp.getValue();
			if(current_wp==-1){
				me["FMSNAVRadial"].setText("---");
			}else{
				var brg = getprop("/autopilot/route-manager/route/wp["~current_wp~"]/leg-bearing-true-deg") or 0;
				var dst = getprop("/autopilot/route-manager/route/wp["~current_wp~"]/leg-distance-nm") or 0;
				var wp_id = getprop("/autopilot/route-manager/route/wp["~current_wp~"]/id") or "---";
				me["FMSNAVRadial"].setText(sprintf("%3d", brg));
				me["FMSNAVDist"].setText(sprintf("%2.1f", dst));
				me["FMSNAVId"].setText(wp_id);
			}
			me["FMSNAVtofrom"].hide();
		}else{
			me["FMSNAVRadial"].setColorFill(1,1,1);
			me["FMSNAVRadial"].setText("---");
			me["FMSNAVDist"].setText("---");
			me["FMSNAVId"].setText("---");
		}
		


		if(ADF0_inrange.getValue()==1){
			me["ADF1text"].show();
			me["ADF1symbol"].show();
			me["ADF1ind"].show();
			var ADF1_bearing=ADF0_brg.getValue();
			me["ADF1ind"].setRotation(ADF1_bearing*D2R);
		}else{
			me["ADF1text"].hide();
			me["ADF1symbol"].hide();
			me["ADF1ind"].hide();
		}
		
		if(ADF1_inrange.getValue()==1){
			me["ADF2text"].show();
			me["ADF2symbol"].show();
			me["ADF2ind"].show();
			var ADF2_bearing=ADF1_brg.getValue();
			me["ADF2ind"].setRotation(ADF2_bearing*D2R);
		}else{
			me["ADF2text"].hide();
			me["ADF2symbol"].hide();
			me["ADF2ind"].hide();
		}

		var dme_distance = DME_dist.getValue() or 0;
		if(dme_distance>=10){
			me["DMEdist"].setText(sprintf("%3d", math.round(dme_distance)));
		}else{
			me["DMEdist"].setText(sprintf("%2.1f", dme_distance));
		}
		
		
			
		me["QNH"].setText(sprintf("%4d", ALT_qnh.getValue()));
		

	
		settimer(func me.slow_update(), 0.2);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	PFD_display = canvas.new({
		"name": "PFD",
		"size": [512, 768],
		"view": [1024, 1536],
		"mipmapping": 1
	});
	PFD_display.addPlacement({"node": "PFD.screen"});
	PFD_display.addPlacement({"node": "MFDpilot.screenPFD"});
	PFD_display.addPlacement({"node": "MFDcopilot.screenPFD"});
	var groupPFDmain = PFD_display.createGroup();

	PFD_main = canvas_PFD_main.new(groupPFDmain, "Aircraft/Q400/Models/Cockpit/Instruments/PFD/PFD.svg");

	PFD_main.fast_update();
	PFD_main.slow_update();
	canvas_PFD_base.update();
});

var showPFD = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(PFD_display);
}
