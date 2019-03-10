# Q400 FMS/EFIS by D-ECHO based on
# A3XX Lower ECAM Canvas
# Joshua Davidson (it0uchpods)

#sources: http://www.smartcockpit.com/docs/Q400-Fuel.pdf http://www.smartcockpit.com/docs/Q400-Electrical.pdf http://www.smartcockpit.com/docs/Q400-Indicating_and_Recording_Systems.pdf

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}

var FMS_startup = nil;
var FMS_main = nil;
var mainpage = props.globals.getNode("/instrumentation/FMS/inputs/main-page", 1); #Main pages are: STARTUP, DATA, NAV, VNAV, DTO, LIST, FUEL, FPL, PERF, TUNE
var page_number = props.globals.getNode("/instrumentation/FMS/inputs/page-number", 1);
var pages = props.globals.getNode("/instrumentation/FMS/pages", 1);
var previous_page = props.globals.getNode("/instrumentation/FMS/previous-page", 1);
var next_page = props.globals.getNode("/instrumentation/FMS/next-page", 1);

var mainpage = props.globals.initNode("/instrumentation/FMS/inputs/main-page", "STARTUP", "STRING");
var page_number = props.globals.initNode("/instrumentation/FMS/inputs/page-number", 1, "INT");
var pages = props.globals.initNode("/instrumentation/FMS/pages", 1, "INT");
var previous_page = props.globals.initNode("/instrumentation/FMS/previous-page", "", "STRING");
var next_page = props.globals.initNode("/instrumentation/FMS/next-page", "", "STRING");



var canvas_FMS_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "BoeingCDU-Large.ttf";
		};

		canvas.parsesvg(canvas_group, file, {"font-mapper": font_mapper});

		var svg_keys = me.getKeys();
		
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();
			foreach (var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var clip_el = canvas_group.getElementById(key ~ "_clip");
			if (clip_el != nil) {
				clip_el.setVisible(0);
				var tran_rect = clip_el.getTransformedBounds();
				var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
				tran_rect[1], # 0 ys
				tran_rect[2], # 1 xe
				tran_rect[3], # 2 ye
				tran_rect[0]); #3 xs
				#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
				me[key].set("clip", clip_rect);
				me[key].set("clip-frame", canvas.Element.PARENT);
			}
			if(key=="horizon"){
				var center=me[key].getCenter();
			}
			}
		}

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		if ((getprop("/systems/electrical/DC/lmain-bus/volts") or 0) >= 10 and getprop("/instrumentation/FMS/onoff") == 1) {
			if(mainpage.getValue()=="startup"){
				FMS_main.page.hide();
				FMS_startup.page.show();
			}else{
				FMS_main.page.show();
				FMS_startup.page.hide();
			}
		} else {
			FMS_main.page.hide();
			FMS_startup.page.hide();
		}
		
		settimer(func me.update(), 0.02);
	},
};

var canvas_FMS_startup = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_FMS_startup,canvas_FMS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		
		settimer(func me.update(), 0.1);
	},
};

var canvas_FMS_main = {
	new: func(canvas_group, file) {
		var m = { parents: [canvas_FMS_main,canvas_FMS_base] };
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["heading","heading.left","heading.right","arrow.1L","arrow.2L","arrow.3L","arrow.4L","arrow.5L","arrow.1R","arrow.2R","arrow.3R","arrow.4R","arrow.5R","text.big1L","text.big2L","text.big3L","text.big4L","text.big5L","text.big1R","text.big2R","text.big3R","text.big4R","text.big5R","text.small1L","text.small2L","text.small3L","text.small4L","text.small5L","text.small1R","text.small2R","text.small3R","text.small4R","text.small5R"];
	},
	update: func() {
		var mp = mainpage.getValue();
		var number = page_number.getValue();
		var total_number = pages.getValue();
		me["heading"].setText(mp~" "~number~" / "~total_number);
		me["heading.left"].setText(previous_page.getValue());
		me["heading.right"].setText(next_page.getValue());
		
		if(mp=="DATA"){
			me["arrow.1L"].show();
			me["arrow.2L"].show();
			me["arrow.3L"].show();
			me["arrow.4L"].show();
			me["arrow.5L"].show();
			me["arrow.1R"].show();
			me["arrow.2R"].show();
			me["arrow.3R"].show();
			me["arrow.4R"].show();
			me["arrow.5R"].show();
			me["text.big1L"].setText(" NAV DATA");
			me["text.big2L"].setText(" PILOT DATA");
			me["text.big3L"].setText(" PERF");
			me["text.big4L"].setText(" DISK");
			me["text.big5L"].setText(" HOLD POS");
			me["text.big1R"].setText("CABIN DISP ");
			me["text.big2R"].setText("MFD DISP ");
			me["text.big3R"].setText("UNILINK ");
			me["text.big4R"].setText("MSTR XFILL ");
			me["text.big5R"].setText("MAINT ");
			me["text.small1L"].setText("");
			me["text.small2L"].setText("");
			me["text.small3L"].setText("");
			me["text.small4L"].setText("");
			me["text.small5L"].setText("");
			me["text.small1R"].setText("");
			me["text.small2R"].setText("");
			me["text.small3R"].setText("");
			me["text.small4R"].setText("");
			me["text.small5R"].setText("");
		}else{
			me["arrow.1L"].hide();
			me["arrow.2L"].hide();
			me["arrow.3L"].hide();
			me["arrow.4L"].hide();
			me["arrow.5L"].hide();
			me["arrow.1R"].hide();
			me["arrow.2R"].hide();
			me["arrow.3R"].hide();
			me["arrow.4R"].hide();
			me["arrow.5R"].hide();
		}
		
		settimer(func me.update(), 0.1);		
	},
};


setlistener("sim/signals/fdm-initialized", func {
	FMS_display = canvas.new({
		"name": "FMS",
		"size": [1024, 638],
		"view": [1024, 638],
		"mipmapping": 1
	});
	FMS_display.addPlacement({"node": "FMS.screen"});
	var groupFMS_startup = FMS_display.createGroup();
	var groupFMS_main = FMS_display.createGroup();

	FMS_startup = canvas_FMS_startup.new(groupFMS_startup, "Aircraft/QSeries/Models/Cockpit/Pedestal/Front/FMS/FMS_startup.svg");
	FMS_main = canvas_FMS_main.new(groupFMS_main, "Aircraft/QSeries/Models/Cockpit/Pedestal/Front/FMS/FMS_main.svg");

	FMS_startup.update();
	FMS_main.update();
	canvas_FMS_base.update();
});

var showFMS = func {
	var dlg = canvas.Window.new([512, 319], "dialog").set("resize", 1);
	dlg.setCanvas(FMS_display);
}

setlistener("/instrumentation/FMS/onoff", func(i){
	if(i.getValue()==1){
		interpolate("/instrumentation/FMS/startup", 1, 2);
	}else{
		setprop("/instrumentation/FMS/startup", 0);
	}
});

setlistener("/instrumentation/FMS/startup", func(i){
	if(i.getValue()==1){
		setprop("/instrumentation/FMS/inputs/main-page", "DATA");
	}else{
		setprop("/instrumentation/FMS/inputs/main-page", "STARTUP");
	}
});

setlistener("/instrumentation/FMS/inputs/main-page", func(i){
	if(i.getValue()=="DATA"){
		pages.setValue(4);
	}
	
	page_number.setValue(1); # Reset to first page of row

});

var nextPage = func() {
	if(page_number.getValue()<pages.getValue()){
		page_number.setValue(page_number.getValue()+1);
	}else{
		page_number.setValue(1);
	}	
}

var previousPage = func() {
	if(page_number.getValue()>1){
		page_number.setValue(page_number.getValue()-1);
	}else{
		page_number.setValue(pages.getValue());
	}	
}
