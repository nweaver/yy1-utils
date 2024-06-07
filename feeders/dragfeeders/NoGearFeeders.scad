// Parameters for a parameterized drag feeder for the YY1 with better peeling

// The idea is that instead of using the under-tape tensioner (which gives inconsistant results depending on the component, the tape, etc), this uses a toothed wheel that engages the tape and has a 2mm step length.

// Initial version does not include a curve for output feeding, instead it just ends a bit early and the tape should just be manually routed into the discharge trench.  This is designed to also make it easier to remove the excess tape.


// The width of the tape (mm)
feederWidth = 8;

// The additional width for the entire feeder assembly
additionalWidth = 4;

// The length of a feeder unit
feederLength = 108;

// Where on the feeder the pick happens
pickStart = 8;

dragStart = 4;

// And the length of the opening
pickLength = feederWidth + 2; // 16;

// Drag length = 20;
dragLength = 20;

// How deep the drag feeder pin is assumed to be
pinDepth = -1;

// And how wide the opening for it
pinWide = 2.4;

// Where on the feeder to include the friction unit
frictionLocation = 45;

// Where the base of the tape is located
tapeBase = 21.5;

// How wide the tape groove is:  Paper tape is 1.1mm thick max, plastic is 0.6mm.
tapeThick = 1.3;

// How much to support the sprocket side
supportLeftSide = 1.75+1.25;

// How much to support the opposite side
supportRightSide = 0.75;

// How much additional tape clearance horizontally on each side
tapeClearance = 0.3;

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
gearPins = 20;

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
printGearHolder = true;

baseHeight = 8;
baseWidth = 10;
baseLength = 156;

feederBank = [8,8,8,8];


holeX = [30, 95];
holeY = [6, 12*4-6, 15];
holeR = 0.8;


// Derived, the radius for the 
// gear itself that engages in the tape:
// The pins are 4mm apart on the tape
gearRadius = (gearPins * 4) / (2 * PI) - gearReduction;

// The distance between the center of the gear and the teeth on the tape itself
tapeOffset = gearRadius + gearReduction;

// The height of the gear that engages the pins.
gearHeight = 5.2 + (feederWidth - 8) ;

// The size of the teeth in the gear for engaging the friction spring.
toothSize = 4.0;

// The radius for locating the cubes that engage the friction spring.
toothRadius = 5.6;

holderSpace = 8.0 - 1.8;



// Thickness of the top
topThick = 0.8;

// Using 8mmx3mm magnets in the base



screwGap = feederLength - 5;



notchWidth = baseWidth;

margin = .2;

baseTapeHeight = tapeBase;
profileHeight = tapeBase+3;
lowProfileTapeBase = 10;
curveDown = 31 - lowProfileTapeBase;
lowProfileHeight = lowProfileTapeBase + 3;
lowProfileLength = 50;




module profile() {
  width = feederWidth + additionalWidth;
  leftWidth = width - additionalWidth/2-supportLeftSide;
  leftTapeSlot = width - additionalWidth/2 + tapeClearance;
    rightTapeSlot = additionalWidth/2 - tapeClearance;
  rightWidth = additionalWidth/2 + supportRightSide;
  tapeBase = baseTapeHeight;
  tapeTop = tapeBase + tapeThick;
  height = profileHeight;
  polygon([[0,0],
          [0,height],
           [width, height],
           [width, 0],
           [leftWidth, 0],
           [leftWidth, tapeBase],
           [leftTapeSlot, tapeBase],
           [leftTapeSlot, tapeTop],
           [rightTapeSlot, tapeTop],
           [rightTapeSlot, tapeBase],
           [rightWidth, tapeBase],
           [rightWidth, 0]
           ]);
}

module curveProfile() {
  width = feederWidth + additionalWidth;
  leftWidth = width - additionalWidth/2-supportLeftSide;
  leftTapeSlot = width - additionalWidth/2 + tapeClearance;
    rightTapeSlot = additionalWidth/2 - tapeClearance;
  rightWidth = additionalWidth/2 + supportRightSide;
  tapeBase = baseTapeHeight;
  tapeTop = tapeBase + tapeThick;
  height = profileHeight;
  polygon([[0,0],
          [0,height],
           [width, height],
           [width, 0],
           [leftWidth, 0],
           [leftWidth, tapeBase-1.5],
           [leftTapeSlot, tapeBase-1.5],
           [leftTapeSlot, tapeTop],
           [rightTapeSlot, tapeTop],
           [rightTapeSlot, tapeBase-1.5],
           [rightWidth, tapeBase-1.5],
           [rightWidth, 0]
           ]);
}

module profileFeeder(){
difference(){
  // Want the angle to be such that the increase in 
  // height for each direction is half the difference.  
  // The bending radius should be 30 for both directions, centered
  // on the tape itself.  Because I'm referencing off the
  // top instead I'm having the bendRadius be 32.
  
  bendRadius = 32;
  
  heightDifference = (profileHeight-lowProfileHeight)/2;
  
  // Added height is (1 - cos(angle) * bendRadius, so 
  // we have cos(angle) = 1-heightDifference/bendRadius)
  
  profileAngle = acos(1-heightDifference/bendRadius);
  pickAt = feederLength-pickStart-pickLength;
  lowLength = lowProfileLength;
  curveLength = sin(profileAngle) * bendRadius;
  
  
  topOfCurveHeight = (1 - cos(profileAngle)) * bendRadius + lowProfileHeight ;
  
  union(){
  
  // First part, at the low range
  translate([0,0,lowProfileHeight-profileHeight]) rotate([90,0,90]) linear_extrude(lowLength) profile();

  // Then the curve up: its radius along
  // the top is profileHeight, along the bottom it is 2*profileHeight  
  translate([lowProfileLength,0,lowProfileHeight+bendRadius]) {
        rotate([0,90,90])
        rotate_extrude(angle=-profileAngle, $fn=100) 
        rotate(90) 
        translate([0, -profileHeight-bendRadius])
        curveProfile();
    }
    
    translate([lowProfileLength + 2 * curveLength, 0, 0]) {
      rotate([90,0,90]) linear_extrude(feederLength - lowLength - 2 * curveLength) profile();
    }
    
    translate([lowProfileLength + 2 * curveLength, 0, profileHeight-bendRadius]) { rotate([0,90,90])rotate_extrude(angle=-profileAngle, $fn=100) rotate(90) translate([0,bendRadius-profileHeight]) curveProfile();
    
    translate([curveDown, 0, 6])  
    rotate([0,90,90])rotate_extrude(angle=90, $fn=100) rotate(90) translate([0,bendRadius-profileHeight-6]) curveProfile();
    
    // cube(40);
    
    
    }
    
   
  }
   translate([-100,-100,-100]) cube([500,500,100]);
  }
}


module profileFeederAssembled(){
  difference() {
    union(){
    profileFeeder();
    cube([feederLength, feederWidth+additionalWidth, 1]);
    }
    translate([-10,-10,-100]) cube([100,100,100]);
     // Pin hole for the drag feeder
     translate([feederLength - dragStart - pickLength, 
        additionalWidth + feederWidth - 2.5 - pinWide,
        tapeBase - pinDepth]) cube([dragLength, pinWide-.5, 100]);

     translate([feederLength - pickStart - pickLength,
        additionalWidth/2+.75, tapeBase+0.01]) 
        cube([pickLength, feederWidth-additionalWidth/2-2.0, 100]);
          
     
     
     
      translate([feederLength - screwGap, -0.1, -0.1]) cube([8,50,3.5]);
     
  
          


    }


         


}




module displayHeads(){
  color("red") {
    translate([0,0,42]) cube([32,30,30]);
    translate([32+25,0,42]) cube([32,30,30]);
    }
}


module baseExtrusion(){
  rotate([90,0,90])
  linear_extrude(height=baseLength){
     polygon(points = [[0,0],[0,baseHeight],[baseWidth, baseHeight],[baseWidth+2, 0]]);
  }
}

// Actual grove is basewidth/2 centered, 1.8mm wide 
 module baseHoleExtrusion(){
   rotate([0,0,0])
   linear_extrude(height=100) {
      polygon(points = [[baseWidth/2-.9, -1],
      [baseWidth/2-.9, baseHeight],
      [baseWidth/2+.9, baseHeight],
      [baseWidth/2+.9, -1]]);}}
      

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
     for(i = [0 : 8]) rotate([0,0,i*45])
     translate([0,-10,-1]) cylinder(h=2.1, r=1.5, $fn=100);
   }

}


module spring(){
 translate([-springLong, 0, 0]) cube([springLong * 2, springThick, sideThick]);
 translate([-springCube * sqrt(2)/2,.2 ,0]) rotate([0,0,-45]) cube([springCube, springCube, 7]);
   translate([0, 0, 0]) rotate([0,0,45]) cube([springThick / sqrt(2), springThick/sqrt(2), 6]);
}

function getOffset(i) = (i <= 0) ? 0 : getOffset(i-1) + feederBank[i-1] + additionalWidth;


module profileFeederBlock(){
   offset = 0;
   echo(offset);
   for(i = [0 : len(feederBank)-1]){
      translate([0, getOffset(i), 0]) profileFeederAssembled();
   }
}


module profileFeederBlockHoles(){
   difference(){
      profileFeederBlock();
      for(x = holeX) {
        for (y = holeY) {
           translate([x, y, -1]) cylinder(h=10, r=holeR, $fn=100);
        
        }
   }

}
}



rotate([0,-90,0])  profileFeederBlockHoles();  
