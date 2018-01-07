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