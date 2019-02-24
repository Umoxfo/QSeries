# Q400 MFD/EFIS by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Fuel.pdf http://www.smartcockpit.com/docs/Q400-Electrical.pdf http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}

var MFDcopilot_elec = nil;
var MFDcopilot_eng = nil;
var MFDcopilot_fuel = nil;
var MFDcopilot_doors = nil;
var MFDcopilot_display = nil;
var syspage = "elec";
var mainpage = "sys";
var DC=0.01744;

setprop("/instrumentation/mfd[1]/inputs/sys-page", "elec");
setprop("/instrumentation/mfd[1]/inputs/main-page", "sys");

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

var canvas_MFDcopilot_base = {
	init: func(canvas_group, file) {
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
			if(key=="horizon"){
				var center=me[key].getCenter();
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
		if (getprop("/systems/electrical/volts") >= 10) {
			var mainpage=getprop("/instrumentation/mfd[1]/inputs/main-page");
			if(mainpage=="sys"){
				var syspage=getprop("/instrumentation/mfd[1]/inputs/sys-page");
				if(syspage=="elec"){
					MFDcopilot_elec.page.show();
					MFDcopilot_eng.page.hide();
					MFDcopilot_fuel.page.hide();
					MFDcopilot_doors.page.hide();
				}else if(syspage=="eng"){
					MFDcopilot_eng.page.show();
					MFDcopilot_elec.page.hide();
					MFDcopilot_fuel.page.hide();
					MFDcopilot_doors.page.hide();
				}else if(syspage=="fuel"){
					MFDcopilot_fuel.page.show();
					MFDcopilot_elec.page.hide();
					MFDcopilot_eng.page.hide();
					MFDcopilot_doors.page.hide();
				}else if(syspage=="doors"){
					MFDcopilot_doors.page.show();
					MFDcopilot_elec.page.hide();
					MFDcopilot_eng.page.hide();
					MFDcopilot_fuel.page.hide();
				}else{
					MFDcopilot_elec.page.hide();
					MFDcopilot_eng.page.hide();
					MFDcopilot_fuel.page.hide();
					MFDcopilot_doors.page.hide();
				}
			}else{
				MFDcopilot_elec.page.hide();
				MFDcopilot_eng.page.hide();
				MFDcopilot_fuel.page.hide();
				MFDcopilot_doors.page.hide();
			}
				
		} else {
			MFDcopilot_elec.page.hide();
			MFDcopilot_eng.page.hide();
			MFDcopilot_fuel.page.hide();
			MFDcopilot_doors.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
	updateBottomStatus: func() {
		var flaps_norm = props.globals.getNode("surface-positions/flap-pos-norm").getValue() or 0;
		me["flaps.pointer"].setRotation(flaps_norm*D2R*210);
		
		var press1 = props.globals.getNode("systems/hydraulic/psi1").getValue() or 0;
		me["one.pointer"].setTranslation(0,-press1*0.045);
		
		var press2 = props.globals.getNode("systems/hydraulic/psi2").getValue() or 0;
		me["two.pointer"].setTranslation(0,-press2*0.045);
		
		var press3 = props.globals.getNode("systems/hydraulic/psi3").getValue() or 0;
		me["three.pointer"].setTranslation(0,-press3*0.045);
		
	},
};

var canvas_MFDcopilot_elec = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_elec,canvas_MFDcopilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["flaps.pointer","pkbrk.pointer","stby.pointer","one.pointer","two.pointer","three.pointer","APUload","gen1load","gen2load","DCext1","ACext1","DCext2","ACext2"];
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

var canvas_MFDcopilot_eng = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_eng,canvas_MFDcopilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["flaps.pointer","pkbrk.pointer","stby.pointer","one.pointer","two.pointer","three.pointer","TRQL","TRQR","PROPRPML","PROPRPMR","ITTL","ITTR","fuelquantityL","fuelquantityR","fueltempL","fueltempR","SAT","FFL","FFR","OilPressL","OilPressR","OilTempL","OilTempR","NLL","NLR","NHL","NHR","NHL.decimal","NHR.decimal"];
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

var canvas_MFDcopilot_fuel = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_fuel,canvas_MFDcopilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["flaps.pointer","pkbrk.pointer","stby.pointer","one.pointer","two.pointer","three.pointer","transferL","transferR","transferOFF","leftquantity","rightquantity","totalquantity","tank1booston1","tank1booston2","tank2booston1","tank2booston2","tank1boostoff1","tank1boostoff2","tank2boostoff1","tank2boostoff2"];
	},
	update: func() {
	
		var transfer=getprop("/controls/fuel/transfer") or 0;
		if(transfer==(-1)){
			me["transferL"].show();
			me["transferR"].hide();
			me["transferOFF"].hide();
		}else if(transfer==1){
			me["transferL"].hide();
			me["transferR"].show();
			me["transferOFF"].hide();		
		}else{
			me["transferL"].hide();
			me["transferR"].hide();
			me["transferOFF"].show();		
		}
		
		
		var quantityL=getprop("/consumables/fuel/tank[0]/level-lbs") or 0;
		var quantityR=getprop("/consumables/fuel/tank[1]/level-lbs") or 0;
		me["leftquantity"].setRotation(quantityL*(0.01744)*313.25/7000);
		me["rightquantity"].setRotation(quantityR*(0.01744)*313.25/7000);
		
		me["totalquantity"].setText(sprintf("%s", math.round(getprop("/consumables/fuel/total-fuel-lbs"))));
		
		if((getprop("/controls/fuel/tank[0]/boost-pump") or 0)==1){
			me["tank1booston1"].show();
			me["tank1booston2"].show();
			me["tank1boostoff1"].hide();
			me["tank1boostoff2"].hide();
		}else{
			me["tank1booston1"].hide();
			me["tank1booston2"].hide();
			me["tank1boostoff1"].show();
			me["tank1boostoff2"].show();
		}
		if((getprop("/controls/fuel/tank[1]/boost-pump") or 0)==1){
			me["tank2booston1"].show();
			me["tank2booston2"].show();
			me["tank2boostoff1"].hide();
			me["tank2boostoff2"].hide();
		}else{
			me["tank2booston1"].hide();
			me["tank2booston2"].hide();
			me["tank2boostoff1"].show();
			me["tank2boostoff2"].show();
		}	
		
		me.updateBottomStatus();
		settimer(func me.update(), 0.02);
	},
};

var canvas_MFDcopilot_doors = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_doors,canvas_MFDcopilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["flaps.pointer","pkbrk.pointer","stby.pointer","one.pointer","two.pointer","three.pointer","PAXF","PAXR","BAGGAGEF","BAGGAGER","SERVICE","PAXF.text","PAXR.text","BAGGAGEF.text","BAGGAGER.text","SERVICE.text","EMERGEXIT","EMERGEXIT.text"];
	},
	update: func() {
	
		if(getprop("/sim/model/door-positions/passengerF/position-norm")==1){
			me["PAXF"].setColor(0,1,0);
			me["PAXF"].setColorFill(0,0,0);
			me["PAXF.text"].hide();
		}else{
			me["PAXF"].setColor(1,0,0);
			me["PAXF"].setColorFill(1,0,0);
			me["PAXF.text"].show();
		}
		if((getprop("/sim/model/door-positions/passengerLH/position-norm") or 0)==0){
			me["PAXR"].setColor(0,1,0);
			me["PAXR"].setColorFill(0,0,0);
			me["PAXR.text"].hide();
		}else{
			me["PAXR"].setColor(1,0,0);
			me["PAXR"].setColorFill(1,0,0);
			me["PAXR.text"].show();
		}
		if((getprop("/sim/model/door-positions/passengerRF/position-norm") or 0)==0){
			me["BAGGAGEF"].setColor(0,1,0);
			me["BAGGAGEF"].setColorFill(0,0,0);
			me["BAGGAGEF.text"].hide();
		}else{
			me["BAGGAGEF"].setColor(1,0,0);
			me["BAGGAGEF"].setColorFill(1,0,0);
			me["BAGGAGEF.text"].show();
		}
		if((getprop("/sim/model/door-positions/cargo/position-norm") or 0)==0){
			me["BAGGAGER"].setColor(0,1,0);
			me["BAGGAGER"].setColorFill(0,0,0);
			me["BAGGAGER.text"].hide();
		}else{
			me["BAGGAGER"].setColor(1,0,0);
			me["BAGGAGER"].setColorFill(1,0,0);
			me["BAGGAGER.text"].show();
		}
		if((getprop("/sim/model/door-positions/passengerRH/position-norm") or 0)==0){
			me["SERVICE"].setColor(0,1,0);
			me["SERVICE"].setColorFill(0,0,0);
			me["SERVICE.text"].hide();
		}else{
			me["SERVICE"].setColor(1,0,0);
			me["SERVICE"].setColorFill(1,0,0);
			me["SERVICE.text"].show();
		}
		
		#emergency exit door not yet implemented
		me["EMERGEXIT.text"].hide();
			
		
		me.updateBottomStatus();
		settimer(func me.update(), 0.02);
	},
};



setlistener("sim/signals/fdm-initialized", func {
	MFDcopilot_display = canvas.new({
		"name": "MFD_c",
		"size": [1024, 1536],
		"view": [1024, 1536],
		"mipmapping": 1
	});
	MFDcopilot_display.addPlacement({"node": "MFDcopilot.screen"});
	var groupMFDcopilot_elec = MFDcopilot_display.createGroup();
	var groupMFDcopilot_eng = MFDcopilot_display.createGroup();
	var groupMFDcopilot_fuel = MFDcopilot_display.createGroup();
	var groupMFDcopilot_doors = MFDcopilot_display.createGroup();

	MFDcopilot_elec = canvas_MFDcopilot_elec.new(groupMFDcopilot_elec, "Aircraft/QSeries/Models/Cockpit/Instruments/MFD/MFD.SYS.ELEC.COPILOT.svg");
	MFDcopilot_eng = canvas_MFDcopilot_eng.new(groupMFDcopilot_eng, "Aircraft/QSeries/Models/Cockpit/Instruments/MFD/MFD.SYS.ENG.COPILOT.svg");
	MFDcopilot_fuel = canvas_MFDcopilot_fuel.new(groupMFDcopilot_fuel, "Aircraft/QSeries/Models/Cockpit/Instruments/MFD/MFD.SYS.FUEL.COPILOT.svg");
	MFDcopilot_doors = canvas_MFDcopilot_doors.new(groupMFDcopilot_doors, "Aircraft/QSeries/Models/Cockpit/Instruments/MFD/MFD.SYS.DOORS.COPILOT.svg");

	MFDcopilot_elec.update();
	MFDcopilot_eng.update();
	MFDcopilot_fuel.update();
	MFDcopilot_doors.update();
	canvas_MFDcopilot_base.update();
});

var showMFDcopilot = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(MFDcopilot_display);
}
