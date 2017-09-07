setlistener("/sim/signals/fdm-initialized", func {
    settimer(update_FADEC, 5);
    print("FADEC (Full Authority Digital Engine Control) loaded.");
});

setlistener("/controls/engines/engine[0]/condition-lever-state", func {
	var i=getprop("/controls/engines/engine[0]/condition-lever-state");
	if(i==0){ #CUTOFF
		setprop("/controls/engines/engine[0]/cutoff-cmd", 1);
		setprop("/controls/engines/engine[0]/condition", 0);
		setprop("/controls/engines/engine[0]/propeller-pitch", 0);
		setprop("/controls/engines/engine[0]/propeller-feather", 0);
	}else if(i==1){ #START&FEATHER
		setprop("/controls/engines/engine[0]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[0]/condition", 0.5);
		setprop("/controls/engines/engine[0]/propeller-pitch", 0);
		setprop("/controls/engines/engine[0]/propeller-feather", 1);
	}else if(i==2){ #MIN 850
		setprop("/controls/engines/engine[0]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[0]/condition", 1);
		setprop("/controls/engines/engine[0]/propeller-pitch", 0);
		setprop("/controls/engines/engine[0]/propeller-feather", 0);
	}else if(i==3){ #900
		setprop("/controls/engines/engine[0]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[0]/condition", 1);
		setprop("/controls/engines/engine[0]/propeller-pitch", 0.294);
		setprop("/controls/engines/engine[0]/propeller-feather", 0);
	}else if(i==4){ #MAX 1020
		setprop("/controls/engines/engine[0]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[0]/condition", 1);
		setprop("/controls/engines/engine[0]/propeller-pitch", 1);
		setprop("/controls/engines/engine[0]/propeller-feather", 0);
	}
	
	interpolate("/controls/engines/engine[0]/condition-lever-pos", i, 0.1);
});

setlistener("/controls/engines/engine[1]/condition-lever-state", func {
	var i=getprop("/controls/engines/engine[1]/condition-lever-state");
	if(i==0){ #CUTOFF
		setprop("/controls/engines/engine[1]/cutoff-cmd", 1);
		setprop("/controls/engines/engine[1]/condition", 0);
		setprop("/controls/engines/engine[1]/propeller-pitch", 0);
		setprop("/controls/engines/engine[1]/propeller-feather", 0);
	}else if(i==1){ #START&FEATHER
		setprop("/controls/engines/engine[1]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[1]/condition", 0.5);
		setprop("/controls/engines/engine[1]/propeller-pitch", 0);
		setprop("/controls/engines/engine[1]/propeller-feather", 1);
	}else if(i==2){ #MIN 850
		setprop("/controls/engines/engine[1]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[1]/condition", 1);
		setprop("/controls/engines/engine[1]/propeller-pitch", 0);
		setprop("/controls/engines/engine[1]/propeller-feather", 0);
	}else if(i==3){ #900
		setprop("/controls/engines/engine[1]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[1]/condition", 1);
		setprop("/controls/engines/engine[1]/propeller-pitch", 0.294);
		setprop("/controls/engines/engine[1]/propeller-feather", 0);
	}else if(i==4){ #MAX 1020
		setprop("/controls/engines/engine[1]/cutoff-cmd", 0);
		setprop("/controls/engines/engine[1]/condition", 1);
		setprop("/controls/engines/engine[1]/propeller-pitch", 1);
		setprop("/controls/engines/engine[1]/propeller-feather", 0);
	}
	
	interpolate("/controls/engines/engine[1]/condition-lever-pos", i, 0.1);
});

#FADEC loop
var update_FADEC = func{
    #Automatical ignition setting
    var ignitionL=getprop("/controls/engines/engine[0]/ignition"); # 1=NORM (AUTO) 0=FORCE OFF
    var ignitionR=getprop("/controls/engines/engine[1]/ignition"); # 1=NORM (AUTO) 0=FORCE OFF
    var runningL=getprop("/engines/engine[0]/running");
    var runningR=getprop("/engines/engine[1]/running");
    var starterL=getprop("/controls/engines/engine[0]/starter");
    var starterR=getprop("/controls/engines/engine[1]/starter");
    
    if(ignitionL and !runningL and starterL){
        setprop("/controls/engines/fadec/ignitionL", 1);
    }else{
        setprop("/controls/engines/fadec/ignitionL", 0);
    }
    
    if(ignitionR and !runningR and starterR){
        setprop("/controls/engines/fadec/ignitionR", 1);
    }else{
        setprop("/controls/engines/fadec/ignitionR", 0);
    }

    

    #Engine System
    var cutoffcmdL=getprop("/controls/engines/engine[0]/cutoff-cmd") or 0;
    var cutoffcmdR=getprop("/controls/engines/engine[1]/cutoff-cmd") or 0;
    var n2L=getprop("/engines/engine[0]/n2");
    var n2R=getprop("/engines/engine[1]/n2");
    var runningL=getprop("/engines/engine[0]/running");
    var runningR=getprop("/engines/engine[1]/running");
    var starterL=getprop("/controls/engines/engine[0]/starter");
    var starterR=getprop("/controls/engines/engine[1]/starter");
    var ignitionL=getprop("/controls/engines/fadec/ignitionL");
    var ignitionR=getprop("/controls/engines/fadec/ignitionR");

    if(!cutoffcmdL and runningL or !cutoffcmdL and starterL and n2L>=15 and ignitionL) {
        setprop("/controls/engines/engine[0]/cutoff", 0);
    }else{
        setprop("/controls/engines/engine[0]/cutoff", 1);
    }


    if(!cutoffcmdL and runningR or !cutoffcmdR and starterR and n2R>=15 and ignitionR) {
        setprop("/controls/engines/engine[1]/cutoff", 0);
    }else{
        setprop("/controls/engines/engine[1]/cutoff", 1);
    }
    
    
    #Set some values so that all scripts work well
    setprop("/engines/engine[0]/n2", (getprop("/engines/engine[0]/thruster/rpm")/1020)*100);
    setprop("/engines/engine[1]/n2", (getprop("/engines/engine[1]/thruster/rpm")/1020)*100);
    setprop("/engines/engine[0]/rpm", getprop("/engines/engine[0]/thruster/rpm"));
    setprop("/engines/engine[1]/rpm", getprop("/engines/engine[1]/thruster/rpm"));
    
    settimer(update_FADEC, 0);
}