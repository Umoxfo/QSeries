# Q400 MFD/EFIS by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Power_Plant.pdf https://quizlet.com/2663067/q400-limitations-flash-cards/ http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var MFD_only = nil;
var MFD_display = nil;
var page = "only";

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
setprop("/consumables/fuel/tank[0]/quantity-lbs", 0);
setprop("/consumables/fuel/tank[1]/quantity-lbs", 0);
setprop("/consumables/fuel/tank[0]/temperature-degc", 0);
setprop("/consumables/fuel/tank[1]/temperature-degc", 0);

var canvas_MFD_base = {
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
				MFD_only.page.show();
		} else {
			MFD_only.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_MFD_only = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFD_only,canvas_MFD_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TRQL.needle","TRQL.percent","TRQL.target","TRQR.needle","TRQR.percent","TRQR.target","RPML.needle","RPMR.needle","RPML","RPMR","ITTL.needle","ITTL","ITTR.needle","ITTR","oilpressL.needle","OilPressL","oilpressR.needle","OilPressR","OilTempL","oiltempL.needle","OilTempR","oiltempR.needle","FFL","FFR","LeftQuantity","RightQuantity","FuelTempL","FuelTempR"];
	},
	update: func() {
	
		var TRQLpercent=(getprop("/engines/engine[0]/thruster/torque")/(-15000))*100;
		var TRQRpercent=(getprop("/engines/engine[1]/thruster/torque")/(-15000))*100;
		var throttleL=getprop("/controls/engines/engine[0]/throttle");
		var throttleR=getprop("/controls/engines/engine[1]/throttle");
	
		me["TRQL.needle"].setRotation(TRQLpercent*0.034);
		me["TRQL.target"].setRotation(throttleL*3.4);
		me["TRQL.percent"].setText(sprintf("%s", math.round(TRQLpercent)));
		
		me["TRQR.needle"].setRotation(TRQRpercent*0.034);
		me["TRQR.target"].setRotation(throttleR*3.4);
		me["TRQR.percent"].setText(sprintf("%s", math.round(TRQRpercent)));
		
		var rpmleft=getprop("/engines/engine[0]/thruster/rpm");
		var rpmright=getprop("/engines/engine[1]/thruster/rpm");
		
		me["RPML.needle"].setRotation(rpmleft*0.00323);
		me["RPML"].setText(sprintf("%s", math.round(rpmleft)));
		
		me["RPMR.needle"].setRotation(rpmright*0.00323);
		me["RPMR"].setText(sprintf("%s", math.round(rpmright)));
		
		var ittLC=getprop("/engines/engine[0]/itt_degc");
		var ittRC=getprop("/engines/engine[1]/itt_degc");
		
		me["ITTL.needle"].setRotation(ittLC*0.002895);
		me["ITTL"].setText(sprintf("%s", math.round(ittLC)));
		
		me["ITTR.needle"].setRotation(ittRC*0.002895);
		me["ITTR"].setText(sprintf("%s", math.round(ittRC)));
		
		var oilPSIL=getprop("/engines/engine[0]/oil-pressure-psi");
		var oilPSIR=getprop("/engines/engine[0]/oil-pressure-psi");
		var oilPSINL=getprop("/MFD/oil-pressure-needle[0]");
		var oilPSINR=getprop("/MFD/oil-pressure-needle[1]");
		
		me["oilpressL.needle"].setRotation(oilPSINL*(-0.017));
		me["OilPressL"].setText(sprintf("%s", math.round(oilPSIL)));
		
		me["oilpressR.needle"].setRotation(oilPSINR*(-0.017));
		me["OilPressR"].setText(sprintf("%s", math.round(oilPSIR)));
		
		if(oilPSIL<44){
			me["OilPressL"].setColor(1,0,0);
		}else{
			me["OilPressL"].setColor(1,1,1);
		}
		if(oilPSIR<44){
			me["OilPressR"].setColor(1,0,0);
		}else{
			me["OilPressR"].setColor(1,1,1);
		}
		
		var oilCL=getprop("/engines/engine[0]/oil-temperature-degc");
		var oilCR=getprop("/engines/engine[0]/oil-temperature-degc");
		var oilNL=getprop("/MFD/oil-temperature-needle[0]");
		var oilNR=getprop("/MFD/oil-temperature-needle[1]");
		
		me["oiltempL.needle"].setRotation(oilNL*0.01);
		me["OilTempL"].setText(sprintf("%s", math.round(oilCL)));
		
		me["oiltempR.needle"].setRotation(oilNR*1.8);
		me["OilTempR"].setText(sprintf("%s", math.round(oilCR)));
		
		var fuelflowL=getprop("/engines/engine[0]/fuel-flow-pph");
		var fuelflowR=getprop("/engines/engine[1]/fuel-flow-pph");
		
		me["FFL"].setText(sprintf("%s", math.round(fuelflowL)));
		me["FFR"].setText(sprintf("%s", math.round(fuelflowR)));
		
		var quantityL=getprop("/consumables/fuel/tank[0]/quantity-lbs");
		var quantityR=getprop("/consumables/fuel/tank[1]/quantity-lbs");
		me["LeftQuantity"].setText(sprintf("%s", math.round(quantityL)));
		me["RightQuantity"].setText(sprintf("%s", math.round(quantityR)));
		
		var fuelCL=getprop("/consumables/fuel/tank[0]/temperature-degc");
		var fuelCR=getprop("/consumables/fuel/tank[1]/temperature-degc");
		me["FuelTempL"].setText(sprintf("%s", math.round(fuelCL)));
		me["FuelTempR"].setText(sprintf("%s", math.round(fuelCR)));
		if(fuelCL>71){
			me["FuelTempL"].setColor(1,0,0);
		}else if(fuelCL<0){
			me["FuelTempL"].setColor(1,1,0);
		}else{
			me["FuelTempL"].setColor(1,1,1);
		}
		if(fuelCR>71){
			me["FuelTempR"].setColor(1,0,0);
		}else if(fuelCR<0){
			me["FuelTempR"].setColor(1,1,0);
		}else{
			me["FuelTempR"].setColor(1,1,1);
		}
		
		settimer(func me.update(), 0.02);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	MFD_display = canvas.new({
		"name": "MFD",
		"size": [1024, 1536],
		"view": [1024, 1536],
		"mipmapping": 1
	});
	MFD_display.addPlacement({"node": "MFD.screen"});
	var groupMFD = MFD_display.createGroup();

	MFD_only = canvas_MFD_only.new(groupMFD, "Aircraft/Q400/Models/Instruments/MFD/MFD.svg");

	MFD_only.update();
	canvas_MFD_base.update();
});

var showMFD = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(MFD_display);
}
