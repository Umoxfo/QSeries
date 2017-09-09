# Q400 MFD/EFIS by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Fuel.pdf http://www.smartcockpit.com/docs/Q400-Electrical.pdf http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var MFDpilot_elec = nil;
var MFDpilot_eng = nil;
var MFDpilot_fuel = nil;
var MFDpilot_doors = nil;
var MFDpilot_pfd = nil;
var MFDpilot_display = nil;
var syspage = "elec";
var mainpage = "sys";

setprop("/instrumentation/mfd[0]/inputs/sys-page", "elec");
setprop("/instrumentation/mfd[0]/inputs/main-page", "sys");

setprop("/engines/engine[0]/thruster/torque", 0);
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

var canvas_MFDpilot_base = {
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
			var mainpage=getprop("/instrumentation/mfd[0]/inputs/main-page");
			if(mainpage=="sys"){
				MFDpilot_pfd.page.hide();
				var syspage=getprop("/instrumentation/mfd[0]/inputs/sys-page");
				if(syspage=="elec"){
					MFDpilot_elec.page.show();
					MFDpilot_eng.page.hide();
					MFDpilot_fuel.page.hide();
					MFDpilot_doors.page.hide();
				}else if(syspage=="eng"){
					MFDpilot_eng.page.show();
					MFDpilot_elec.page.hide();
					MFDpilot_fuel.page.hide();
					MFDpilot_doors.page.hide();
				}else if(syspage=="fuel"){
					MFDpilot_fuel.page.show();
					MFDpilot_elec.page.hide();
					MFDpilot_eng.page.hide();
					MFDpilot_doors.page.hide();
				}else if(syspage=="doors"){
					MFDpilot_doors.page.show();
					MFDpilot_elec.page.hide();
					MFDpilot_eng.page.hide();
					MFDpilot_fuel.page.hide();
				}else{
					MFDpilot_elec.page.hide();
					MFDpilot_eng.page.hide();
					MFDpilot_fuel.page.hide();
					MFDpilot_doors.page.hide();
				}
			}else if(mainpage=="pfd"){
				MFDpilot_pfd.page.show();
				MFDpilot_elec.page.hide();
				MFDpilot_eng.page.hide();
				MFDpilot_fuel.page.hide();
				MFDpilot_doors.page.hide();
			}else{
				MFDpilot_elec.page.hide();
				MFDpilot_eng.page.hide();
				MFDpilot_fuel.page.hide();
				MFDpilot_doors.page.hide();
				MFDpilot_pfd.page.hide();
			}
				
		} else {
			MFDpilot_pfd.page.hide();
			MFDpilot_elec.page.hide();
			MFDpilot_eng.page.hide();
			MFDpilot_fuel.page.hide();
			MFDpilot_doors.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
	updateBottomStatus: func() {
		me["rudder"].setRotation((getprop("/surface-positions/rudder-pos-norm") or 0)*(-0.01744)*41.4);
		var elevator=getprop("/surface-positions/elevator-pos-norm") or 0;
		if(elevator>0){
			me["Lelev"].setRotation(elevator*(-0.01744)*30);
			me["Relev"].setRotation(elevator*(0.01744)*30);
		}else if(elevator<0){
			me["Lelev"].setRotation(elevator*(-0.01744)*43);
			me["Relev"].setRotation(elevator*(0.01744)*43);
		}
		
	},
};

var canvas_MFDpilot_elec = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDpilot_elec,canvas_MFDpilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["APUload","gen1load","gen2load","DCext1","ACext1","DCext2","ACext2","rudder","Lelev","Relev"];
	},
	update: func() {
	
	
		if(getprop("/systems/electrical/power-source")!="external"){
			me["DCext1"].hide();
			me["ACext1"].hide();
			me["DCext2"].hide();
			me["ACext2"].hide();
		}else{
			me["DCext1"].show();
			me["ACext1"].show();
			me["DCext2"].show();
			me["ACext2"].show();
		}
		
		me["gen1load"].setText(sprintf("%.2f", (getprop("/systems/electrical/gen-load[0]") or 0)));
		me["gen2load"].setText(sprintf("%.2f", (getprop("/systems/electrical/gen-load[1]") or 0)));
		me["APUload"].setText(sprintf("%.2f", (getprop("/systems/electrical/gen-load[2]") or 0)));
			
		
		me.updateBottomStatus();
		settimer(func me.update(), 0.02);
	},
};

var canvas_MFDpilot_eng = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDpilot_eng,canvas_MFDpilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TRQL","TRQR","PROPRPML","PROPRPMR","ITTL","ITTR","fuelquantityL","fuelquantityR","fueltempL","fueltempR","SAT","FFL","FFR","OilPressL","OilPressR","OilTempL","OilTempR","NLL","NLR","NHL","NHR","NHL.decimal","NHR.decimal","rudder","Lelev","Relev"];
	},
	update: func() {
			
		var TRQLpercent=(getprop("/engines/engine[0]/thruster/torque")/(-15000))*100;
		var TRQRpercent=(getprop("/engines/engine[1]/thruster/torque")/(-15000))*100;
		me["TRQL"].setText(sprintf("%s", math.round(TRQLpercent)));
		me["TRQR"].setText(sprintf("%s", math.round(TRQRpercent)));
		
		var rpmleft=getprop("/engines/engine[0]/thruster/rpm");
		var rpmright=getprop("/engines/engine[1]/thruster/rpm");
		me["PROPRPML"].setText(sprintf("%s", math.round(rpmleft)));
		me["PROPRPMR"].setText(sprintf("%s", math.round(rpmright)));
		
		var ittLC=getprop("/engines/engine[0]/itt_degc");
		var ittRC=getprop("/engines/engine[1]/itt_degc");
		me["ITTL"].setText(sprintf("%s", math.round(ittLC)));
		me["ITTR"].setText(sprintf("%s", math.round(ittRC)));
		
		var quantityL=getprop("/consumables/fuel/tank[0]/level-lbs") or 0;
		var quantityR=getprop("/consumables/fuel/tank[1]/level-lbs") or 0;
		me["fuelquantityL"].setText(sprintf("%s", math.round(quantityL)));
		me["fuelquantityR"].setText(sprintf("%s", math.round(quantityR)));
		
		
		var fuelCL=getprop("/consumables/fuel/tank[0]/temperature-degc");
		var fuelCR=getprop("/consumables/fuel/tank[1]/temperature-degc");
		me["fueltempL"].setText(sprintf("%+s", math.round(fuelCL)));
		me["fueltempR"].setText(sprintf("%+s", math.round(fuelCR)));
		
		var static_air_temp=getprop("/environment/temperature-degc");
		me["SAT"].setText(sprintf("%+s", math.round(static_air_temp)));
		
		
		var fuelflowL=getprop("/engines/engine[0]/fuel-flow-pph");
		var fuelflowR=getprop("/engines/engine[1]/fuel-flow-pph");
		me["FFL"].setText(sprintf("%s", math.round(fuelflowL)));
		me["FFR"].setText(sprintf("%s", math.round(fuelflowR)));
		
		
		var oilPSIL=getprop("/engines/engine[0]/oil-pressure-psi");
		var oilPSIR=getprop("/engines/engine[1]/oil-pressure-psi");
		me["OilPressL"].setText(sprintf("%s", math.round(oilPSIL)));
		me["OilPressR"].setText(sprintf("%s", math.round(oilPSIR)));
		
		var oilCL=getprop("/engines/engine[0]/oil-temperature-degc");
		var oilCR=getprop("/engines/engine[1]/oil-temperature-degc");
		me["OilTempL"].setText(sprintf("%s", math.round(oilCL)));
		me["OilTempR"].setText(sprintf("%s", math.round(oilCR)));
		
		var n1L=getprop("/engines/engine[0]/n1");
		var n1R=getprop("/engines/engine[1]/n1");
		me["NLL"].setText(sprintf("%s", math.round(n1L)));
		me["NLR"].setText(sprintf("%s", math.round(n1R)));
		
		var n2L=getprop("/engines/engine[0]/n2");
		var n2R=getprop("/engines/engine[1]/n2");
		me["NHL"].setText(sprintf("%s", math.round(n2L)));
		me["NHR"].setText(sprintf("%s", math.round(n2R)));
		me["NHL.decimal"].setText(sprintf("%s", int(10*math.mod((n2L or 0),1))));
		me["NHR.decimal"].setText(sprintf("%s", int(10*math.mod((n2R or 0),1))));
		
		me.updateBottomStatus();
		settimer(func me.update(), 0.02);
	},
};

var canvas_MFDpilot_fuel = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDpilot_fuel,canvas_MFDpilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["rudder","Lelev","Relev"];
	},
	update: func() {
			
		
		me.updateBottomStatus();
		settimer(func me.update(), 0.02);
	},
};

var canvas_MFDpilot_doors = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDpilot_doors,canvas_MFDpilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["rudder","Lelev","Relev","PAXF","PAXR","BAGGAGEF","BAGGAGER","SERVICE"];
	},
	update: func() {
	
		if(getprop("/sim/model/door-positions/passengerF")==1){
			me["PAXF"].setColorFill(0,1,0);
		}else{
			me["PAXF"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/passengerLH") or 0)==0){
			me["PAXR"].setColorFill(0,1,0);
		}else{
			me["PAXR"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/passengerRF") or 0)==0){
			me["BAGGAGEF"].setColorFill(0,1,0);
		}else{
			me["BAGGAGEF"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/cargo") or 0)==0){
			me["BAGGAGER"].setColorFill(0,1,0);
		}else{
			me["BAGGAGER"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/passengerRH") or 0)==0){
			me["SERVICE"].setColorFill(0,1,0);
		}else{
			me["SERVICE"].setColorFill(1,0,0);
		}
			
		
		me.updateBottomStatus();
		settimer(func me.update(), 0.02);
	},
};


var canvas_MFDpilot_pfd = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDpilot_pfd,canvas_MFDpilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ap-alt","ap-alt-capture","IASbug1","IASbug1symbol","IASbug1digit","IASbug2","IASbug2symbol","IASbug2digit","compassrose","IAS","ap-hdg","ap-hdg-bug","FMSNAVpointer","FMSNAVdeviation","NavFreq","FMSNAVRadial","FMSNAVdeflectionscale","FMSNAVtext","dh","radaralt","QNH","alt.1000","alt.100","alt.1","alt.1.top","alt.1.btm","VS","horizon"];
	},
	update: func() {
	
		me["ap-alt"].setText(sprintf("%s", math.round(getprop("/it-autoflight/input/alt")or 0)));
		
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



setlistener("sim/signals/fdm-initialized", func {
	MFDpilot_display = canvas.new({
		"name": "MFD",
		"size": [1024, 1536],
		"view": [1024, 1536],
		"mipmapping": 1
	});
	MFDpilot_display.addPlacement({"node": "MFDpilot.screen"});
	var groupMFDpilot_elec = MFDpilot_display.createGroup();
	var groupMFDpilot_eng = MFDpilot_display.createGroup();
	var groupMFDpilot_fuel = MFDpilot_display.createGroup();
	var groupMFDpilot_doors = MFDpilot_display.createGroup();
	var groupMFDpilot_pfd = MFDpilot_display.createGroup();

	MFDpilot_elec = canvas_MFDpilot_elec.new(groupMFDpilot_elec, "Aircraft/Q400/Models/Instruments/MFD/MFD_SYS_ELEC_PILOT.svg");
	MFDpilot_eng = canvas_MFDpilot_eng.new(groupMFDpilot_eng, "Aircraft/Q400/Models/Instruments/MFD/MFD_SYS_ENG_PILOT.svg");
	MFDpilot_fuel = canvas_MFDpilot_fuel.new(groupMFDpilot_fuel, "Aircraft/Q400/Models/Instruments/MFD/MFD.SYS.FUEL.PILOT.svg");
	MFDpilot_doors = canvas_MFDpilot_doors.new(groupMFDpilot_doors, "Aircraft/Q400/Models/Instruments/MFD/MFD.SYS.DOORS.PILOT.svg");
	MFDpilot_pfd = canvas_MFDpilot_pfd.new(groupMFDpilot_pfd, "Aircraft/Q400/Models/Instruments/PFD/PFD.svg");

	MFDpilot_elec.update();
	MFDpilot_eng.update();
	MFDpilot_fuel.update();
	MFDpilot_doors.update();
	MFDpilot_pfd.update();
	canvas_MFDpilot_base.update();
});

var showMFDpilot = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(MFDpilot_display);
}
