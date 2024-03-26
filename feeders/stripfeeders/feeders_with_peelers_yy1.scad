// Written by Nicholas Weaver
// nweaver@skerry-tech.com

// Creative Commons CC0 (public domain) licensed.
// No warrantee expressed or implide

// A variant on my strip feeder design,
// with a hole rather than a pin, and a 
// peeler bar.

// Critical: Print WITHOUT a skirt.

PeelerBarLength = 10;

// A basic strip-feeder parameter builder for building mixed sized feeders
FeederLength = 100;

// Slot sizes, as an array from left to right
// SlotSizes = [8, 8, 8, 8, 8, 8, 8, 8, 12, 12];
//SlotSizes = [12, 12, 12, 12, 16, 16, 16, 24];

//SlotSizes = [8, 8, 8, 8, 12, 12, 12, 12, 12, 16, 16, 16, 24];
SlotSizes = [8, 8,8,8,8,8,8,8,8,12,12,12,12,12,16,16,16,24];

MagnetTapeThick = 2.2;

// Mouting pitch.  This is done as a full array on the base but only
// the first channel will be guarenteed accessable
MountingPitch = 30;

// Y offset for the first mount
MountingOffset = 0;

// Base thickness
BaseThickness = 3;

// Feeder height, to the base of the STRIP
FeederHeight = 22;

// Separation between feeders, this parameter shouldn't need to change
FeederSeparation = 2.5;

// Slot extra width, for slop, may need to be tuned to your specific printer
SlotWidth = 0.2;

// SlotExtraHeight, again, may need to be tuned to your specific printer
SlotHeight = 0.9;

// Amonut of tape covered on the opposite the sprocket side, should not need to be modified
SlotCoverage = 0.8;

// Pin depth, may need to be tuned
PinDepth = 10;

// Pin Diameter, may need to be tuned
PinDiameter = 1.4;

// Actual width of feeder
function FeederWidth(i = 0) = (i == len(SlotSizes) - 1 ? SlotSizes[i] + FeederSeparation : SlotSizes[i] + FeederSeparation + FeederWidth(i+1));

function FeederWidthSoFar(i) = (i == 0 ? 0 : FeederWidthSoFar(i-1) + FeederSeparation + SlotSizes[i-1]);


module Base() {
    difference(){
    cube([FeederWidth(), FeederLength ,BaseThickness]);
    }
}

// Change feeder height to accomodate magetic tape
NewFeederHeight = FeederHeight - MagnetTapeThick;

module FeederStrip(i){
    translate([FeederWidthSoFar(i),0,0]) {
        difference(){
            cube([FeederSeparation/2+SlotCoverage, FeederLength, NewFeederHeight+1.5]);
            translate([FeederSeparation/2-SlotWidth, -0.1, NewFeederHeight])
            cube([100, 1000, SlotHeight]);
        }
        difference(){
        union(){
            cube([FeederSeparation/2+1.75+1.5/2, FeederLength, NewFeederHeight]);
            translate([FeederSeparation/2+1.75, FeederLength - 1.75, 0]) cylinder(r=PinDiameter/2+.5,h=NewFeederHeight, $fn=100);
        }
        translate([FeederSeparation/2+1.75, FeederLength - 1.75, NewFeederHeight-PinDepth]) cylinder(r=PinDiameter/2,h=NewFeederHeight+PinDepth+10, $fn=100);
        }
        
        translate([FeederSeparation/2+SlotSizes[i]-SlotCoverage, 0, 0]) {
            difference(){
            cube([FeederSeparation/2 + SlotCoverage, FeederLength, NewFeederHeight+1.5]);
            
            translate([-3, -1, NewFeederHeight]) cube([3+SlotCoverage+SlotWidth, FeederLength+2, SlotHeight]);
            }
            
        }
        translate([0,0,NewFeederHeight+SlotHeight]) {  
      rotate([0,90,0]) linear_extrude(height=FeederWidth(i)){
         polygon(points=[[0,0],[0,PeelerBarLength],[-1,0]]);
      }
      // cube([FeederWidth(i),PeelerBarLength,1]);
    }
    }

}

module UnitComponent(){
    Base();
    for(i = [0 : len(SlotSizes)-1]){
        FeederStrip(i);
    }
}

module Unit(){
    difference(){
       UnitComponent();
  }
}

rotate([90,0,0]) Unit();