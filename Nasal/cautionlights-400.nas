var master_caution_sw = props.globals.initNode("/instrumentation/crew-alerting/master-caution", 0, "BOOL");
var master_warning_sw = props.globals.initNode("/instrumentation/crew-alerting/master-warning", 0, "BOOL");

var master_caution = aircraft.light.new("/instrumentation/crew-alerting/master-caution-light", [0.25,0.1], "/instrumentation/crew-alerting/master-caution");
var master_warning = aircraft.light.new("/instrumentation/crew-alerting/master-warning-light", [0.25,0.1], "/instrumentation/crew-alerting/master-warning");

var psi_edp_1_was = 0;
var psi_edp_2_was = 0;
var fuel_1_was = 0;
var fuel_2_was = 0;
var op_1_was = 0;
var op_2_was = 0;
var ph1_was = 0;
var ph2_was = 0;
var pf_was = 0;
var lh_was = 0;
var rf_was = 0;
var rh_was = 0;
var cargo_was = 0;


#Caution Lights that trigger master caution (all except fueling on)
setlistener("/controls/gear/brake-parking", func(i){
	if(i.getValue()){
		master_caution_sw.setValue(1);
	}
});
setlistener("systems/hydraulic/psi-edp-1", func(i){
	if(i.getValue()<2000){
		if(!psi_edp_1_was){
			master_caution_sw.setValue(1);
			psi_edp_1_was=1;
		}
	}else{
		psi_edp_1_was=1;
	}
});
setlistener("systems/hydraulic/psi-edp-2", func(i){
	if(i.getValue()<2000){
		if(!psi_edp_2_was){
			master_caution_sw.setValue(1);
			psi_edp_2_was=1;
		}
	}else{
		psi_edp_2_was=0;
	}
});
setlistener("consumables/fuel/tank[0]/level-kg", func(i){
	if(i.getValue()<60){
		if(!fuel_1_was){
			master_caution_sw.setValue(1);
			fuel_1_was=1;
		}
	}else{
		fuel_1_was=0;
	}
});
setlistener("consumables/fuel/tank[1]/level-kg", func(i){
	if(i.getValue()<60){
		if(!fuel_2_was){
			master_caution_sw.setValue(1);
			fuel_2_was=1;
		}
	}else{
		fuel_2_was=0;
	}
});
setlistener("systems/electrical/outputs/pitot-heat[0]", func(i){
	if(i.getValue()<15){
		if(!ph1_was){
			master_caution_sw.setValue(1);
			ph1_was=1;
		}
	}else{
		ph1_was=0;
	}
});
setlistener("systems/electrical/outputs/pitot-heat[1]", func(i){
	if(i.getValue()<15){
		if(!ph2_was){
			master_caution_sw.setValue(1);
			ph2_was=1;
		}
	}else{
		ph2_was=0;
	}
});
setlistener("/controls/cabin/emergency-lights", func(i){
	if(i.getValue()==-1){
		master_caution_sw.setValue(1);
	}
});
setlistener("/controls/electric/engine[0]/dc-generator", func(i){
	if(!i.getValue()){
		master_caution_sw.setValue(1);
	}
});
setlistener("/controls/electric/engine[1]/dc-generator", func(i){
	if(!i.getValue()){
		master_caution_sw.setValue(1);
	}
});
setlistener("/controls/electric/engine[0]/ac-generator", func(i){
	if(!i.getValue()){
		master_caution_sw.setValue(1);
	}
});
setlistener("/controls/electric/engine[1]/ac-generator", func(i){
	if(!i.getValue()){
		master_caution_sw.setValue(1);
	}
});
					
					
var beacon = props.globals.getNode("/controls/lighting/beacon", 1);
var strobe = props.globals.getNode("/controls/lighting/strobe-lights", 1);
var rcdrtest = props.globals.getNode("instrumentation/flightrcdr/gndtes", 1);
setlistener("/controls/lighting/beacon", func(){
	if(!beacon.getValue() and !strobe.getValue() and !rcdrtest.getValue()){
		master_caution_sw.setValue(1);
	}
});
setlistener("/controls/lighting/strobe-lights", func(){
	if(!beacon.getValue() and !strobe.getValue() and !rcdrtest.getValue()){
		master_caution_sw.setValue(1);
	}
});
setlistener("instrumentation/flightrcdr/gndtest", func(){
	if(!beacon.getValue() and !strobe.getValue() and !rcdrtest.getValue()){
		master_caution_sw.setValue(1);
	}
});

setlistener("/controls/panel/cautiontest", func(i){
	if(i.getValue()){
		master_caution_sw.setValue(1);
	}
});


#Warning Lights trigger master warning
setlistener("engines/engine[0]/oil-pressure-psi", func(i){
	if(i.getValue()<40){
		if(!op_1_was){
			master_warning_sw.setValue(1);
			op_1_was=1;
		}
	}else{
		op_1_was=0;
	}
});
setlistener("engines/engine[1]/oil-pressure-psi", func(i){
	if(i.getValue()<40){
		if(!op_2_was){
			master_warning_sw.setValue(1);
			op_2_was=1;
		}
	}else{
		op_2_was=0;
	}
});
setlistener("/sim/model/door-positions/passengerF/position-norm", func(i){
	if(i.getValue()!=1){
		if(!pf_was){
			master_warning_sw.setValue(1);
			pf_was=1;
		}
	}else{
		pf_was=0;
	}
});
setlistener("/sim/model/door-positions/passengerLH/position-norm", func(i){
	if(i.getValue()!=0){
		if(!lh_was){
			master_warning_sw.setValue(1);
			lh_was=1;
		}
	}else{
		lh_was=0;
	}
});
setlistener("/sim/model/door-positions/passengerRF/position-norm", func(i){
	if(i.getValue()!=0){
		if(!rf_was){
			master_warning_sw.setValue(1);
			rf_was=1;
		}
	}else{
		rf_was=0;
	}
});
setlistener("/sim/model/door-positions/passengerRH/position-norm", func(i){
	if(i.getValue()!=0){
		if(!rh_was){
			master_warning_sw.setValue(1);
			rh_was=1;
		}
	}else{
		rh_was=0;
	}
});
setlistener("/sim/model/door-positions/cargo/position-norm", func(i){
	if(i.getValue()!=0){
		if(!cargo_was){
			master_warning_sw.setValue(1);
			cargo_was=1;
		}
	}else{
		cargo_was=0;
	}
});
setlistener("/controls/panel/cautiontest", func(i){
	if(i.getValue()){
		master_warning_sw.setValue(1);
	}
});

