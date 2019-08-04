/*
 * Copyright (c) 2019, Vigibot
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * 
 * Description: OpenSCAD design for servo and servo fixation holes
 * Author:      Quillès Jonathan/Gilles Bouissac
 */

PRECISION = 100;

$fn = PRECISION;

SERVO_BOX_X = 23;
SERVO_BOX_Z = 12.5;

SERVO_STAND_THICKNESS = 2.8;
SERVO_STAND_LENGTH = 33;
SERVO_STAND_OFFSET = 17.4; // From servo right (x>0) border

SERVO_HEAD_WIDTH = 14.75;
SERVO_HEAD_HEIGHT = 5;

WIRE_PASS_X = 8;
WIRE_PASS_Y = 3;

HORN_D=7.10;   // Horn placeholder large axis diameter
HORN_d=4.2;    // Horn placeholder small axis diameter
HORN_L=14.00;  // Inter axis distance
HORN_T=2+0.01;      // Horn placeholder thickness
HORN_AXIS_T=3; // Horn axis thickness
HORN_AXIS_D=HORN_D; // Horn axis diameter

// Distance between fixation screws
SERVO_INTER_SCREW = 28;

// Distance from center to axis
SERVO_AXIS_Y = 5.4;

M2_DS = 1.8;  // Screwing diameter
M2_DP = 2.2;  // Passing diameter
M2_DH = 4.0;  // Head diameter

// Dimension accessors
function servoBoxSizeX()   = SERVO_BOX_X;
function servoBoxSizeY()   = SERVO_BOX_X;
function servoBoxSizeZ()   = SERVO_BOX_Z;
function servoSizeX()      = SERVO_BOX_X+SERVO_HEAD_HEIGHT;
function servoSizeY()      = SERVO_STAND_LENGTH;
function servoSizeZ()      = SERVO_BOX_Z;
function servoStandSizeX() = SERVO_STAND_THICKNESS;
function servoStandSizeY() = SERVO_STAND_LENGTH;
function servoStandSizeZ() = SERVO_BOX_Z;
function servoStandPosX()  = SERVO_STAND_OFFSET;
function servoAxisPosX()   = 0;
function servoAxisPosY()   = SERVO_AXIS_Y;
function servoScrewPosX()  = -SERVO_STAND_OFFSET+SERVO_STAND_THICKNESS/2;
function servoScrewPosY()  = SERVO_INTER_SCREW/2;

// drill a M2 screw:
//   ls: Screwing hole length (from z=0 to z+)
//   lp: Passing hole length (from z=0 to z-)
//   lh: Head length (from z=-lp to z-)
module screwM2 ( ls=10, lp=5, lh=2 ) {
    translate( [0,0,ls/2] )
        cylinder (r = M2_DS/2, h = ls+0.1, center = true);
    translate( [0,0,-lp/2] )
        cylinder (r = M2_DP/2, h = lp+0.1, center = true);
    translate( [0,0,-lp-lh/2] )
        cylinder (r = M2_DH/2, h = lh, center = true);
}

module servoHornHole( r=0 ) {
    translate( [-SERVO_BOX_X/2-SERVO_HEAD_HEIGHT-HORN_T/2-HORN_AXIS_T,-servoAxisPosY(),0] )
    rotate([r,0,0])
    rotate([0,90,0])
    union() {
        translate([0,0,(HORN_AXIS_T+SERVO_HEAD_HEIGHT)/2])
            cylinder(r=HORN_AXIS_D/2,h=HORN_T+HORN_AXIS_T+SERVO_HEAD_HEIGHT,center=true);
        hull() {
            translate([0,HORN_L,0])
                cylinder(r=HORN_d/2,h=HORN_T,center=true);
            cylinder(r=HORN_D/2,h=HORN_T,center=true);
        }
    }
}

module servo ( hornRotation=0, hornNbArm=1 ) {

    translate( [-SERVO_BOX_X/2,0,0] ) {
        // Servo Box
        cube([SERVO_BOX_X, SERVO_BOX_X, SERVO_BOX_Z], center = true);

        // Servo Stand
        translate ([SERVO_BOX_X/2-SERVO_STAND_OFFSET, 0, 0])
            cube([SERVO_STAND_THICKNESS, SERVO_STAND_LENGTH, SERVO_BOX_Z], center = true);

        // Servo Head 
        translate ([
            -(SERVO_BOX_X+SERVO_HEAD_HEIGHT)/2,
            (SERVO_HEAD_WIDTH-SERVO_BOX_X)/2,
            0])
            cube([SERVO_HEAD_HEIGHT, SERVO_HEAD_WIDTH, SERVO_BOX_Z], center = true);

        // Space for wires
        translate ([
            (SERVO_BOX_X-WIRE_PASS_X)/2,
            -(SERVO_BOX_X+WIRE_PASS_Y)/2,
            0])
            cube([WIRE_PASS_X, WIRE_PASS_Y, SERVO_BOX_Z], center = true);

        // Required Horn
        for ( i=[0:360/(hornNbArm):360] )
            servoHornHole(hornRotation + i);

    }
}

// Stand holes
//   h: Can't be changed
//   H: Passing hole length after screwing hole
DEFAULT_PASSING_L = 0.1+SERVO_HEAD_HEIGHT+SERVO_BOX_X + servoScrewPosX();
module servoScrewHoles ( H=DEFAULT_PASSING_L ) {
    offset_x = servoScrewPosX();
    offset_y = servoScrewPosY();
    translate ([offset_x, +offset_y, 0])
        rotate ([0, 90, 0])
        screwM2 (6,H);
    translate ([offset_x, -offset_y, 0])
        rotate ([0, 90, 0])
        screwM2 (6,H);
}

// Counter axis hole
//   ls: Screwing hole length stuck to the servo
//   lp: Passing hole length after screwing hole
//   lh: Head length
module servoCounterAxisHole ( ls=20, lp=0, lh=2 ) {
    offset_x = ls;
    offset_y = SERVO_AXIS_Y;
    translate ([offset_x, -offset_y, 0])
        rotate([0, -90, 0])
        screwM2 (ls,lp,lh);
}

difference () {
    color( "gold", 0.2 )
        servo( 10, 3 );

    servoScrewHoles();
    servoCounterAxisHole(5,5);
}

% servoScrewHoles();
% servoCounterAxisHole(5,5);