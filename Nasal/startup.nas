# Simple Autostart for now -- I am super lazy :D -JD

var autostartupthing = func {
	setprop("/controls/electric/autostart", 1);

	setprop("/controls/electric/battery-switch", 1);
	setprop("/controls/engines/engine[0]/starter", 1);
	setprop("/controls/engines/engine[1]/starter", 1);
	setprop("/controls/engines/engine[0]/ignition-switch", 1);
	setprop("/controls/engines/engine[1]/ignition-switch", 1);
	setprop("/controls/electric/engine[0]/generator", 1);
	setprop("/controls/electric/engine[1]/generator", 1);
	setprop("/sim/model/door-positions/passengerF/position-norm", 1);
	setprop("/controls/cabin/seatbelts", 1);
	setprop("/controls/cabin/nosmoking", 1);
	setprop("/it-autoflight/input/yd", 1);
	if(getprop("/sim/aero")=="q400-jsb"){
		settimer(func {
			setprop("/controls/engines/engine[0]/condition-lever-state", 4);
			setprop("/controls/engines/engine[1]/condition-lever-state", 4);
		}, 2);
	}else{
		settimer(func {
			setprop("/controls/engines/engine[0]/condition-lever-state", 2);
			setprop("/controls/engines/engine[1]/condition-lever-state", 2);
		}, 2);
	}
}

setlistener("/engines/engine[0]/running", func{
    if(getprop("/engines/engine[0]/running")==1){
        setprop("/controls/electric/autostart", 0);
    }
});

var aglgears = func {
	var agl = getprop("/position/altitude-agl-ft") or 0;
	var aglft = agl - 11.101;  # is the position from the Q400 above ground
	var aglm = aglft * 0.3048;
	setprop("/position/gear-agl-ft", aglft);
	setprop("/position/gear-agl-m", aglm);

	settimer(aglgears, 0.01);
}

aglgears();
