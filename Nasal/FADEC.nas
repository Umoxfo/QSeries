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

    

    #Engine System
    var conditionL=getprop("/controls/engines/engine[0]/condition");
    var conditionR=getprop("/controls/engines/engine[1]/condition");
    var n2L=getprop("/engines/engine[0]/n2");
    var n2R=getprop("/engines/engine[1]/n2");
    var runningL=getprop("/engines/engine[0]/running");
    var runningR=getprop("/engines/engine[1]/running");
    var starterL=getprop("/controls/engines/engine[0]/starter");
    var starterR=getprop("/controls/engines/engine[1]/starter");
    var ignitionL=getprop("/controls/engines/fadec/ignitionL");
    var ignitionR=getprop("/controls/engines/fadec/ignitionR");

    if(conditionL>=0.2 and runningL or conditionL>=0.2 and starterL and n2L>=15 and ignitionL) {
        setprop("/controls/engines/engine[0]/cutoff", 0);
    }else{
        setprop("/controls/engines/engine[0]/cutoff", 1);
    }


    if(conditionR>=0.2 and runningR or conditionR>=0.2 and starterR and n2R>=15 and ignitionR) {
        setprop("/controls/engines/engine[1]/cutoff", 0);
    }else{
        setprop("/controls/engines/engine[1]/cutoff", 1);
    }
    
    #Condition Lever Mode 1 START&FEATHER
    if(conditionL==0.2){
        setprop("/controls/engines/engine/fadec/feather", 1);
        setprop("/controls/engines/engine/fadec/propeller-rpm", 500);
    }else{
        setprop("/controls/engines/engine/fadec/feather", 0);
    }
    if(conditionR==0.2){
        setprop("/controls/engines/engine[1]/fadec/feather", 1);
        setprop("/controls/engines/engine[1]/fadec/propeller-rpm", 500);
    }else{
        setprop("/controls/engines/engine[1]/fadec/feather", 0);
    }
    #Condition Lever Mode 2 MIN850-MAX1020
    if(conditionL>=0.4){
        setprop("/controls/engines/engine/fadec/propeller-rpm", conditionL*1020);
    }
    if(conditionR>=0.4){
        setprop("/controls/engines/engine[1]/fadec/propeller-rpm", conditionR*1020);
    }
    
    
    #Set some values so that all scripts work well
    setprop("/engines/engine[0]/n2", (getprop("/engines/engine[0]/thruster/rpm")/1020)*100);
    setprop("/engines/engine[1]/n2", (getprop("/engines/engine[1]/thruster/rpm")/1020)*100);
    setprop("/engines/engine[0]/rpm", getprop("/engines/engine[0]/thruster/rpm"));
    setprop("/engines/engine[1]/rpm", getprop("/engines/engine[1]/thruster/rpm"));
    
    settimer(update_FADEC, 0);
}