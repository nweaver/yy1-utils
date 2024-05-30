// Parameters for a parameterized drag feeder for the YY1 with better peeling
// The idea is that instead of using the under-tape tensioner (which gives inconsistant results depending on the component, the tape, etc), this uses a toothed wheel that engages the tape and has a 2mm step length.

// Layer height for the printer.  Should be .1mm, but can be changed.  This is used for the spacing on manual support.

// Initial version does not include a curve for output feeding, instead it just ends a bit early and the tape should just be manually routed into the discharge trench.

layerHeight = 0.1;

// The width of the tape (mm)
feederWidth = 8;

// The additional width for the entire feeder assembly
additionalWidth = 4;

// Cutoff before the end instead of a curve.
cutoffLength = 20;

// The length of a feeder unit
feederLength = 138 - cutoffLength;

// Where on the feeder the pick happens
pickStart = 25 - cutoffLength;

pickLength = 20;

// How deep the drag feeder pin is assumed to be
pinDepth = 5;

// And how wide the opening for it
pinWide = 2.4;

// Where on the feeder to include the friction unit
frictionLocation = 55;

// Where the base of the tape is located
tapeBase = 21.5;

// How thick the tape groove is:  Paper tape is 1.1mm thick max, plastic is 0.6mm.
tapeThick = 1.3;

// How much to support the sprocket side
supportSprocketSide = 1.75+1.25;

// How much to support the opposite side
supportOppositeSide = 0.7;

// How much additional tape clearance horizontally
tapeClearance = 0.5;

// Bearing inner diameter (mm)
bearingID = 4;

// Bearing outer diameter (mm)
bearingOD = 11;

// Bearing length (mm) for the portion that
// overlaps.  The bearing itself is 4mm 
// but we want some spacing
bearingLength = 3.5;

// Bearing OD margin, adjust in your printer for a snug fit.
bearingODMargin = 0.05 ;

// Bearing ID Margin, adjust in your printer for a snug fit.
bearingIDMargin = 0.0;

// Number of gear pins to engage the tape.
gearPins = 16;

// How much smaller should the gear itself be
gearReduction = 0.3;

// Gear pin radius, the holes are .75mm radius
// that it engages into
gearPinRadius = 0.5;

// Gear pin length
gearPinLength = 1.2;

// Gear pin base height;
gearPinBaseHeight = .45;

printGear = true;

printHolder = true;

printBase = true;

baseHeight = 8;
baseWidth = 10;
baseLength = 156;


// Derived, the radius for the 
// gear itself that engages in the tape
gearRadius = (gearPins * 4) / (2 * PI) - gearReduction;

// The distance between the center of the gear and the teeth on the tape itself
tapeOffset = gearRadius + gearReduction;

// The height of the gear that engages the pins.
gearHeight = 4.9 + (feederWidth - 8) ;

// The size of the teeth in the gear for engaging the friction spring.
toothSize = 4.0;

// The radius for locating the cubes that engage the friction spring.
toothRadius = 4.2;

holderSpace = 8.0 - 1.8;

sideThick = 2;

springSpace = toothRadius + toothSize/sqrt(2)/2 + 0; // 0.2;

springThick = 2.0;

springMargin = 0.8;

springLong = 8;

// Bearing cushion in the gear
bearingCushionDepth = 0.5;

// Thickness of the top
topThick = 0.8;

// Using 6mm magnets in the base

magnetRadius = 3.05;
magnetThick = 2.2;

magnetLoc1 = 10;
magnetLoc2 = feederLength - 10;
magnetLoc3 = feederLength/2;

notchOne = 30;

notchTwo = 95;

notchWidth = baseWidth;

margin = .2;



baseProfile = polygon(points = [[0,0],[0,baseHeight],[baseWidth, baseHeight],[baseWidth+2, 0]]);

module baseExtrusion(){
  rotate([90,0,90])
  linear_extrude(height=baseLength){
     polygon(points = [[0,0],[0,baseHeight],[baseWidth, baseHeight],[baseWidth+2, 0]]);
  }
}
 module baseHoleExtrusion(){
   rotate([0,0,0])
   linear_extrude(height=100) {
      polygon(points = [[-margin, -margin],
      [-margin, baseHeight+margin],
      [baseWidth+margin, baseHeight+margin],
      [baseWidth+2+margin, margin],
      [baseWidth+2+margin, 0]]);
        
   }
}

module base(){
  difference(){
//    baseHoleExtrusion();
    baseExtrusion();
    for(i = [0 : 3]) {
      translate([baseLength-5.5 - i * 46.5, baseWidth/2, -1]) cylinder(h=100, r=1.2);
    }
    
    }
}

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
     gear();
     translate([0,0,-1]) cylinder(h=100, r=bearingOD/2 -1, $fn=100);

   }

}


module spring(){
  intersection(){
  rotate([0,0,45]) cube([toothSize, toothSize, holderSpace]);
   translate([-10,-3,0]) cube([15,5.5,15]);
  }  
  translate([-springLong, -springThick/2 +  sqrt(2) * toothSize/2, 0]) cube([springLong * 2, springThick, sideThick]);
}

module springCutout(){
  translate([-springLong, sqrt(2) * toothSize/2 - springMargin - springThick/2, 0]) cube([2 * springLong,springThick + 2 * springMargin,10]);
  
  translate([0, -springMargin*sqrt(2), 0])rotate([0,0,45]) cube([toothSize + 2 * springMargin,toothSize + 2 * springMargin,100]);

  //translate([-springLong, -springSpace-springThick/2, 0]) cube([2 * springLong, springThick + 2 * springMargin, 100]);

}

trackRadius = gearRadius + 2.2;

module gearHolder(){
  cylinder(h=holderSpace, r = bearingID/2 - bearingIDMargin, $fn=100);
  
  cylinder(h=holderSpace-bearingLength, r= bearingID/2 + 1, $fn=100);

  difference(){
    cylinder(h=additionalWidth/2, r=trackRadius+3)
  translate([-feederLength+frictionLocation,-3,0]) cube([20,20,sideThick]);
  translate([0, springSpace, -0.1]) springCutout();
  }
  translate([0, springSpace, 0]) spring();
  
  difference(){
     union(){
     cylinder(h=feederWidth+additionalWidth, r=trackRadius+1, $fn=100);
     cylinder(h=1, r=trackRadius+3, $fn=100);
          translate([0,0,feederWidth+additionalWidth-1])     cylinder(h=1, r=trackRadius+3, $fn=100);
    
    
    translate([-43.5,22.5,0]) rotate([0,0,-45]){
   
     cube([50,29,2]);
     translate([0,0,feederWidth+2]) cube([50,29,2]);
     
     }
      translate([-18,0,0]) cylinder(h=feederWidth+additionalWidth, r=1.4, $fn=100);

 //         translate([-50,20,0]) rotate([0,0,-45]) cube([50,29,2]);
 
     }
     
     translate([0,0,additionalWidth/2])cylinder(h=50, r=trackRadius, $fn=100);
     translate([-50,12,-1]) cube(100);
       translate([0, springSpace, -0.1]) springCutout();
  
     translate([0,-7,additionalWidth/2]) cube([100,40, 100]);
     }
     
    
}

module stripHolder(){
  cube([feederLength, feederWidth + additionalWidth, 4]);
  difference() {cube([feederLength, additionalWidth/2 + supportOppositeSide, tapeBase + topThick + tapeThick]);
    translate([-1, additionalWidth/2 - tapeClearance, tapeBase])
    cube([feederLength+10, 100, tapeThick]);
  }
  
  difference() {
    translate([0, feederWidth + additionalWidth/2 - supportSprocketSide, 0]) cube([feederLength, additionalWidth/2 + supportSprocketSide, tapeBase + topThick + tapeThick]);
    translate([-1, feederWidth + additionalWidth/2 - supportSprocketSide - 1, tapeBase])
    cube([feederLength+10, 1 + supportSprocketSide + tapeClearance , tapeThick]);
  }
  translate([0,0,tapeBase+tapeThick]) cube([feederLength, feederWidth+additionalWidth,topThick]);
}

module stripHolderCuts(){
   difference(){
      stripHolder();
      translate([feederLength - pickStart - pickLength, additionalWidth/2+supportOppositeSide, tapeBase]) cube([pickLength, feederWidth-supportOppositeSide, 100]);
      
      translate([feederLength - pickStart - pickLength, 
        additionalWidth + feederWidth - 1.75 - pinWide,
        tapeBase - pinDepth]) cube([pickLength, pinWide, 100]);
        
     
     translate([feederLength - magnetLoc1, (feederWidth + additionalWidth)/2, -0.1]) cylinder(h=magnetThick+.1, r=magnetRadius, $fn=100);
     
          
     translate([feederLength - magnetLoc2, (feederWidth + additionalWidth)/2, -0.1]) cylinder(h=magnetThick+.1, r=magnetRadius, $fn=100);
     
          
     translate([feederLength - magnetLoc3, (feederWidth + additionalWidth)/2, -0.1]) cylinder(h=magnetThick+.1, r=magnetRadius, $fn=100);
     
     translate([feederLength-frictionLocation, -1, tapeBase+tapeOffset]) rotate([-90, 0, 0]) cylinder(h=100, r=gearRadius + gearPinLength+1, $fn=100);
     
    translate([notchOne-notchWidth/2, 20, 0]) rotate([90,0,0]) baseHoleExtrusion(); //cube([notchWidth, 100, notchHeight]);
    
     translate([notchTwo-notchWidth/2, 20, 0]) rotate([90,0,0]) baseHoleExtrusion(); //cube([notchWidth, 100, notchHeight]);
   }
   intersection(){
   translate([feederLength - frictionLocation, 0, tapeBase + tapeOffset]) rotate([-90,0,0]) gearHolder();
   cube(100);
   }
 }

if(printGear) {
// gearHolder();
translate([0,0,0]) 
gearIntersection();
}

if(printHolder) {
translate([20, 20,0 ]) rotate([0,-90,0]) stripHolderCuts();
}

if(printBase) {
translate([-baseLength/2,20 + feederWidth+10,0])
base();
}