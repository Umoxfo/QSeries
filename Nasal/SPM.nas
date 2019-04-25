#This simulates the (Q400) Stall Protection Module

var stick_push_shutoff = props.globals.getNode("controls/flight/stick-pusher-shutoff", 1);
var stick_push_shutoff = props.globals.initNode("controls/flight/stick-pusher-shutoff", 0, "BOOL");
var stick_push_serv = props.globals.initNode("/controls/flight/stick-pusher-serviceable", 1, "BOOL");
var stick_push_signal = props.globals.initNode("controls/flight/stick-pusher-signal", 0, "BOOL");

var stick_shaker1_serv = props.globals.initNode("/controls/flight/stick-shaker-serviceable[0]", 1, "BOOL");
var stick_shaker2_serv = props.globals.initNode("/controls/flight/stick-shaker-serviceable[1]", 1, "BOOL");
var stick_shaker1_signal = props.globals.initNode("controls/flight/stick-shaker-signal[0]", 0, "BOOL");
var stick_shaker2_signal = props.globals.initNode("controls/flight/stick-shaker-signal[1]", 0, "BOOL");

var power = props.globals.getNode("systems/electrical/DC/lessential-bus/volts", 1);


setlistener("/controls/flight/stick-pusher-signal-int", func(i) {
	if(i.getValue()==1){
		if(!stick_push_shutoff.getValue() and stick_push_serv.getValue() and stick_shaker1_signal.getValue() and stick_shaker2_signal.getValue() and power.getValue() > 10){
			stick_push_signal.setValue(1);
		}
	}else{
		stick_push_signal.setValue(0);
	}
});

setlistener("/controls/flight/stick-shaker-signal-int[0]", func(i) {
	if(i.getValue()==1){
		if(stick_shaker1_serv.getValue() and power.getValue() > 10){
			stick_shaker1_signal.setValue(1);
		}
	}else{
		stick_shaker1_signal.setValue(0);
	}
});

setlistener("/controls/flight/stick-shaker-signal-int[1]", func(i) {
	if(i.getValue()==1){
		if(stick_shaker2_serv.getValue() and power.getValue() > 10){
			stick_shaker2_signal.setValue(1);
		}
	}else{
		stick_shaker2_signal.setValue(0);
	}
});
