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
var PFD_avail = nil;
var PFD_display = nil;
var page = "only";
var DC=0.01744;

setprop("/it-autoflight/input/alt", 100000);
setprop("/instrumentation/PFD/ias-bugs/bug1", 0);
setprop("/instrumentation/PFD/ias-bugs/bug2", 0);
setprop("/instrumentation/PFD/DH", 200);
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
setprop("/engines/engine[1]/fuel-flow-pph", 0);
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
		if (getprop("/systems/electrical/volts") >= 10) {
			var mainpage=getprop("/instrumentation/mfd[0]/inputs/main-page") or 0;
			if(mainpage=="pfd"){
				PFD_avail.page.show();
				PFD_main.page.hide();
			}else{
				PFD_main.page.show();
				PFD_avail.page.hide();
				PFD_main.update();
			}
		} else {
			PFD_main.page.hide();
			PFD_avail.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_PFD_main = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_PFD_main,canvas_PFD_base] };
		m.init(canvas_group, file, "main");

		return m;
	},
	getKeys: func() {
		return ["ap-alt","ap-alt-capture","IASbug1","IASbug1symbol","IASbug1digit","IASbug2","IASbug2symbol","IASbug2digit","compassrose","IAS.100","IAS.10","ap-hdg","ap-hdg-bug","FMSNAVpointer","FMSNAVdeviation","NavFreq","FMSNAVRadial","FMSNAVdeflectionscale","FMSNAVtext","dh","radaralt","QNH","alt.1000","alt.100","alt.1","alt.1.top","alt.1.btm","VS","horizon","ladder","rollpointer","rollpointer2","asitape","asitapevmo","asi.trend.up","asi.trend.down","alt.tape","VS.needle","AP","ap.lat.engaged","ap.lat.armed","ap.vert.eng","ap.vert.value","ap.vert.arm","altTextLowSmall1","altTextHighSmall2","altTextLow1","altTextHigh1","altTextHigh2","alt.low.digits","alt.bug","alt.bug.top","alt.bug.btm","asi.rollingdigits","NavFreq"];
	},
	update: func() {
	
		#AUTOPILOT INDICATIONS
		#AP ON
		if((getprop("/it-autoflight/input/ap1") or 0)==1){
			me["AP"].show();
		}else{
			me["AP"].hide();
		}
		
		var ap_mode_lat=getprop("/it-autoflight/mode/lat");
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
		
		var ap_mode_arm=getprop("/it-autoflight/mode/arm");
		if(ap_mode_arm=="HDG"){
			me["ap.lat.armed"].setText("HDG");
		}else if(ap_mode_arm=="LOC" or ap_mode_arm=="ILS"){
			me["ap.lat.armed"].setText("LOC");
		}else{
			me["ap.lat.armed"].setText("");
		}
		
		var ap_mode_vert=getprop("it-autoflight/mode/vert");
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
			me["ap.vert.value"].setText(sprintf("%s", math.round(getprop("/it-autoflight/input/vs"))));
		}else if(ap_mode_vert=="G/A CLB"){
			me["ap.vert.eng"].setText("GA");
			me["ap.vert.value"].hide();
		}else if(ap_mode_vert=="SPD CLB" or ap_mode_vert=="SPD DSC"){
			me["ap.vert.eng"].setText("IAS");
			me["ap.vert.value"].show();
			me["ap.vert.value"].setText(sprintf("%s", math.round(getprop("/it-autoflight/input/spd-kts"))));
		}else{
			me["ap.vert.eng"].setText("");
			me["ap.vert.value"].hide();
		}
		
		me["ap.vert.arm"].hide();
		
		
		
		me["ap-alt"].setText(sprintf("%s", math.round(getprop("/it-autoflight/input/alt"))));
		
		var altbugdiff=getprop("/instrumentation/pfd/alt-bug-diff") or 0;
		if(altbugdiff<-500){
			me["alt.bug"].hide();
			me["alt.bug.btm"].show();
			me["alt.bug.top"].hide();
		}else if(altbugdiff>500){
			me["alt.bug"].hide();
			me["alt.bug.btm"].hide();
			me["alt.bug.top"].show();
		}else{
			me["alt.bug"].show();
			me["alt.bug.btm"].hide();
			me["alt.bug.top"].hide();
			me["alt.bug"].setTranslation(0,altbugdiff*(-0.5));
		}
		
		var ias_bug1=getprop("/instrumentation/PFD/ias-bugs/bug1");
		var ias_bug2=getprop("/instrumentation/PFD/ias-bugs/bug2");
		if(ias_bug1<50){
			me["IASbug1symbol"].hide();
			me["IASbug1digit"].hide();
			me["IASbug1"].hide();
		}else{
			me["IASbug1symbol"].show();
			me["IASbug1digit"].show();
			me["IASbug1"].show();
			me["IASbug1"].setTranslation(0,getprop("/instrumentation/pfd/ias-bug1-diff")*6.34);
			me["IASbug1digit"].setText(sprintf("%s", math.round(ias_bug1)));
		}
		if(ias_bug2<50){
			me["IASbug2symbol"].hide();
			me["IASbug2digit"].hide();
			me["IASbug2"].hide();
		}else{
			me["IASbug2symbol"].show();
			me["IASbug2digit"].show();
			me["IASbug2"].show();
			me["IASbug2"].setTranslation(0,getprop("/instrumentation/pfd/ias-bug2-diff")*6.34);
			me["IASbug2digit"].setText(sprintf("%s", math.round(ias_bug2)));
		}
		var airspeed=getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0;
		me["asitape"].setTranslation(0,airspeed*6.33);
		me["asitapevmo"].setTranslation(0,airspeed*6.33);
		var asi10=getprop("/instrumentation/pfd/asi-10") or 0;
		if(asi10!=0){
			me["IAS.10"].show();
			me["IAS.10"].setText(sprintf("%s", math.round((10*math.mod(asi10/10,1)))));
		}else{
			me["IAS.10"].hide();
		}
		var asi100=getprop("/instrumentation/pfd/asi-100") or 0;
		if(asi100!=0){
			me["IAS.100"].show();
			me["IAS.100"].setText(sprintf("%s", math.round(asi100)));
		}else{
			me["IAS.100"].hide();
		}
		me["asi.rollingdigits"].setTranslation(0,math.round((10*math.mod(airspeed/10,1))*42.86, 0.1));
		#me["asi.trend.up"].setTranslation(0,((getprop("/instrumentation/pfd/speed-trend-up")or 0)*(-230)));
		#me["asi.trend.down"].setTranslation(0,((getprop("/instrumentation/pfd/speed-trend-down")or 0)*(-230)));
		
		me["dh"].setText(sprintf("%s", math.round(getprop("/instrumentation/PFD/DH"))));
		me["compassrose"].setRotation((getprop("/orientation/heading-deg") or 0)*(-0.01744));
		#me["FMSNAVpointer"].setRotation((getprop("/orientation/heading-deg") or 0)*(0.01744));
		#me["FMSNAVdeviation"].setRotation((getprop("/orientation/heading-deg") or 0)*(0.01744));
		var hdgbugdiff=getprop("/instrumentation/pfd/hdg-bug-diff") or 0;
		me["ap-hdg-bug"].setRotation(hdgbugdiff*(-0.01744));
		
		me["ap-hdg"].setText(sprintf("%s", math.round(getprop("/it-autoflight/input/hdg") or 0)));
	
		var nav_source = getprop("/it-autoflight/settings/nav-source");
		me["FMSNAVtext"].setText(nav_source or "---");
		if(nav_source == "NAV1"){
			me["NavFreq"].show();
			me["NavFreq"].setText(sprintf("%3.2f", getprop("/instrumentation/nav[0]/frequencies/selected-mhz")));
			if((getprop("/instrumentation/nav[0]/in-range") or 0)==1){
				me["FMSNAVpointer"].show();
				me["FMSNAVdeviation"].show();			
				me["FMSNAVdeviation"].setTranslation((getprop("/instrumentation/nav[0]/heading-needle-deflection-norm") or 0)*130, 0);		
				me["NavFreq"].setText(sprintf("%s", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt") or 0));
				me["FMSNAVRadial"].setText(sprintf("%s", getprop("/instrumentation/nav[0]/radials/target-radial-deg") or 0));
				var nav0_radialdiff=(getprop("/orientation/heading-deg") or 0)-(getprop("/instrumentation/nav[0]/radials/target-radial-deg") or 0);
				me["FMSNAVpointer"].setRotation(nav0_radialdiff*(-DC));
				me["FMSNAVdeviation"].setRotation(nav0_radialdiff*(-DC));
				me["FMSNAVdeflectionscale"].setRotation(nav0_radialdiff*(-DC));
				
			
			}else{
				me["FMSNAVpointer"].hide();
				me["FMSNAVdeviation"].hide();			
			}
		}else if(nav_source == "NAV2"){
			me["NavFreq"].show();
			me["NavFreq"].setText(sprintf("%3.2f", getprop("/instrumentation/nav[1]/frequencies/selected-mhz")));
			if((getprop("/instrumentation/nav[1]/in-range") or 0)==1){
				me["FMSNAVpointer"].show();
				me["FMSNAVdeviation"].show();			
				me["FMSNAVdeviation"].setTranslation((getprop("/instrumentation/nav[1]/heading-needle-deflection-norm") or 0)*130, 0);		
				me["NavFreq"].setText(sprintf("%s", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt") or 0));
				me["FMSNAVRadial"].setText(sprintf("%s", getprop("/instrumentation/nav[1]/radials/target-radial-deg") or 0));
				var nav1_radialdiff=(getprop("/orientation/heading-deg") or 0)-(getprop("/instrumentation/nav[1]/radials/target-radial-deg") or 0);
				me["FMSNAVpointer"].setRotation(nav1_radialdiff*(-DC));
				me["FMSNAVdeviation"].setRotation(nav1_radialdiff*(-DC));
				me["FMSNAVdeflectionscale"].setRotation(nav1_radialdiff*(-DC));
				
			
			}else{
				me["FMSNAVpointer"].hide();
				me["FMSNAVdeviation"].hide();			
			}
		}else if(nav_source == "FMS"){
			me["NavFreq"].hide();
		}
		
		var radaralti=getprop("/position/gear-agl-ft") or 0;
		if(radaralti<2500 and radaralti>0){
			me["radaralt"].show();
			me["radaralt"].setText(sprintf("%s", math.round(radaralti)));
		}else{
			me["radaralt"].hide();
		}
			
			
		me["QNH"].setText(sprintf("%s", math.round(getprop("/instrumentation/altimeter/setting-hpa"))));
		
		var alt=getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0;

		me["alt.tape"].setTranslation(0,(alt - roundToNearest(alt, 1000))*0.4933);
		if (roundToNearest(alt, 1000) == 0) {
			#me["altTextLowSmall1"].setText(sprintf("%0.0f",5));
			#me["altTextHighSmall2"].setText(sprintf("%0.0f",5));
			var altNumLow = "-5";
			var altNumHigh = "5";
			var altNumCenter = altNumHigh-5;
		} elsif (roundToNearest(alt, 1000) > 0) {
			#me["altTextLowSmall1"].setText(sprintf("%0.0f",5));
			#me["altTextHighSmall2"].setText(sprintf("%0.0f",5));
			var altNumLow = (roundToNearest(alt, 1000)/1000 - 1)*10+5;
			var altNumHigh = (roundToNearest(alt, 1000)/1000)*10+5;
			var altNumCenter = altNumHigh-5;
		} elsif (roundToNearest(alt, 1000) < 0) {
			#me["altTextLowSmall1"].setText(sprintf("%0.0f",5));
			#me["altTextHighSmall2"].setText(sprintf("%0.0f",5));
			var altNumLow = roundToNearest(alt, 1000)/100+5;
			var altNumHigh = (roundToNearest(alt, 1000)/1000 + 1)*10+5 ;
			var altNumCenter = altNumLow-5;
		}
		if ( altNumLow == 0 ) {
			altNumLow = "";
		}
		if ( altNumHigh == 0 and alt < 0) {
			altNumHigh = "-";
		}
		
		var alt100=(getprop("/instrumentation/PFD/alt-1") or 0)/100;
		
		me["alt.low.digits"].setTranslation(0,math.round((10*math.mod(alt100,1))*15, 0.1));
		
		me["altTextLow1"].setText(sprintf("%s", altNumLow));
		me["altTextHigh1"].setText(sprintf("%s", altNumCenter));
		me["altTextHigh2"].setText(sprintf("%s", altNumHigh));
		
		
		me["alt.1000"].setText(sprintf("%3d", getprop("/instrumentation/PFD/alt-1000")));
		me["alt.100"].setText(sprintf("%s", int(10*math.mod((getprop("/instrumentation/PFD/alt-100") or 0)/10,1))));
		
		var fpm=getprop("/velocities/vertical-speed-fps")*60;
		me["VS"].setText(sprintf("%.1f", (fpm or 0)/1000));
		me["VS.needle"].setRotation((getprop("/instrumentation/pfd/vs-needle") or 0)*DC);
		
		var pitch = (getprop("orientation/pitch-deg") or 0);
		var roll =  getprop("orientation/roll-deg") or 0;
		var x=math.sin(-3.14/180*roll)*pitch*10.6;
		var y=math.cos(-3.14/180*roll)*pitch*10.6;
		
		#me["horizon"].setTranslation(x,y);
		#me["horizon"].setRotation(roll*(-DC),me["horizon"].getCenter());
		
		me.h_trans.setTranslation(0,pitch*10.63);
		me.h_rot.setRotation(-roll*DC,me["horizon"].getCenter());
		
		me["rollpointer"].setRotation(roll*(-DC));
		me["rollpointer2"].setTranslation(math.round(getprop("/instrumentation/slip-skid-ball/indicated-slip-skid") or 0)*5, 0);
		
		
		
		
	},
};

var canvas_PFD_avail = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_PFD_avail,canvas_PFD_base] };
		m.init(canvas_group, file, "avail");

		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		
		settimer(func me.update(), 0.02);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	PFD_display = canvas.new({
		"name": "PFD",
		"size": [1024, 1536],
		"view": [1024, 1536],
		"mipmapping": 1
	});
	PFD_display.addPlacement({"node": "PFD.screen"});
	var groupPFDmain = PFD_display.createGroup();
	var groupPFDavail = PFD_display.createGroup();

	PFD_main = canvas_PFD_main.new(groupPFDmain, "Aircraft/Q400/Models/Cockpit/Instruments/PFD/PFD.svg");
	PFD_avail = canvas_PFD_avail.new(groupPFDavail, "Aircraft/Q400/Models/Cockpit/Instruments/PFD/PFDavail.svg");

	PFD_main.update();
	PFD_avail.update();
	canvas_PFD_base.update();
});

var showPFD = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(PFD_display);
}
