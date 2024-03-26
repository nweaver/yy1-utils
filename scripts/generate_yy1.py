#!/usr/bin/env python3
import sys
import csv
import string
import math

def load_inventory(inventory):
    res = {}
    with open(inventory, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for line in reader:
            if line["Nozzle Size"] == "S":
                line["Nozzle"] = 1
            elif line["Nozzle Size"] == "M":
                line["Nozzle"] = 2
            elif line["Nozzle Size"] == "L":
                line["Nozzle"] = 3
            elif line["Nozzle Size"] == "T":
                line["Nozzle"] = 0
            elif line['Part'] != "":
                print("Unknown nozzle %s" % line)
                line["Nozzle"] = 1
            if line['Part'] != "":
                res[line['Part']] = line
            if line['Substitutes'] != "":
                res[line['Substitutes']] = line
    return res

# Returns top, bottom
def load_placement(placement):
    top = []
    bottom = []
    with open(placement, newline='', encoding='ISO-8859-1') as csvfile:
        reader = csv.DictReader(csvfile)
        for line in reader:
            for key in line:
                line[key] = ''.join(filter(lambda x: x in string.printable, line[key]))
            line["Center-X(mm)"] = float(line["Center-X(mm)"])
            line["Center-Y(mm)"] = float(line["Center-Y(mm)"])
            if line["Layer"] == "TopLayer":
                top.append(line)
            else:
                bottom.append(line)
    return (top, bottom)

# Rotation is a Y axis flip as well...  So basically X is flipped both
# for location AND for angle, thus the cos/sin, -1, atan2(y,x) to
# reverse, and then add 360 if negative to make things consistent
# 0-360 rather than -180 to 180
def fix_bottom(placement, length):
    for line in placement:
        line["Center-X(mm)"] = length-line["Center-X(mm)"]
        radian = math.radians(int(line["Rotation"]))
        x = math.cos(radian)
        y = math.sin(radian)
        x = x * -1
        degrees = math.degrees(math.atan2(y, x))
        if degrees < 0:
            degrees = degrees + 180
        line["Rotation"] = "%2.0f" % degrees
        
                              

def output_placement(placement, filename, inventory, speed):
    header = """NEODEN,YY1,P&P FILE,,,,,,,,,,,
,,,,,,,,,,,,,
PanelizedPCB,UnitLength,0,UnitWidth,0,Rows,1,Columns,1,
,,,,,,,,,,,,,
Fiducial,1-X,{:.2f},1-Y,{:.2f},OverallOffsetX,0,OverallOffsetY,0,
,,,,,,,,,,,,,
NozzleChange,ON,BeforeComponent,{},Head2,Drop,Station3,PickUp,Station1,
NozzleChange,ON,BeforeComponent,{},Head2,Drop,Station1,PickUp,Station2,
NozzleChange,ON,BeforeComponent,{},Head2,Drop,Station2,PickUp,Station3,
NozzleChange,OFF,BeforeComponent,1,Head2,Drop,Station1,PickUp,Station1,
,,,,,,,,,,,,,
Designator,Comment,Footprint,Mid X(mm),Mid Y(mm) ,Rotation,Head ,FeederNo,Mount Speed(%),Pick Height(mm),Place Height(mm),Mode,Skip
"""
    body = """{},{},{},{:.2f},{:.2f},{},{},{},{},{},{},{},{}
"""
    
    change1 = 1
    change2 = 0
    change3 = 0
    placementlist = []
    fiducial = None
    for line in placement:
        name = line["Comment"]
        if name in inventory:
            line["Feeder"] = inventory[name]
            placementlist.append(line)
        elif name == "FID1X2R":
            if fiducial == None:
                fiducial = line
            elif fiducial['Center-Y(mm)'] < line['Center-Y(mm)']:
                fiducial = line
            elif fiducial['Center-Y(mm)'] == line['Center-Y(mm)']:
                if fiducial['Center-X(mm)'] < line['Center-X(mm)']:
                    fiducial = line
        else:
            print(name)
    placementlist = sorted(placementlist, key=lambda x: x["Designator"])
    placementlist = sorted(placementlist, key=lambda x: x["Comment"])
    placementlist = sorted(placementlist, key=lambda x: x["Feeder"]["Nozzle"])

    for i in range(len(placementlist)):
        if change2 == 0 and placementlist[i]["Feeder"]["Nozzle"] > 1:
            change2 = i+1
        if change3 == 0 and placementlist[i]["Feeder"]["Nozzle"] > 2:
            change3 = i+1

    f = open(filename, "w", newline="\r\n")
    f.write(header.format(fiducial["Center-X(mm)"],
                        fiducial["Center-Y(mm)"],
                        change1,
                        change2,
                        change3))
    # print(fiducial)
    
    for line in placementlist:
        designator = line["Designator"]
        comment = line["Comment"]
        footprint = line["Feeder"]["Package"]
        x = line["Center-X(mm)"]
        y = line["Center-Y(mm)"]
        rotation = line["Rotation"]
        head = 2
        # Use both heads for 0402, using the S/T pair
        if line["Feeder"]["Nozzle"] == 1:
            head = 0
        feeder = line["Feeder"]["Feeder"]
        # speed = 100
        pickh = line["Feeder"]["PickHeight"]
        placeh = line["Feeder"]["PlaceHeight"]
        mode = line["Feeder"]["Mode"]
        skip = 0
        if line["Feeder"]["Ignore"] == "Y":
            skip = 1
        f.write(body.format(designator,
                          comment,
                          footprint,
                          x,
                          y,
                          rotation,
                          head,
                          feeder,
                          speed,
                          pickh,
                          placeh,
                          mode,
                          skip))
        pass
      #  print(line)
    f.close()
    return

if __name__ == '__main__':
    width = -1
    inventory = None
    placement = None
    name = None
    speed = 100
    boardfile = sys.argv[1]
    data = open(boardfile, 'r').readlines()
    for line in data:
        line = line.strip().split()
        if line[0] == 'Width:':
            width = float(line[1])
        elif line[0] == 'Inventory:':
            inventory = load_inventory(line[1])
        elif line[0] == 'Placement:':
            placement = load_placement(line[1])
        elif line[0] == 'Name:':
            name = line[1]
        elif line[0] == 'Speed:':
            speed = line[1]
    fix_bottom(placement[1], width)
    output_placement(placement[0], name + "top.csv", inventory, speed)
    output_placement(placement[1], name + "bot.csv", inventory, speed)
