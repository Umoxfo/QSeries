# Q400 MFD/EFIS by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Power_Plant.pdf https://quizlet.com/2663067/q400-limitations-flash-cards/ http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var ED_only = nil;
var ED_display = nil;
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
setprop("/consumables/fuel/tank[0]/temperature-degc", 0);
setprop("/consumables/fuel/tank[1]/temperature-degc", 0);
setprop("/controls/engines/engine[0]/condition-lever-state", 0);
setprop("/controls/engines/engine[1]/condition-lever-state", 0);
setprop("/controls/engines/engine[0]/throttle-int", 0);
setprop("/controls/engines/engine[1]/throttle-int", 0);

var canvas_ED_base = {
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
				ED_only.page.show();
		} else {
			ED_only.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_ED_only = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_ED_only,canvas_ED_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TRQL.needle","TRQL.percent","TRQL.target","TRQR.needle","TRQR.percent","TRQR.target","RPML.needle","RPMR.needle","RPML","RPMR","ITTL.needle","ITTL","ITTR.needle","ITTR","oilpressL.needle","OilPressL","oilpressR.needle","OilPressR","OilTempL","oiltempL.needle","OilTempR","oiltempR.needle","FFL","FFR","LeftQuantity","RightQuantity","FuelTempL","FuelTempR","SAT","SATp","thrustdtL","thrustdtR","powerpctL","powerpctR"];
	},
	update: func() {
		var thrustmode0=getprop("/FADEC/thrust-mode[0]") or "";
		var thrustmode1=getprop("/FADEC/thrust-mode[1]") or "";
		me["thrustdtL"].setText(thrustmode0 or "");
		me["thrustdtR"].setText(thrustmode1 or "");
		
		var powercmd0=getprop("/fcs/throttle-cmd-norm[0]") or 0;
		var powercmd1=getprop("/fcs/throttle-cmd-norm[1]") or 0;
		var rvs0=getprop("/engines/engine[0]/reversed");
		var rvs1=getprop("/engines/engine[0]/reversed");
		if(thrustmode0=="NTOP" and !rvs0){
			var pwrpct0=powercmd0/0.72*100;
		}else if(thrustmode0=="MTOP" and !rvs0){
			var pwrpct0=powercmd0/0.8*100;
		}else if(thrustmode0=="MCL" and !rvs0){
			var pwrpct0=powercmd0/0.65*100;
		}else if(thrustmode0=="MCR" and !rvs0){
			var pwrpct0=powercmd0/0.62*100;
		}else if(thrustmode0=="EMERG" and !rvs0){
			var pwrpct0=powercmd0*100;
		}else{
			var pwrpct0=0;
		}
		
		if(thrustmode1=="NTOP" and !rvs1){
			var pwrpct1=powercmd1/0.72*100;
		}else if(thrustmode1=="MTOP" and !rvs1){
			var pwrpct1=powercmd1/0.8*100;
		}else if(thrustmode1=="MCL" and !rvs1){
			var pwrpct1=powercmd1/0.65*100;
		}else if(thrustmode1=="MCR" and !rvs1){
			var pwrpct1=powercmd1/0.62*100;
		}else if(thrustmode1=="EMERG" and !rvs1){
			var pwrpct1=powercmd1*100;
		}else{
			var pwrpct1=0;
		}
		
		me["powerpctL"].setText(sprintf("%s", math.round(pwrpct0)));
		me["powerpctR"].setText(sprintf("%s", math.round(pwrpct1)));
		
	
		var TRQLpercent=(getprop("/engines/engine[0]/thruster/torque")/(-13550.7))*100;
		var TRQRpercent=(getprop("/engines/engine[1]/thruster/torque")/(-13550.7))*100;
		var throttleL=getprop("/fcs/throttle-cmd-norm") or 0;
		var throttleR=getprop("/fcs/throttle-cmd-norm[1]") or 0;
	
		me["TRQL.needle"].setRotation(TRQLpercent*0.034);
		me["TRQL.target"].setRotation(throttleL*3.4);
		me["TRQL.percent"].setText(sprintf("%s", math.round(TRQLpercent)));
		var condition_leverl=getprop("/controls/engines/engine[0]/condition-lever-state");
		if(condition_leverl<=1){
			me["TRQL.target"].hide();
		}else{
			me["TRQL.target"].show();		
		}
		
		me["TRQR.needle"].setRotation(TRQRpercent*0.034);
		me["TRQR.target"].setRotation(throttleR*3.4);
		me["TRQR.percent"].setText(sprintf("%s", math.round(TRQRpercent)));
		var condition_leverr=getprop("/controls/engines/engine[1]/condition-lever-state");
		if(condition_leverr<=1){
			me["TRQR.target"].hide();
		}else{
			me["TRQR.target"].show();		
		}
		
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
			me["oilpressL.needle"].setColor(1,0,0);
		}else if(oilPSIL<61 or oilPSIL>72){
			me["OilPressL"].setColor(1,1,0);
			me["oilpressL.needle"].setColor(1,1,0);
		}else{
			me["OilPressL"].setColor(1,1,1);
			me["oilpressL.needle"].setColor(1,1,1)
		}
		if(oilPSIR<44){
			me["OilPressR"].setColor(1,0,0);
			me["oilpressR.needle"].setColor(1,0,0);
		}else if(oilPSIR<61 or oilPSIR>72){
			me["OilPressR"].setColor(1,1,0);
			me["oilpressR.needle"].setColor(1,1,0);
		}else{
			me["OilPressR"].setColor(1,1,1);
			me["oilpressR.needle"].setColor(1,1,1)
		}
		
		var oilCL=getprop("/engines/engine[0]/oil-temperature-degc");
		var oilCR=getprop("/engines/engine[0]/oil-temperature-degc");
		var oilNL=getprop("/MFD/oil-temperature-needle[0]");
		var oilNR=getprop("/MFD/oil-temperature-needle[1]");
		
		me["oiltempL.needle"].setRotation(oilNL*0.017);
		me["OilTempL"].setText(sprintf("%s", math.round(oilCL)));
		
		me["oiltempR.needle"].setRotation(oilNR*0.017);
		me["OilTempR"].setText(sprintf("%s", math.round(oilCR)));
		
		if(oilCL<55 or oilCL>125){
			me["oiltempL.needle"].setColor(1,0,0);
			me["OilTempL"].setColor(1,0,0);
		}else if(oilCL<65 or oilCL>115){
			me["oiltempL.needle"].setColor(1,1,0);
			me["OilTempL"].setColor(1,1,1);
		}else{
			me["oiltempL.needle"].setColor(1,1,1);
			me["OilTempL"].setColor(1,1,1);
		}
		if(oilCR<55 or oilCR>125){
			me["oiltempR.needle"].setColor(1,0,0);
			me["OilTempR"].setColor(1,0,0);
		}else if(oilCR<65 or oilCR>115){
			me["oiltempR.needle"].setColor(1,1,0);
			me["OilTempR"].setColor(1,1,1);
		}else{
			me["oiltempR.needle"].setColor(1,1,1);
			me["OilTempR"].setColor(1,1,1);
		}
		
		var fuelflowL=getprop("/engines/engine[0]/fuel-flow-pph");
		var fuelflowR=getprop("/engines/engine[1]/fuel-flow-pph");
		
		me["FFL"].setText(sprintf("%s", math.round(fuelflowL)));
		me["FFR"].setText(sprintf("%s", math.round(fuelflowR)));
		
		var quantityL=getprop("/consumables/fuel/tank[0]/level-lbs") or 0;
		var quantityR=getprop("/consumables/fuel/tank[1]/level-lbs") or 0;
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
		
		var static_air_temp=getprop("/environment/temperature-degc");
		me["SAT"].setText(sprintf("%s", math.round(static_air_temp)));
		if(static_air_temp>=0){
			me["SATp"].show();
		}else{
			me["SATp"].hide();
		}
			
		
		settimer(func me.update(), 0.02);
	},
};

setlistener("sim/signals/fdm-initialized", func {
	ED_display = canvas.new({
		"name": "MFD",
		"size": [1024, 1536],
		"view": [1024, 1536],
		"mipmapping": 1
	});
	ED_display.addPlacement({"node": "ED.screen"});
	var groupED = ED_display.createGroup();

	ED_only = canvas_ED_only.new(groupED, "Aircraft/Q400/Models/Cockpit/Instruments/ED/ED.svg");

	ED_only.update();
	canvas_ED_base.update();
});

var showED = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(ED_display);
}
