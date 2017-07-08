setlistener("/sim/signals/fdm-initialized", func {
    settimer(update_FADEC, 5);
    print("FADEC (Full Authority Digital Engine Control) loaded.");
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

    
    settimer(update_FADEC, 0);
}