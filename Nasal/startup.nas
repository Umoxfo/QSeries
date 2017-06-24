# Simple Autostart for now -- I am super lazy :D -JD

var autostartupthing = func {
	setprop("/systems/electrical/batt-volts", 15);

	setprop("/controls/engines/engine[0]/starter", 1);
	setprop("/controls/engines/engine[1]/starter", 1);
	settimer(func {
		setprop("/controls/engines/engine[0]/cutoff", 0);
		setprop("/controls/engines/engine[1]/cutoff", 0);
	}, 2);
}

setlistener("/sim/signals/fdm-initialized", func {
	itaf.ap_init();
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