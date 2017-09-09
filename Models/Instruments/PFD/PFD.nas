# Q400 PFD by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Autoflight.pdf http://www.smartcockpit.com/docs/Q400-Navigation_1.pdf http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var PFD_only = nil;
var PFD_avail = nil;
var PFD_display = nil;
var page = "only";

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

var canvas_PFD_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {'font-mapper': font_mapper});

		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
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
				PFD_only.page.hide();
			}else{
				PFD_only.page.show();
				PFD_avail.page.hide();
			}
		} else {
			PFD_only.page.hide();
			PFD_avail.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_PFD_only = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_PFD_only,canvas_PFD_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ap-alt","ap-alt-capture","IASbug1","IASbug1symbol","IASbug1digit","IASbug2","IASbug2symbol","IASbug2digit","compassrose","IAS","ap-hdg","ap-hdg-bug","FMSNAVpointer","FMSNAVdeviation","NavFreq","FMSNAVRadial","FMSNAVdeflectionscale","FMSNAVtext","dh","radaralt","QNH","alt.1000","alt.100","alt.1","alt.1.top","alt.1.btm","VS","horizon"];
	},
	update: func() {
	
		me["ap-alt"].setText(sprintf("%s", math.round(getprop("/it-autoflight/input/alt"))));
		
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
			me["IASbug2digit"].setText(sprintf("%s", math.round(ias_bug2)));
		}
		
		me["dh"].setText(sprintf("%s", math.round(getprop("/instrumentation/PFD/DH"))));
		me["compassrose"].setRotation((getprop("/orientation/heading-deg") or 0)*(-0.01744));
		#me["FMSNAVpointer"].setRotation((getprop("/orientation/heading-deg") or 0)*(0.01744));
		#me["FMSNAVdeviation"].setRotation((getprop("/orientation/heading-deg") or 0)*(0.01744));
		var hdgbugdiff=(getprop("/orientation/heading-deg") or 0)-(getprop("/it-autoflight/input/hdg") or 0);
		me["ap-hdg-bug"].setRotation(hdgbugdiff*(-0.01744));
		
		me["ap-hdg"].setText(sprintf("%s", math.round(getprop("/it-autoflight/input/hdg") or 0)));
		me["IAS"].setText(sprintf("%s", math.round(getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") or 0)));
	
		var nav_source = getprop("/autopilot/settings/nav-source");
		me["FMSNAVtext"].setText(nav_source or "---");
		if(nav_source == "NAV1"){
			if((getprop("/instrumentation/nav[0]/in-range") or 0)==1){
				me["FMSNAVpointer"].show();
				me["FMSNAVdeviation"].show();			
				me["FMSNAVdeviation"].setTranslation((getprop("/instrumentation/nav[0]/heading-needle-deflection-norm") or 0)*130, 0);		
				me["NavFreq"].setText(sprintf("%s", getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt") or 0));
				me["FMSNAVRadial"].setText(sprintf("%s", getprop("/instrumentation/nav[0]/radials/target-radial-deg") or 0));
				var nav0_radialdiff=(getprop("/orientation/heading-deg") or 0)-(getprop("/instrumentation/nav[0]/radials/target-radial-deg") or 0);
				me["FMSNAVpointer"].setRotation(nav0_radialdiff*(-0.01744));
				me["FMSNAVdeviation"].setRotation(nav0_radialdiff*(-0.01744));
				me["FMSNAVdeflectionscale"].setRotation(nav0_radialdiff*(-0.01744));
				
			
			}else{
				me["FMSNAVpointer"].hide();
				me["FMSNAVdeviation"].hide();			
			}
		}else if(nav_source == "NAV2"){
			if((getprop("/instrumentation/nav[1]/in-range") or 0)==1){
				me["FMSNAVpointer"].show();
				me["FMSNAVdeviation"].show();			
				me["FMSNAVdeviation"].setTranslation((getprop("/instrumentation/nav[1]/heading-needle-deflection-norm") or 0)*130, 0);		
				me["NavFreq"].setText(sprintf("%s", getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt") or 0));
				me["FMSNAVRadial"].setText(sprintf("%s", getprop("/instrumentation/nav[1]/radials/target-radial-deg") or 0));
				var nav1_radialdiff=(getprop("/orientation/heading-deg") or 0)-(getprop("/instrumentation/nav[1]/radials/target-radial-deg") or 0);
				me["FMSNAVpointer"].setRotation(nav1_radialdiff*(-0.01744));
				me["FMSNAVdeviation"].setRotation(nav1_radialdiff*(-0.01744));
				me["FMSNAVdeflectionscale"].setRotation(nav1_radialdiff*(-0.01744));
				
			
			}else{
				me["FMSNAVpointer"].hide();
				me["FMSNAVdeviation"].hide();			
			}
		}else if(nav_source == "FMS"){
		}
		
		var radaralti=getprop("/position/gear-agl-ft") or 0;
		if(radaralti<2500 and radaralti>0){
			me["radaralt"].show();
			me["radaralt"].setText(sprintf("%s", math.round(radaralti)));
		}else{
			me["radaralt"].hide();
		}
			
			
		me["QNH"].setText(sprintf("%s", math.round(getprop("/instrumentation/altimeter/setting-hpa"))));
		
		#var altitude=getprop("/instrumentation/altimeter/indicated-altitude-ft") or 0;
		me["alt.1000"].setText(sprintf("%3d", getprop("/instrumentation/PFD/alt-1000")));
		me["alt.100"].setText(sprintf("%s", int(10*math.mod((getprop("/instrumentation/PFD/alt-100") or 0)/10,1))));
		me["alt.1"].setText(sprintf("%s", int(100*math.mod((getprop("/instrumentation/PFD/alt-1") or 0)/100,1))));
		me["alt.1.top"].setText(sprintf("%s", int(100*math.mod((getprop("/instrumentation/PFD/alt-1") or 0)/100,1))+1));
		me["alt.1.btm"].setText(sprintf("%s", int(100*math.mod((getprop("/instrumentation/PFD/alt-1") or 0)/100,1))-1));
		#me["alt.100"].setText(sprintf("%1d", getprop("/instrumentation/PFD/alt-100")));
		#me["alt.1"].setText(sprintf("%s", getprop("/instrumentation/PFD/alt-1")));
		#me["alt.100"].setText(sprintf("%d", math.round(altitude)/100));
		#me["alt.1"].setText(sprintf("%d", math.round(altitude)));
		
		me["VS"].setText(sprintf("%.1f", (getprop("/velocities/vertical-speed-fps") or 0)/1000*60));
		
		
		#var pitch = getprop("orientation/pitch-deg");
		#var path = getprop("orientation/path-deg");
		#var roll =  getprop("orientation/roll-deg");
		
		#debug.dump(me["horizon"].getCenter());
		#me.h_trans = me["horizon"].createTransform();
		#me.h_rot = me["horizon"].createTransform();
		
		#var c4 = me["horizon"].getCenter();
		#me["horizon"].set("clip", "rect(220.816, 693.673, 750.887, 192.606)");
		#me.h_trans.setTranslation(0,pitch*11.4625);
		#me.h_rot.setRotation(-roll*D2R,me["horizon"].getCenter());
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_PFD_avail = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_PFD_avail,canvas_PFD_base] };
		m.init(canvas_group, file);

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
	var groupPFD = PFD_display.createGroup();
	var groupPFDavail = PFD_display.createGroup();

	PFD_only = canvas_PFD_only.new(groupPFD, "Aircraft/Q400/Models/Instruments/PFD/PFD.svg");
	PFD_avail = canvas_PFD_avail.new(groupPFDavail, "Aircraft/Q400/Models/Instruments/PFD/PFD.avail.svg");

	PFD_only.update();
	PFD_avail.update();
	canvas_PFD_base.update();
});

var showPFD = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(PFD_display);
}
