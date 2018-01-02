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
var MFDcopilot_pfd = nil;
var MFDcopilot_ed = nil;
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
				MFDcopilot_pfd.page.hide();
				MFDcopilot_ed.page.hide();
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
			}else if(mainpage=="pfd"){
				MFDcopilot_pfd.page.show();
				MFDcopilot_ed.page.hide();
				MFDcopilot_elec.page.hide();
				MFDcopilot_eng.page.hide();
				MFDcopilot_fuel.page.hide();
				MFDcopilot_doors.page.hide();
			}else if(mainpage=="ed"){
				MFDcopilot_ed.page.show();
				MFDcopilot_pfd.page.hide();
				MFDcopilot_elec.page.hide();
				MFDcopilot_eng.page.hide();
				MFDcopilot_fuel.page.hide();
				MFDcopilot_doors.page.hide();
			}else{
				MFDcopilot_elec.page.hide();
				MFDcopilot_eng.page.hide();
				MFDcopilot_fuel.page.hide();
				MFDcopilot_doors.page.hide();
				MFDcopilot_pfd.page.hide();
				MFDcopilot_ed.page.hide();
			}
				
		} else {
			MFDcopilot_pfd.page.hide();
			MFDcopilot_ed.page.hide();
			MFDcopilot_elec.page.hide();
			MFDcopilot_eng.page.hide();
			MFDcopilot_fuel.page.hide();
			MFDcopilot_doors.page.hide();
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

var canvas_MFDcopilot_elec = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_elec,canvas_MFDcopilot_base] };
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

var canvas_MFDcopilot_eng = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_eng,canvas_MFDcopilot_base] };
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

var canvas_MFDcopilot_fuel = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_fuel,canvas_MFDcopilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["rudder","Lelev","Relev","transferL","transferR","transferOFF","leftquantity","rightquantity","totalquantity","tank1booston1","tank1booston2","tank2booston1","tank2booston2","tank1boostoff1","tank1boostoff2","tank2boostoff1","tank2boostoff2"];
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
		return ["rudder","Lelev","Relev","PAXF","PAXR","BAGGAGEF","BAGGAGER","SERVICE"];
	},
	update: func() {
	
		if(getprop("/sim/model/door-positions/passengerF/position-norm")==1){
			me["PAXF"].setColor(0,1,0);
			me["PAXF"].setColorFill(0,1,0);
		}else{
			me["PAXF"].setColor(1,0,0);
			me["PAXF"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/passengerLH/position-norm") or 0)==0){
			me["PAXR"].setColorFill(0,1,0);
		}else{
			me["PAXR"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/passengerRF/position-norm") or 0)==0){
			me["BAGGAGEF"].setColorFill(0,1,0);
		}else{
			me["BAGGAGEF"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/cargo/position-norm") or 0)==0){
			me["BAGGAGER"].setColorFill(0,1,0);
		}else{
			me["BAGGAGER"].setColorFill(1,0,0);
		}
		if((getprop("/sim/model/door-positions/passengerRH/position-norm") or 0)==0){
			me["SERVICE"].setColorFill(0,1,0);
		}else{
			me["SERVICE"].setColorFill(1,0,0);
		}
			
		
		me.updateBottomStatus();
		settimer(func me.update(), 0.02);
	},
};

var canvas_MFDcopilot_ed = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_ed,canvas_MFDcopilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["TRQL.needle","TRQL.percent","TRQL.target","TRQR.needle","TRQR.percent","TRQR.target","RPML.needle","RPMR.needle","RPML","RPMR","ITTL.needle","ITTL","ITTR.needle","ITTR","oilpressL.needle","OilPressL","oilpressR.needle","OilPressR","OilTempL","oiltempL.needle","OilTempR","oiltempR.needle","FFL","FFR","LeftQuantity","RightQuantity","FuelTempL","FuelTempR","SAT","SATp"];
	},
	update: func() {
	
		var TRQLpercent=(getprop("/engines/engine[0]/thruster/torque")/(-15000))*100;
		var TRQRpercent=(getprop("/engines/engine[1]/thruster/torque")/(-15000))*100;
		var throttleL=getprop("/controls/engines/engine[0]/throttle-int") or 0;
		var throttleR=getprop("/controls/engines/engine[1]/throttle-int") or 0;
	
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

var canvas_MFDcopilot_pfd = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_MFDcopilot_pfd,canvas_MFDcopilot_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["ap-alt","ap-alt-capture","IASbug1","IASbug1symbol","IASbug1digit","IASbug2","IASbug2symbol","IASbug2digit","compassrose","IAS.100","IAS.10","ap-hdg","ap-hdg-bug","FMSNAVpointer","FMSNAVdeviation","NavFreq","FMSNAVRadial","FMSNAVdeflectionscale","FMSNAVtext","dh","radaralt","QNH","alt.1000","alt.100","alt.1","alt.1.top","alt.1.btm","VS","horizon","ladder","rollpointer","rollpointer2","asitape","asitapevmo","asi.trend.up","asi.trend.down","alt.tape","VS.needle","AP","ap.lat.engaged","ap.lat.armed","ap.vert.eng","ap.vert.value","ap.vert.arm","altTextLowSmall1","altTextHighSmall2","altTextLow1","altTextHigh1","altTextHigh2","alt.low.digits","alt.bug","alt.bug.top","alt.bug.btm","asi.rollingdigits"];
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
				me["FMSNAVpointer"].setRotation(nav0_radialdiff*(-DC));
				me["FMSNAVdeviation"].setRotation(nav0_radialdiff*(-DC));
				me["FMSNAVdeflectionscale"].setRotation(nav0_radialdiff*(-DC));
				
			
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
				me["FMSNAVpointer"].setRotation(nav1_radialdiff*(-DC));
				me["FMSNAVdeviation"].setRotation(nav1_radialdiff*(-DC));
				me["FMSNAVdeflectionscale"].setRotation(nav1_radialdiff*(-DC));
				
			
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
		
		me["horizon"].setTranslation(x,y);
		me["horizon"].setRotation(roll*(-DC),me["horizon"].getCenter());
		
		me["rollpointer"].setRotation(-roll*(-DC));
		me["rollpointer2"].setTranslation(math.round(getprop("/instrumentation/slip-skid-ball/indicated-slip-skid") or 0)*5, 0);
		
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
	var groupMFDcopilot_pfd = MFDcopilot_display.createGroup();
	var groupMFDcopilot_ed = MFDcopilot_display.createGroup();

	MFDcopilot_elec = canvas_MFDcopilot_elec.new(groupMFDcopilot_elec, "Aircraft/Q400/Models/Cockpit/Instruments/MFD/MFD_SYS_ELEC_PILOT.svg");
	MFDcopilot_eng = canvas_MFDcopilot_eng.new(groupMFDcopilot_eng, "Aircraft/Q400/Models/Cockpit/Instruments/MFD/MFD_SYS_ENG_PILOT.svg");
	MFDcopilot_fuel = canvas_MFDcopilot_fuel.new(groupMFDcopilot_fuel, "Aircraft/Q400/Models/Cockpit/Instruments/MFD/MFD.SYS.FUEL.PILOT.svg");
	MFDcopilot_doors = canvas_MFDcopilot_doors.new(groupMFDcopilot_doors, "Aircraft/Q400/Models/Cockpit/Instruments/MFD/MFD.SYS.DOORS.PILOT.svg");
	MFDcopilot_pfd = canvas_MFDcopilot_pfd.new(groupMFDcopilot_pfd, "Aircraft/Q400/Models/Cockpit/Instruments/PFD/PFD.svg");
	MFDcopilot_ed = canvas_MFDcopilot_ed.new(groupMFDcopilot_ed, "Aircraft/Q400/Models/Cockpit/Instruments/ED/ED.svg");

	MFDcopilot_elec.update();
	MFDcopilot_eng.update();
	MFDcopilot_fuel.update();
	MFDcopilot_doors.update();
	MFDcopilot_pfd.update();
	MFDcopilot_ed.update();
	canvas_MFDcopilot_base.update();
});

var showMFDcopilot = func {
	var dlg = canvas.Window.new([512, 768], "dialog").set("resize", 1);
	dlg.setCanvas(MFDcopilot_display);
}
