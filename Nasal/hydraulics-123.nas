# Q100, 200 and 300 Hydraulic System
# Joshua Davidson (it0uchpods); D-ECHO

######
#Description
#There are 3(5) hydraulic systems: two main, two standby powering the two main and one emergency

#############
# Init Vars #
#############

var hyd_init = func {
	setprop("/controls/hydraulic/eng1-pump", 1);
	setprop("/controls/hydraulic/eng2-pump", 1);
	setprop("/controls/hydraulic/elec-pump-sys3", 1);
	setprop("/controls/hydraulic/ptu", 0);
	#setprop("/controls/hydraulic/rat-man", 0);
	#setprop("/controls/hydraulic/rat", 0);
	#setprop("/controls/hydraulic/rat-deployed", 0);
	setprop("/controls/hydraulic/isol-valve3", 0);
	setprop("/controls/hydraulic/isol-valve-btn3", 0);
	setprop("/systems/hydraulic/ptu-active", 0);
	setprop("/systems/hydraulic/psi-main-1", 0);
	setprop("/systems/hydraulic/psi-main-2", 0);
	setprop("/systems/hydraulic/psi-stby-1", 0);
	setprop("/systems/hydraulic/psi-stby-2", 0);
	setprop("/systems/hydraulic/psi-emergency", 0);
	setprop("/systems/hydraulic/spoiler3and4-inhibit", 0);
	setprop("/systems/hydraulic/spoiler-inhibit", 0);
	setprop("/controls/gear/brake-parking", 0);
	setprop("/systems/hydraulic/qty-1", 2);
	setprop("/systems/hydraulic/qty-2", 3);
	hyd_timer.start();
}

var op1 = props.globals.getNode("engines/engine[1]/oil-pressure-psi", 1);
var op1below = props.globals.getNode("engines/engine[1]/oil-pressure-low", 1);
var lg_sel = props.globals.getNode("controls/gear/gear-down", 1);
var lg_pos = props.globals.getNode("gear/gear[0]/position-norm", 1);
var ptu_man = props.globals.getNode("controls/hydraulic/ptu-man", 1);
var flap_sel = props.globals.getNode("controls/flight/flaps", 1);
var edp1_serv = props.globals.getNode("systems/hydraulic/edp1-serviceable", 1);
var edp2_serv = props.globals.getNode("systems/hydraulic/edp2-serviceable", 1);
var spu1_serv = props.globals.getNode("systems/hydraulic/spu1-serviceable", 1);
var spu2_serv = props.globals.getNode("systems/hydraulic/spu2-serviceable", 1);

var op1below = props.globals.initNode("engines/engine[1]/oil-pressure-low", 0, "BOOL");
var ptu_man = props.globals.initNode("controls/hydraulic/ptu-man", 0, "BOOL");
var edp1_serv = props.globals.initNode("systems/hydraulic/edp1-serviceable", 1, "BOOL");
var edp2_serv = props.globals.initNode("systems/hydraulic/edp2-serviceable", 1, "BOOL");
var spu1_serv = props.globals.initNode("systems/hydraulic/spu1-serviceable", 1, "BOOL");
var spu2_serv = props.globals.initNode("systems/hydraulic/spu2-serviceable", 1, "BOOL");

setprop("controls/gear/gear-down", 1);

#######################
# Main Hydraulic Loop #
#######################

var master_hyd = func {
	var eng1_pump_sw = getprop("/controls/hydraulic/eng1-pump");
	var eng2_pump_sw = getprop("/controls/hydraulic/eng2-pump");
	var elec_pump_3_sw = getprop("/controls/hydraulic/elec-pump-sys3");
	var spu1_sw = getprop("/controls/hydraulic/spu1_sw");
	var spu2_sw = getprop("/controls/hydraulic/spu2_sw");
	var spu1_act = getprop("/controls/hydraulic/spu1_act");
	var spu2_act = getprop("/controls/hydraulic/spu2_act");
	var psi_main_1 = getprop("/systems/hydraulic/psi-main-1");
	var psi_main_2 = getprop("/systems/hydraulic/psi-main-2");
	var rpmapu = getprop("/engines/APU/rpm");
	var runningL = getprop("/engines/engine[0]/running");
	var runningR = getprop("/engines/engine[1]/running");
	var dc_ess = getprop("/systems/electrical/bus/dc-ess");
	var psi_diff = psi_main_1 - psi_main_2;
	var gs = getprop("/velocities/groundspeed-kt");
	var leak1 = getprop("/systems/failures/hyd1");
	var leak2 = getprop("/systems/failures/hyd2");
	var leak3 = getprop("/systems/failures/hyd3");
	var eng1_pump_fail = getprop("/systems/failures/pump1") or 0;
	var eng2_pump_fail = getprop("/systems/failures/pump2") or 0;
	var ptu_fail = getprop("/systems/failures/ptu");
	var spu_fail = getprop("/systems/failures/spu");
	var parkbrakeInp = getprop("/controls/gear/brake-parking");
	var brakeLInp = getprop("/controls/gear/brake-left");
	var brakeRInp = getprop("/controls/gear/brake-right");
	var flaps = getprop("/controls/flight/flaps");
	var wow1 = getprop("/gear/gear[1]/wow");
	var spu1_volts = getprop("/systems/electrical/outputs/stby-hyd-pump[0]");
	var spu2_volts = getprop("/systems/electrical/outputs/stby-hyd-pump[1]");
	var volts = getprop("/systems/electrical/volts");
	
	
	var ptu_active = getprop("/systems/hydraulic/ptu-active");
	
	#Standby Power Unit
	#activation:
	#	NORM
	#		flap lever != 0
	#		resp. engine pump fail
	#	manual ON
	#	TODO replace volts with correct AC variable freq busses
	if((spu1_sw or (flap_sel.getValue() != 0 and edp1_serv.getValue()==0)) and spu1_volts>15){
		setprop("/controls/hydraulic/spu1_act", 1);
	}else{
		setprop("/controls/hydraulic/spu1_act", 0);
	}
	if((spu2_sw or (flap_sel.getValue() != 0 and edp2_serv.getValue()==0)) and spu2_volts>15){
		setprop("/controls/hydraulic/spu2_act", 1);
	}else{
		setprop("/controls/hydraulic/spu2_act", 0);
	}
	
	#see also hydraulics-123.xml
        
        if(psi_main_2>2900){
            setprop("/controls/gear/brake-parking-int", parkbrakeInp);
        }else{
            setprop("/controls/gear/brake-parking-int", 0);
        }
        
        if(psi_main_1>2900){
            setprop("/controls/gear/brake-left-int", brakeLInp);
            setprop("/controls/gear/brake-right-int", brakeRInp);
        }else{
            setprop("/controls/gear/brake-left-int", 0);
            setprop("/controls/gear/brake-right-int", 0);
        }
        
        if(op1.getValue() < 42){
		if(op1below.getValue()==0){
			op1below.setValue(1);
		}
	}else{
		if(op1below.getValue()==1){
			op1below.setValue(0);
		}
	}
        
}

#############
# PTU Logic #
#############
#Automatic activation when
#	eng 2 loss of oil pressure
#	LDG GEAR UP
#	LDG GEAR not fully retracted
#Manual activation with ptu switchlight
setlistener("engines/engine[1]/oil-pressure-low", func(i){
	if((op1below.getValue()==1 and lg_sel.getValue()==0 and lg_pos.getValue()!=0) or ptu_man.getValue()==1){
		setprop("/controls/hydraulic/ptu", 1);
	}else{
		setprop("/controls/hydraulic/ptu", 0);
	}
});

setlistener("controls/gear/gear-down", func(i){
	if((op1below.getValue()==1 and lg_sel.getValue()==0 and lg_pos.getValue()!=0) or ptu_man.getValue()==1){
		setprop("/controls/hydraulic/ptu", 1);
	}else{
		setprop("/controls/hydraulic/ptu", 0);
	}
});

setlistener("gear/gear[0]/position-norm", func(i){
	if((op1below.getValue()==1 and lg_sel.getValue()==0 and lg_pos.getValue()!=0) or ptu_man.getValue()==1){
		setprop("/controls/hydraulic/ptu", 1);
	}else{
		setprop("/controls/hydraulic/ptu", 0);
	}
});

setlistener("controls/hydraulic/ptu-man", func(i){
	if((op1below.getValue()==1 and lg_sel.getValue()==0 and lg_pos.getValue()!=0) or ptu_man.getValue()==1){
		setprop("/controls/hydraulic/ptu", 1);
	}else{
		setprop("/controls/hydraulic/ptu", 0);
	}
});

#######################
# Various Other Stuff #
#######################

setlistener("/controls/gear/gear-down", func {
	var psi_main_2 = getprop("/systems/hydraulic/psi-main-2") or 0;
	var gearDownInp=getprop("/controls/gear/gear-down");
	if(psi_main_2>2900){
            setprop("/controls/gear/gear-down-int", gearDownInp);
        }
        
	var down = getprop("/controls/gear/gear-down-int");
	if (!down and (getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow") or getprop("/gear/gear[2]/wow"))) {
		setprop("/controls/gear/gear-down-int", 1);
	}
});

setlistener("/controls/flight/flaps", func {
        var psi_main_1 = getprop("/systems/hydraulic/psi-main-1") or 0;
        var flapInp=getprop("/controls/flight/flaps");
        if(psi_main_1>2900){
            setprop("/controls/flight/flaps-int", flapInp);
        }
});

###################
# Update Function #
###################

var update_hydraulic = func {
	master_hyd();
}

var hyd_timer = maketimer(0.2, update_hydraulic);



setlistener("/sim/signals/fdm-initialized", func{
    hyd_init();
    print("Hydraulic system loaded");
});
