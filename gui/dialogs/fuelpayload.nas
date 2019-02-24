#    This file is part of the QSeries based on extra500
#


#Load Constants
var JETA_LBGAL=getprop("/qseries/const/JETA_LBGAL");
var ad_const=160; 	#160lbs average adult weight
var ch_const=80;	#80lbs average children weight

var clamp = func(value,min=0.0,max=0.0){
	if(value < min) {value = min;}
	if(value > max) {value = max;}
	return value;
}

var MyWindow = {
  # Constructor
  #
  # @param size ([width, height])
  new: func(size, type = nil, id = nil)
  {
    var ghost = canvas._newWindowGhost(id);
    var m = {
      parents: [MyWindow, canvas.PropertyElement, ghost],
      _node: props.wrapNode(ghost._node_ghost)
    };

    m.setInt("size[0]", size[0]);
    m.setInt("size[1]", size[1]);

    # TODO better default position
    m.move(0,0);

    # arg = [child, listener_node, mode, is_child_event]
    setlistener(m._node, func m._propCallback(arg[0], arg[2]), 0, 2);
    if( type )
      m.set("type", type);

    m._isOpen = 1;
    return m;
  },
  # Destructor
  del: func
  {
    me._node.remove();
    me._node = nil;

    if( me["_canvas"] != nil )
    {
      me._canvas.del();
      me._canvas = nil;
    }
     me._isOpen = 0;
  },
  # Create the canvas to be used for this Window
  #
  # @return The new canvas
  createCanvas: func()
  {
    var size = [
      me.get("size[0]"),
      me.get("size[1]")
    ];

    me._canvas = canvas.new({
      size: [2 * size[0], 2 * size[1]],
      view: size,
      placement: {
        type: "window",
        id: me.get("id")
      }
    });

    me._canvas.addEventListener("mousedown", func me.raise());
    return me._canvas;
  },
  # Set an existing canvas to be used for this Window
  setCanvas: func(canvas_)
  {
    if( !isa(canvas_, canvas.Canvas) )
      return debug.warn("Not a canvas.Canvas");

    canvas_.addPlacement({type: "window", index: me._node.getIndex()});
    me['_canvas'] = canvas_;
  },
  # Get the displayed canvas
  getCanvas: func()
  {
    return me['_canvas'];
  },
  getCanvasDecoration: func()
  {
    return canvas.wrapCanvas(me._getCanvasDecoration());
  },
  setPosition: func(x, y)
  {
    me.setInt("tf/t[0]", x);
    me.setInt("tf/t[1]", y);
  },
  move: func(x, y)
  {
    me.setInt("tf/t[0]", me.get("tf/t[0]", 10) + x);
    me.setInt("tf/t[1]", me.get("tf/t[1]", 30) + y);
  },
  # Raise to top of window stack
  raise: func()
  {
    # on writing the z-index the window always is moved to the top of all other
    # windows with the same z-index.
    me.setInt("z-index", me.get("z-index", 0));
  },
# private:
  _propCallback: func(child, mode)
  {
    if( !me._node.equals(child.getParent()) )
      return;
    var name = child.getName();

    # support for CSS like position: absolute; with right and/or bottom margin
    if( name == "right" )
      me._handlePositionAbsolute(child, mode, name, 0);
    else if( name == "bottom" )
      me._handlePositionAbsolute(child, mode, name, 1);

    # update decoration on type change
    else if( name == "type" )
    {
      if( mode == 0 )
        settimer(func me._updateDecoration(), 0);
    }
  },
  _handlePositionAbsolute: func(child, mode, name, index)
  {
    # mode
    #   -1 child removed
    #    0 value changed
    #    1 child added

    if( mode == 0 )
      me._updatePos(index, name);
    else if( mode == 1 )
      me["_listener_" ~ name] = [
        setlistener
        (
          "/sim/gui/canvas/size[" ~ index ~ "]",
          func me._updatePos(index, name)
        ),
        setlistener
        (
          me._node.getNode("size[" ~ index ~ "]"),
          func me._updatePos(index, name)
        )
      ];
    else if( mode == -1 )
      for(var i = 0; i < 2; i += 1)
        removelistener(me["_listener_" ~ name][i]);
  },
  _updatePos: func(index, name)
  {
    me.setInt
    (
      "tf/t[" ~ index ~ "]",
      getprop("/sim/gui/canvas/size[" ~ index ~ "]")
      - me.get(name)
      - me.get("size[" ~ index ~ "]")
    );
  },
  _onClose : func(){
	me.del();
  },
  _updateDecoration: func()
  {
    var border_radius = 9;
    me.set("decoration-border", "25 1 1");
    me.set("shadow-inset", int((1 - math.cos(45 * D2R)) * border_radius + 0.5));
    me.set("shadow-radius", 5);
    me.setBool("update", 1);

    var canvas_deco = me.getCanvasDecoration();
    canvas_deco.addEventListener("mousedown", func me.raise());
    canvas_deco.set("blend-source-rgb", "src-alpha");
    canvas_deco.set("blend-destination-rgb", "one-minus-src-alpha");
    canvas_deco.set("blend-source-alpha", "one");
    canvas_deco.set("blend-destination-alpha", "one");

    var group_deco = canvas_deco.getGroup("decoration");
    var title_bar = group_deco.createChild("group", "title_bar");
    title_bar
      .rect( 0, 0,
             me.get("size[0]"),
             me.get("size[1]"), #25,
             {"border-top-radius": border_radius} )
      .setColorFill(0.25,0.24,0.22)
      .setStrokeLineWidth(0);

    var style_dir = "gui/styles/AmbianceClassic/decoration/";

    # close icon
    var x = 10;
    var y = 3;
    var w = 19;
    var h = 19;
    var ico = title_bar.createChild("image", "icon-close")
                       .set("file", style_dir ~ "close_focused_normal.png")
                       .setTranslation(x,y);
    ico.addEventListener("click", func me._onClose());
    ico.addEventListener("mouseover", func ico.set("file", style_dir ~ "close_focused_prelight.png"));
    ico.addEventListener("mousedown", func ico.set("file", style_dir ~ "close_focused_pressed.png"));
    ico.addEventListener("mouseout",  func ico.set("file", style_dir ~ "close_focused_normal.png"));

    # title
    me._title = title_bar.createChild("text", "title")
                         .set("alignment", "left-center")
                         .set("character-size", 14)
                         .set("font", "LiberationFonts/LiberationSans-Bold.ttf")
                         .setTranslation( int(x + 1.5 * w + 0.5),
                                          int(y + 0.5 * h + 0.5) );

    var title = me.get("title", "Canvas Dialog");
    me._node.getNode("title", 1).alias(me._title._node.getPath() ~ "/text");
    me.set("title", title);

    title_bar.addEventListener("drag", func(e) {
      if( !ico.equals(e.target) )
        me.move(e.deltaX, e.deltaY);
    });
  }
};

var COLOR = {};
COLOR["Red"] 			= "rgb(244,28,33)";
COLOR["Green"] 			= "#008000";
COLOR["Black"] 			= "#000000";
COLOR["btnActive"] 		= "#9ec5ffff";
COLOR["btnPassive"] 		= "#003ea2ff";
COLOR["btnEnable"] 		= "#2a7fffff";
COLOR["btnBorderEnable"] 	= "#0000ffff";
COLOR["btnDisable"] 		= "#8c939dff";
COLOR["btnBorderDisable"] 	= "#69697bff";


var SvgWidget = {
	new: func(dialog,canvasGroup,name){
		var m = {parents:[SvgWidget]};
		m._class = "SvgWidget";
		m._dialog 	= dialog;
		m._listeners 	= [];
		m._name 	= name;
		m._group	= canvasGroup;
		return m;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	setListeners : func(instance) {
		
	},
	init : func(instance=me){
		
	},
	deinit : func(){
		me.removeListeners();	
	},
	
};

var TankWidget = {
	new: func(dialog,canvasGroup,name,lable,index,refuelable=1){
		var m = {parents:[TankWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "TankWidget";
		m._index 	= index;
		m._refuelable 	= refuelable;
		m._lable 	= lable;
		m._nLevel 	= props.globals.initNode("/consumables/fuel/tank["~m._index~"]/level-gal_us",0.0,"DOUBLE");
		m._nCapacity 	= props.globals.initNode("/consumables/fuel/tank["~m._index~"]/capacity-gal_us",0.0,"DOUBLE");
		
		m._level	= m._nLevel.getValue();
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._level / m._capacity;
			
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cLevel 	= m._group.getElementById(m._name~"_Fuel_Level");
		m._cDataName 	= m._group.getElementById(m._name~"_Data_Name");
		#m._cDataMax 	= m._group.getElementById(m._name~"_Data_Max");
		m._cDataLevel 	= m._group.getElementById(m._name~"_Data_Level");
		#m._cDataPercent	= m._group.getElementById(m._name~"_Data_Percent");
				
		m._cDataName.setText(m._lable);
		#m._cDataMax.setText(sprintf("%3.0f",m._capacity * JETA_LBGAL));
		m._cDataLevel.setText(sprintf("%3.0f",m._level * JETA_LBGAL));
		#m._cDataPercent.setText(sprintf("%3.1f",m._fraction*100.0));
		
		
		m._left		= m._cFrame.get("coord[0]");
		m._right	= m._cFrame.get("coord[2]");
		m._width	= m._right - m._left;
		#me.cLeftAuxFrame.addEventListener("wheel",func(e){me._onLeftAuxFuelChange(e);});
		
		return m;
	},
	setListeners : func(instance) {
		
		append(me._listeners, setlistener(me._nLevel,func(n){me._onFuelLevelChange(n);},1,0) );
		if(me._refuelable == 1){
			me._cFrame.addEventListener("drag",func(e){me._onFuelInputChange(e);});
			me._cLevel.addEventListener("drag",func(e){me._onFuelInputChange(e);});
			me._cFrame.addEventListener("wheel",func(e){me._onFuelInputChange(e);});
			me._cLevel.addEventListener("wheel",func(e){me._onFuelInputChange(e);});
			
		}
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onFuelLevelChange : func(n){
		me._level	= n.getValue();
		me._fraction	= me._level / me._capacity;
		
		me._cDataLevel.setText(sprintf("%3.0f",me._level * JETA_LBGAL));
		#me._cDataPercent.setText(sprintf("%3.1f",me._fraction*100.0));
		
		me._cLevel.set("coord[2]", me._left + (me._width * me._fraction));
			
	},
	_onFuelInputChange : func(e){
		var newFraction = 0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._width);
		}else{
			newFraction = me._fraction + (e.deltaX/me._width);
		}
		newFraction = clamp(newFraction,0.0,1.0);
		me._nLevel.setValue(me._capacity * newFraction);
		
	},
};

var TankerWidget = {
	new: func(dialog,canvasGroup,name,lable,widgets){
		var m = {parents:[TankerWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "TankerWidget";
		m._lable 	= lable;
		m._widget	= {};
		m._nLevel 	= props.globals.initNode("/fdm/jsbsim/propulsion/total-fuel-lbs",0.0,"DOUBLE");
		
		m._level		= 0;
		m._capacity		= 0;
		m._levelTotal		= 0;
		m._capacityTotal	= 0;
		
		#debug.dump(m._widget);
		foreach(tank;keys(widgets)){
			if(widgets[tank] != nil){
				if(widgets[tank]._class == "TankWidget"){
					m._widget[tank] = widgets[tank];
				}
			}
		}
		
		foreach(tank;keys(m._widget)){
			
			if (m._widget[tank]._refuelable == 1){
			#print ("TankerWidget.new() ... "~tank);
				
				m._capacity 	+= m._widget[tank]._capacity;
				m._level	+= m._widget[tank]._level;
			}
			m._capacityTotal 	+= m._widget[tank]._capacity;
			m._levelTotal		+= m._widget[tank]._level;
			
		}
		m._fraction		= m._level / m._capacity;
		m._fractionTotal	= m._levelTotal / m._capacityTotal;
		
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cLevel 	= m._group.getElementById(m._name~"_Level");
		m._cDataName 	= m._group.getElementById(m._name~"_Data_Name");
		m._cDataMax 	= m._group.getElementById(m._name~"_Data_Max");
		m._cDataLevel 	= m._group.getElementById(m._name~"_Data_Level");
		m._cDataPercent	= m._group.getElementById(m._name~"_Data_Percent");
		
		m._cTotalDataName 	= m._group.getElementById(m._name~"_Total_Data_Name");
		m._cTotalDataMax 	= m._group.getElementById(m._name~"_Total_Data_Max");
		m._cTotalDataLevel 	= m._group.getElementById(m._name~"_Total_Data_Level");
		m._cTotalDataPercent	= m._group.getElementById(m._name~"_Total_Data_Percent");
		
		m._cWeightFuel		 	= m._group.getElementById("Weight_Fuel");
		
		m._cDataName.setText(m._lable);
		m._cDataMax.setText(sprintf("%3.0f",m._capacity * JETA_LBGAL));
		m._cDataLevel.setText(sprintf("%3.0f",m._level * JETA_LBGAL));
		m._cDataPercent.setText(sprintf("%3.1f",m._fraction*100.0));
		
		m._cTotalDataName.setText("Total");
		m._cTotalDataMax.setText(sprintf("%3.0f",m._capacityTotal * JETA_LBGAL));
		m._cTotalDataLevel.setText(sprintf("%3.0f",m._levelTotal * JETA_LBGAL));
		m._cTotalDataPercent.setText(sprintf("%3.1f",m._fractionTotal*100.0));
		
		
		m._bottom	= m._cFrame.get("coord[3]");
		m._top		= m._cFrame.get("coord[1]");
		m._height	= m._bottom - m._top;
		#me.cLeftAuxFrame.addEventListener("wheel",func(e){me._onLeftAuxFuelChange(e);});
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(me._nLevel,func(n){me._onLevelChange(n);},1,0) );
		
		me._cFrame.addEventListener("drag",func(e){me._onFuelInputChange(e);});
		me._cLevel.addEventListener("drag",func(e){me._onFuelInputChange(e);});
		me._cFrame.addEventListener("wheel",func(e){me._onFuelInputChange(e);});
		me._cLevel.addEventListener("wheel",func(e){me._onFuelInputChange(e);});

	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onLevelChange : func(n){
		me._level 	= 0;
		me._levelTotal 	= 0;
		foreach(tank;keys(me._widget)){
			if (me._widget[tank]._refuelable == 1){
				me._level	+= me._widget[tank]._level;
			}
			me._levelTotal		+= me._widget[tank]._level;
		}
		
		me._fraction		= me._level / me._capacity;
		me._fractionTotal	= me._levelTotal / me._capacityTotal;
		
		me._cDataLevel.setText(sprintf("%3.0f",me._level * JETA_LBGAL));
		me._cDataPercent.setText(sprintf("%3.1f",me._fraction*100.0));
		
		me._cTotalDataLevel.setText(sprintf("%3.0f",me._levelTotal * JETA_LBGAL));
		me._cTotalDataPercent.setText(sprintf("%3.1f",me._fractionTotal*100.0));
		
		me._cWeightFuel.setText(sprintf("%3.0f",me._levelTotal * JETA_LBGAL));
		
		me._cLevel.set("coord[1]", me._bottom - (me._height * me._fraction));
	
	},
	_onFuelInputChange : func(e){
		var newFraction = 0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._height);
		}else{
			newFraction = me._fraction - (e.deltaY/me._height);
		}
		newFraction = clamp(newFraction,0.0,1.0);
		
# 		foreach(tank;keys(me._widget)){
# 			if (me._widget[tank]._refuelable == 1){
# 				me._widget[tank]._nLevel.setValue(me._widget[tank]._capacity * newFraction);
# 			}
# 			
# 		}
		
		me.orderFuel(me._capacity * newFraction);
		
	},
	
	orderFuel : func(amount){
		var fuelamount  = (amount) /2;
		var fuelAux	= fuelamount - me._widget.LeftMain._capacity;
		if (fuelAux > me._widget.LeftAux._capacity){
			fuelAux = me._widget.LeftAux._capacity;
		}
		
		if (fuelAux > 0){
			me._widget.LeftMain._nLevel.setValue(me._widget.LeftMain._capacity);
			me._widget.RightMain._nLevel.setValue(me._widget.RightMain._capacity);
						
			me._widget.LeftAux._nLevel.setValue(fuelAux);
			me._widget.RightAux._nLevel.setValue(fuelAux);
		}else{
			me._widget.LeftMain._nLevel.setValue(fuelamount);
			me._widget.RightMain._nLevel.setValue(fuelamount);
			
			me._widget.LeftAux._nLevel.setValue(0);
			me._widget.RightAux._nLevel.setValue(0);
			
		}
		
	}
};



var WeightWidget = {
	new: func(dialog,canvasGroup,name,widgets){
		var m = {parents:[WeightWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "WeightWidget";
		m._widget = {};
		
		foreach(w;keys(widgets)){
			if(widgets[w] != nil){
				if(widgets[w]._class == "PayloadWidget"){
					m._widget[w] = widgets[w];
				}
			}
		}
		
		

		m._cWeightGross	 		= m._group.getElementById("Weight_Gross");
		m._cWeightWarning	 	= m._group.getElementById("Weight_Warning");
		m._cWeightPayload	 	= m._group.getElementById("Weight_Payload");
		m._cWeightPAX		 	= m._group.getElementById("Weight_PAX");

		m._cWeight_Limits_lbs	 	= m._group.getElementById("Weight_Limits_lbs");
		m._cWeight_Limits_in	 	= m._group.getElementById("Weight_Limits_in");
		
		
		
		m._nCGx 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-x-in");
		m._nCGy 	= props.globals.initNode("/fdm/jsbsim/inertia/cg-y-in");
		m._nGross 	= props.globals.initNode("/fdm/jsbsim/inertia/weight-lbs");
		m._nPayload 	= props.globals.initNode("/fdm/jsbsim/inertia/weight-lbs");
		m._nEmpty 	= props.globals.initNode("/fdm/jsbsim/inertia/empty-weight-lbs");
		m._nRamp 	= props.globals.initNode("/limits/mass-and-balance/maximum-ramp-mass-lbs");
		m._nTakeoff 	= props.globals.initNode("/limits/mass-and-balance/mtow-lbs");
		m._nLanding 	= props.globals.initNode("/limits/mass-and-balance/maximum-landing-mass-lbs");
		m._nMac 	= props.globals.initNode("/limits/mass-and-balance/mac-mm",1322.0,"DOUBLE");
		m._nMac0 	= props.globals.initNode("/limits/mass-and-balance/mac-0-mm",3200.0,"DOUBLE");
		
		
		m._cgX  	= 0;
		m._cgY  	= 0;
		m._empty 	= 0;
		m._payload 	= 0;
		m._pax		= 0;
		m._gross 	= 0;
		m._ramp  	= 0;
		m._takeoff  	= 0;
		m._landing 	= 0;
		m._MACPercent 	= 0.0; # %
		m._MAC 			= m._nMac.getValue(); # mm
		m._MAC_0 		= m._nMac0.getValue(); # mm
		m._MAC_Limit_Min	= 0.17; #%
		m._MAC_Limit_Max	= 0.35; #%
		
		m._takeoff = m._nTakeoff.getValue();
		
		return m;
	},
	setListeners : func(instance) {
		append(me._listeners, setlistener(fuelPayload._nGrossWeight,func(n){me._onGrossWeightChange(n);},1,0) );
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	_onGrossWeightChange : func(n){
		
		me._gross = me._nGross.getValue();
		me._cWeightGross.setText(sprintf("%5d",me._gross));
		
		
		me._payload = getprop("/payload/weight[0]/weight-lb")+getprop("/payload/weight[1]/weight-lb")+getprop("/payload/weight[2]/weight-lb")+getprop("/payload/weight[3]/weight-lb");
		me._cWeightPayload.setText(sprintf("%.0f",me._payload));
		
		me._pax = getprop("/payload/weight[1]/weight-lb")+getprop("/payload/weight[2]/weight-lb");
		me._cWeightPAX.setText(sprintf("%.0f",me._pax));
		
		if (me._gross > me._takeoff){
			me._cWeightWarning.show();
			me._cWeightGross.setColor(COLOR["Red"]);
		}else{
			me._cWeightWarning.hide();
			me._cWeightGross.setColor(COLOR["Black"]);
		}
		
		
	},
	
	
	
};

var PayloadWidget = {
	new: func(dialog,canvasGroup,name,lable,index){
		var m = {parents:[PayloadWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "PayloadWidget";
		m._index 	= index;
		m._lable 	= lable;
		
		#debug.dump(m._listCategoryKeys);
		
		m._nRoot	= props.globals.getNode("/payload/weight["~m._index~"]");
		m._nLable 	= m._nRoot.initNode("name","","STRING");
		
		### HACK : listener on /payload/weight[0]/weight-lb not working
		###	   two props one for fdm(weight-lb) one for dialog(nt-weight-lb) listener
		m._nWeightFdm 	= m._nRoot.initNode("weight-lb",0.0,"DOUBLE");
		m._weight	= m._nWeightFdm.getValue(); # lbs
		m._nWeight 	= m._nRoot.initNode("nt-weight-lb",m._weight,"DOUBLE");
		
		m._nCapacity 	= m._nRoot.initNode("max-lb",0.0,"DOUBLE");
		
		m._capacity	= m._nCapacity.getValue();
		m._fraction	= m._weight / m._capacity;
		
		m._cFrame 	= m._group.getElementById(m._name~"_Frame");
		m._cLevel 	= m._group.getElementById(m._name~"_Level");
		m._cLBS 	= m._group.getElementById(m._name~"_Lbs");
	
		m._cLBS.setText(sprintf("%3.0f",m._weight));
				
		
		m._left		= m._cFrame.get("coord[0]");
		m._right	= m._cFrame.get("coord[2]");
		m._width	= m._right - m._left;
		
		return m;
	},
	setListeners : func(instance) {
		### FIXME : use one property remove the HACK
		append(me._listeners, setlistener(me._nWeight,func(n){me._onWeightChange(n);},1,0) );
				
		me._cFrame.addEventListener("drag",func(e){me._onInputChange(e);});
		me._cLevel.addEventListener("drag",func(e){me._onInputChange(e);});
		me._cFrame.addEventListener("wheel",func(e){me._onInputChange(e);});
		me._cLevel.addEventListener("wheel",func(e){me._onInputChange(e);});
		
			
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	setWeight : func(weight){
		me._weight = weight;
		
		### HACK : set two props 
		me._nWeight.setValue(me._weight);
		me._nWeightFdm.setValue(me._weight);
		
	},
	_onWeightChange : func(n){
		me._weight	= me._nWeight.getValue();
		#print("PayloadWidget._onWeightChange() ... "~me._weight);
		
		me._fraction	= me._weight / me._capacity;
		
		me._cLBS.setText(sprintf("%3.0f",me._weight));
		
		me._cLevel.set("coord[2]", me._left + (me._width * me._fraction));
		
		
			
	},
	_onInputChange : func(e){
		var newFraction =0;
		if(e.type == "wheel"){
			newFraction = me._fraction + (e.deltaY/me._width);
		}else{
			newFraction = me._fraction + (e.deltaX/me._width);
		}
		newFraction = clamp(newFraction,0.0,1.0);
		me._weight = me._capacity * newFraction;
		
		me.setWeight(me._weight);

	},
};

var PAXWidget = {
	new: func(dialog,canvasGroup,name,lable,index){
		var m = {parents:[PAXWidget,SvgWidget.new(dialog,canvasGroup,name)]};
		m._class = "PAXWidget";
		m._index 	= index;
		m._lable 	= lable;
		
		#debug.dump(m._listCategoryKeys);
		
		m._nRoot	= props.globals.getNode("/payload/weight["~m._index~"]");
		m._nLable 	= m._nRoot.initNode("name","","STRING");
		
		### HACK : listener on /payload/weight[0]/weight-lb not working
		###	   two props one for fdm(weight-lb) one for dialog(nt-weight-lb) listener
		m._nWeightFdm 	= m._nRoot.initNode("weight-lb",0.0,"DOUBLE");
		m._weight	= m._nWeightFdm.getValue(); # lbs
		m._nWeight 	= m._nRoot.initNode("nt-weight-lb",m._weight,"DOUBLE");
		
		m._nCapacity 	= m._nRoot.initNode("max-lb",0.0,"DOUBLE");
		
		m._nAdults	= m._nRoot.initNode("adults",5,"DOUBLE");
		m._nAdultsMax	= m._nRoot.initNode("adults-max",42,"DOUBLE");
		m._nChildren	= m._nRoot.initNode("children",5,"DOUBLE");
		m._nChildrenMax	= m._nRoot.initNode("children-max",42,"DOUBLE");
		
		m._fractionAd	= m._nAdults.getValue() / m._nAdultsMax.getValue();
		m._fractionCh	= m._nChildren.getValue() / m._nChildrenMax.getValue();
		
		m._cFrameAd 	= m._group.getElementById(m._name~"_FrameAd");
		m._cLevelAd 	= m._group.getElementById(m._name~"_LevelAd");
		m._cNAd 	= m._group.getElementById(m._name~"_nAd");
		m._cFrameCh	= m._group.getElementById(m._name~"_FrameCh");
		m._cLevelCh 	= m._group.getElementById(m._name~"_LevelCh");
		m._cNCh 	= m._group.getElementById(m._name~"_nCh");
	
		m._cNAd.setText(sprintf("%3d",m._nAdults.getValue()));
		m._cNCh.setText(sprintf("%3d",m._nChildren.getValue()));
				
		
		m._leftAd	= m._cFrameAd.get("coord[0]");
		m._leftCh	= m._cFrameCh.get("coord[0]");
		m._right	= m._cFrameAd.get("coord[2]");
		m._width	= m._right - m._leftAd;
		
		return m;
	},
	setListeners : func(instance) {
		### FIXME : use one property remove the HACK
		append(me._listeners, setlistener(me._nAdults,func(n){me._onNAdChange(n);},1,0) );
		append(me._listeners, setlistener(me._nChildren,func(n){me._onNChChange(n);},1,0) );
				
		me._cFrameAd.addEventListener("drag",func(e){me._onInputChangeAd(e);});
		me._cLevelAd.addEventListener("drag",func(e){me._onInputChangeAd(e);});
		me._cFrameAd.addEventListener("wheel",func(e){me._onInputChangeAd(e);});
		me._cLevelAd.addEventListener("wheel",func(e){me._onInputChangeAd(e);});
				
		me._cFrameCh.addEventListener("drag",func(e){me._onInputChangeCh(e);});
		me._cLevelCh.addEventListener("drag",func(e){me._onInputChangeCh(e);});
		me._cFrameCh.addEventListener("wheel",func(e){me._onInputChangeCh(e);});
		me._cLevelCh.addEventListener("wheel",func(e){me._onInputChangeCh(e);});
		
			
		
	},
	init : func(instance=me){
		me.setListeners(instance);
	},
	deinit : func(){
		me.removeListeners();	
	},
	setWeight : func(weight){
		me._weight = weight;
		### HACK : set two props 
		me._nWeight.setValue(me._weight);
		me._nWeightFdm.setValue(me._weight);
		
	},
	_onNAdChange : func(n){
		var nAd = me._nAdults.getValue();
	
		me._fractionAd	= nAd / me._nAdultsMax.getValue();
		
		me._cNAd.setText(sprintf("%3.0f",nAd));
		
		me._cLevelAd.set("coord[2]", me._leftAd + (me._width * me._fractionAd));
		
		me.setWeight(me._nAdults.getValue()*ad_const+me._nChildren.getValue()*ch_const);
		
		
			
	},
	_onNChChange : func(n){
		var nCh = me._nChildren.getValue();
	
		me._fractionCh	= nCh / me._nChildrenMax.getValue();
		
		me._cNCh.setText(sprintf("%3.0f",nCh));
		
		me._cLevelCh.set("coord[2]", me._leftCh + (me._width * me._fractionCh));
		
		me.setWeight(me._nAdults.getValue()*ad_const+me._nChildren.getValue()*ch_const);;
		
		
			
	},
	_onInputChangeAd : func(e){
		var newFraction =0;
		if(e.type == "wheel"){
			newFraction = me._fractionAd + (e.deltaY/me._width);
		}else{
			newFraction = me._fractionAd + (e.deltaX/me._width);
		}
		newFraction = clamp(newFraction,0.0,1.0);
		me._nAdults.setValue(me._nAdultsMax.getValue() * newFraction);
		
		if((me._nChildren.getValue()+me._nAdults.getValue())>42){
			me._nChildren.setValue(42-me._nAdults.getValue());
		}
		
		me.setWeight(me._weight);

	},
	_onInputChangeCh : func(e){
		var newFraction =0;
		if(e.type == "wheel"){
			newFraction = me._fractionCh + (e.deltaY/me._width);
		}else{
			newFraction = me._fractionCh + (e.deltaX/me._width);
		}
		newFraction = clamp(newFraction,0.0,1.0);
		me._nChildren.setValue(me._nChildrenMax.getValue() * newFraction);
		
		if((me._nChildren.getValue()+me._nAdults.getValue())>42){
			me._nAdults.setValue(42-me._nChildren.getValue());
		}
		
		me.setWeight(me._weight);

	},
};


var FuelPayloadClass = {
	new : func(){
		var m = {parents:[FuelPayloadClass]};
		m._nRoot 	= props.globals.initNode("/qseries/dialog/fuel");
		
		m._nGrossWeight	= props.globals.initNode("/fdm/jsbsim/inertia/nt-weight-lbs",0.0,"DOUBLE"); #listener on weight-lbs not possible, set via system in Systems/fuelpayload.xml
		
		m._name  = "Fuel and Payload";
		m._title = "Fuel and Payload Settings";
		m._fdmdata = {
			grosswgt : "/fdm/jsbsim/inertia/weight-lbs",
			payload  : "/payload",
			cg       : "/fdm/jsbsim/inertia/cg-x-in",
		};
		m._tankIndex = [
			"LeftAuxiliary",
			"LeftMain",
			"LeftCollector",
			"Engine",
			"RightCollector",
			"RightMain",
			"RightAuxiliary"
			];
		
		
		m._listeners = [];
		m._dlg 		= nil;
		m._canvas 	= nil;
		
		m._isOpen = 0;
		m._isNotInitialized = 1;
		
		m._widget = {
			Left	 	: nil,
			Right	 	: nil,
			Cockpit 	: nil,
			Cargo	 	: nil,
			PAXFront 	: nil,
			PAXRear		: nil,
		};
		

		return m;
	},
	toggle : func(){
		if(me._dlg != nil){
			if (me._dlg._isOpen){
				me.close();
			}else{
				me.open();	
			}
		}else{
			me.open();
		}
	},
	close : func(){
		me._dlg.del();
		me._dlg = nil;
	},
	removeListeners  :func(){
		foreach(l;me._listeners){
			removelistener(l);
		}
		me._listeners = [];
	},
	setListeners : func(instance) {
	
		
	},
	_onClose : func(){
		#print("FuelPayloadClass._onClose() ... ");
		me.removeListeners();
		me._dlg.del();
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].deinit();
				me._widget[widget] = nil;
			}
		}
		
	},
	open : func(){
		if(getprop("/gear/gear[0]/wow") == 1){
			me.openFuel();
		}else{
			screen.log.write("Fuel and payload dialog not available in air!");
		}
		
	},
	openFuel : func(){
		
		
		me._dlg = MyWindow.new([768,576], "dialog");
		me._dlg._onClose = func(){
			fuelPayload._onClose();
		}
		me._dlg.set("title", "Fuel and Payload");
		me._dlg.move(100,100);
		
		
		me._canvas = me._dlg.createCanvas();
		me._canvas.set("background", "#3F3D38");
		
		me._group = me._canvas.createGroup();

		canvas.parsesvg(me._group, "Aircraft/QSeries/gui/dialogs/FuelPayload.svg",{"font-mapper": global.canvas.FontMapper("Liberation Sans", "bold")});
		
		
		
		me._widget.Left 		= TankWidget.new(me,me._group,"Left","Left Fuel Tank:",0,1);
		me._widget.Right 		= TankWidget.new(me,me._group,"Right","Right Fuel Tank:",1,1);
		
		#me._widget.tanker		= TankerWidget.new(me,me._group,"Tanker","Tanker",me._widget);

		me._widget.Cockpit		= PayloadWidget.new(me,me._group,"Cockpit","Cockpit Crew",0);
		me._widget.Cargo		= PayloadWidget.new(me,me._group,"Cargo","Cargo",3);
		me._widget.PAXFront		= PAXWidget.new(me,me._group,"Front","Passengers Front",1);
		me._widget.PAXRear		= PAXWidget.new(me,me._group,"Rear","Passengers Rear",2);
		
		me._widget.weight = WeightWidget.new(me,me._group,"Weight",me._widget);
		
		foreach(widget;keys(me._widget)){
			if(me._widget[widget] != nil){
				me._widget[widget].init();
			}
		}
		
		#me.setListeners();
		
		
	},
	_onNotifyChange : func(n){

	},
	_onFuelTotalChange : func(n){
		
	}
	
};

var fuelPayload = FuelPayloadClass.new();

