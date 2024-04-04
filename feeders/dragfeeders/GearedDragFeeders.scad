// Parameters for a parameterized drag feeder for the YY1 with better peeling

// The width of the tape (mm)
feederWidth = 8;

// The reduction in size for the gear shaft
gearShaftReduction = 1;

// Bearing inner diameter (mm)
bearingID = 4;

// Bearing outer diameter (mm)
bearingOD = 11;

// Bearing length (mm) for the gear portion
bearingLength = 3.5;

// Bearing OD margin
bearingODMargin = 0.05 ;

// Bearing ID Margin
bearingIDMargin = 0.0;

// Number of gear pins
gearPins = 20;

// How much smaller should the gear itself be
gearReduction = 0.3;

// Gear pin radius
gearPinRadius = 0.5;

// Gear pin length
gearPinLength = 1.2;

// Gear pin base height;
gearPinBaseHeight = 0.4;

// Gear pin vertical space
gearPinVerticalSpace = 0;

// Derived
gearRadius = (gearPins * 4) / (2 * PI) - gearReduction;

gearHeight = 5.5;

toothSize = 3.0;

toothRadius = 8.5;

holderSpace = 2.8;

sideThick = 1.5;

springSpace = toothRadius + toothSize/sqrt(2)/2;

springThick = 0.8;

springMargin = 0.8;

springLong = 8;


// Bearing cushion in the gear
bearingCushionDepth = 0.5;

module gearTeeth() {
  for(i = [0: gearPins * 2]) {
     rotate([0, 0, i * (360 / (gearPins * 2))])
     translate([toothRadius,-1 * toothSize / sqrt(2),0]) rotate([0,0,45]) cube([toothSize,toothSize,gearHeight]);
  
  }
  cylinder(h=gearHeight, r=toothRadius);

  }

module gear(){
  // Circumference = 2 * pi * r
  cylinder(h=1, r=gearRadius, $fn=100);
  difference(){
    gearTeeth();
     translate([0,0,gearHeight-bearingLength]) cylinder(h=feederWidth, r=bearingOD/2 + bearingODMargin, $fn=100);
     translate([0,0,gearHeight-bearingLength-bearingCushionDepth]) cylinder(h=feederWidth, r = bearingOD/2 - 1, $fn=100);
  }
  for(i = [0:gearPins]) {
    translate([0,0,gearPinBaseHeight])
    rotate([0, 90, i * (360 / gearPins)]){
    cylinder(h=gearPinLength + gearRadius, r=gearPinRadius, $fn=100);
    translate([0,0,gearPinLength + gearRadius]) sphere(r=gearPinRadius, $fn=100);
    }
  }
}

// make the center hollow so the bearing can be pushed out
module gearIntersection(){
  difference(){
  intersection(){
     translate([0,0,gearPinVerticalSpace]) gear();
     translate([-1000, -1000, 0]) cube([2000, 2000, 2000]);
  }
   translate([0,0,-1]) cylinder(h=100, r=bearingOD/2 -1, $fn=100);

   }

}


module spring(){
  rotate([0,0,45]) cube([toothSize, toothSize, feederWidth-holderSpace]);
  
  translate([-springLong, -springThick/2 +  sqrt(2) * toothSize/2, 0]) cube([springLong * 2, springThick, sideThick]);
}

module springCutout(){
  translate([-springLong, sqrt(2) * toothSize/2 - springMargin - springThick/2, 0]) cube([2 * springLong,springThick + 2 * springMargin,10]);
  
  translate([0, -springMargin*sqrt(2), 0])rotate([0,0,45]) cube([toothSize + 2 * springMargin,toothSize + 2 * springMargin,100]);

  //translate([-springLong, -springSpace-springThick/2, 0]) cube([2 * springLong, springThick + 2 * springMargin, 100]);

}

module gearHolder(){
  cylinder(h=feederWidth-holderSpace, r = bearingID/2 - bearingIDMargin, $fn=100);
  
  cylinder(h=feederWidth-holderSpace-bearingLength, r= bearingID/2 + 1, $fn=100);

  difference(){
  translate([-10,-3,0]) cube([20,20,sideThick]);
  translate([0, springSpace, -0.1]) springCutout();
  }
  translate([0, springSpace, 0]) spring();
}


gearHolder();
translate([25,0,0]) 
gearIntersection();

// gearTeeth();