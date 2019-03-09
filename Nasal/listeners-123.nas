#Various Listeners

var apt="instrumentation/efis[0]/inputs/arpt";
var vor="instrumentation/efis[0]/inputs/VORD";
var ndb="instrumentation/efis[0]/inputs/NDB";


setlistener("/instrumentation/efis[0]/inputs/data-btn", func{
	var data_btn=getprop("/instrumentation/efis[0]/inputs/data-btn");
	if(data_btn==1){
		setprop(apt, 0);
		setprop(vor, 1);
		setprop(ndb, 1);
	}else if(data_btn==2){
		setprop(apt, 1);
		setprop(vor, 0);
		setprop(ndb, 0);
	}else if(data_btn==3){
		setprop(apt, 1);
		setprop(vor, 1);
		setprop(ndb, 1);
	}else{
		setprop(apt, 0);
		setprop(vor, 0);
		setprop(ndb, 0);
	}
});

setlistener("/controls/engines/engine[0]/condition-lever-state", func(i){
	condStateInfo();
	if(i.getValue() != 2){
		setprop("/controls/engines/engine[0]/condition-lever-set", 0);
	}
});

setlistener("/controls/engines/engine[1]/condition-lever-state", func(i){
	condStateInfo();
	if(i.getValue() != 2){
		setprop("/controls/engines/engine[1]/condition-lever-set", 0);
	}
});

var condStateInfo = func{
	if(getprop("/sim/q400/popups-enabled")==1 and getprop("/sim/aero") == "q400-jsb"){
		var condstateL=getprop("/controls/engines/engine[0]/condition-lever-state");
		if(condstateL==0){
			var condstateL2="FUEL OFF";
		}else if(condstateL==1){
			var condstateL2="START AND FEATHER";
		}else if(condstateL==2){
			var condstateL2="MIN 850";							
		}else if(condstateL==3){
			var condstateL2="900";
		}else if(condstateL==4){
			var condstateL2="MAX 1020";
		}else{
			var condstateL2="INVALID";
		}
		var condstateR=getprop("/controls/engines/engine[1]/condition-lever-state");
		if(condstateR==0){
			var condstateR2="FUEL OFF";
		}else if(condstateR==1){
			var condstateR2="START AND FEATHER";
		}else if(condstateR==2){
			var condstateR2="MIN 850";							
		}else if(condstateR==3){
			var condstateR2="900";
		}else if(condstateR==4){
			var condstateR2="MAX 1020";
		}else{
			var condstateR2="INVALID";
		}
		gui.popupTip("CONDITION L: "~condstateL2~"\nCONDITION R: "~condstateR2);
	}
}

var ias_sw=props.globals.getNode("instrumentation/airspeed-indicator/speed-below-130", 1);
var pwr0=props.globals.getNode("controls/engines/engine[0]/throttle", 1);
var pwr1=props.globals.getNode("controls/engines/engine[1]/throttle", 1);
var flap_sel=props.globals.getNode("controls/flight/flaps", 1);
var gear_down = props.globals.getNode("gear/gear[0]/position-norm", 1);

setlistener("instrumentation/airspeed-indicator/speed-below-130", func(i){
	if(i.getValue()==1 and gear_down.getValue()!=1){
		if((pwr0.getValue() < 0.1 and pwr1.getValue() < 0.1) or flap_sel.getValue() > 0.2){
			setprop("gear/warning-horn", 2);		
		}else if(pwr0.getValue() < 0.1 or pwr1.getValue() < 0.1){
			setprop("gear/warning-horn", 1);
		}else{
			setprop("gear/warning-horn", 0);
		}
	}else{
		setprop("gear/warning-horn", 0);
	}
});
	
setlistener("controls/engines/engine[0]/throttle", func(i){
	if(ias_sw.getValue()==1 and gear_down.getValue()!=1){
		if((pwr0.getValue() < 0.1 and pwr1.getValue() < 0.1) or flap_sel.getValue() > 0.2){
			setprop("gear/warning-horn", 2);		
		}else if(pwr0.getValue() < 0.1 or pwr1.getValue() < 0.1){
			setprop("gear/warning-horn", 1);
		}else{
			setprop("gear/warning-horn", 0);
		}
	}else{
		setprop("gear/warning-horn", 0);
	}
});	
	
setlistener("controls/engines/engine[1]/throttle", func(i){
	if(ias_sw.getValue()==1 and gear_down.getValue()!=1){
		if((pwr0.getValue() < 0.1 and pwr1.getValue() < 0.1) or flap_sel.getValue() > 0.2){
			setprop("gear/warning-horn", 2);		
		}else if(pwr0.getValue() < 0.1 or pwr1.getValue() < 0.1){
			setprop("gear/warning-horn", 1);
		}else{
			setprop("gear/warning-horn", 0);
		}
	}else{
		setprop("gear/warning-horn", 0);
	}
});	
	
setlistener("controls/flight/flaps", func(i){
	if(ias_sw.getValue()==1 and gear_down.getValue()!=1){
		if((pwr0.getValue() < 0.1 and pwr1.getValue() < 0.1) or flap_sel.getValue() > 0.2){
			setprop("gear/warning-horn", 2);		
		}else if(pwr0.getValue() < 0.1 or pwr1.getValue() < 0.1){
			setprop("gear/warning-horn", 1);
		}else{
			setprop("gear/warning-horn", 0);
		}
	}else{
		setprop("gear/warning-horn", 0);
	}
});	
