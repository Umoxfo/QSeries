setlistener("/controls/engines/engine[0]/condition-lever-state", func (i) {
	if(i==0){ #CUTOFF
		setprop("/controls/engines/engine[~n~]/cutoff-cmd", 1);
		setprop("/controls/engines/engine[~n~]/propeller-pitch", 0);
		setprop("/controls/engines/engine[~n~]/propeller-feather", 0);
	}else if(i==1){ #START&FEATHER
		setprop("/controls/engines/engine[~n~]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[~n~]/propeller-pitch", 0);
		setprop("/controls/engines/engine[~n~]/propeller-feather", 1);
	}else if(i==2){ #MIN 850
		setprop("/controls/engines/engine[~n~]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[~n~]/propeller-pitch", 0);
		setprop("/controls/engines/engine[~n~]/propeller-feather", 0);
	}else if(i==3){ #900
		setprop("/controls/engines/engine[~n~]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[~n~]/propeller-pitch", 0.294);
		setprop("/controls/engines/engine[~n~]/propeller-feather", 0);
	}else if(i==4){ #MAX 1020
		setprop("/controls/engines/engine[~n~]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[~n~]/propeller-pitch", 1);
		setprop("/controls/engines/engine[~n~]/propeller-feather", 0);
	}
	
	interpolate("/controls/engines/engine[~n~]/condition-lever-pos", i, 0.1);
});
		