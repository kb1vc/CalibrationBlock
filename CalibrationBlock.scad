/*
  CalibrationBlock.scad
 
  Author: radiogeek381@gmail.com

  A test object to allow measurement of "deviation" from actual
  dimensions from a 3D printer.  Tests include circular and square
  holes and pegs ranging in size from 0.1 in to 0.5 in.
*/ 
/*
Copyright (c) 2016, Matthew H. Reilly (kb1vc)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


// All dimensions are in inches -- scaling to mm is at the end.

// list the hole sizes of interest.  Note that we need
// a string representation as well, since OpenSCAD string conversion
// from float is a little iffy...
Sizes = [ [0.1, "0.1"], [0.125, "0.125"], [0.25, "0.25"], [0.375, "0.375"], [0.5, "0.5"] ];

// render round things kinda round
$fn = 32;

// These shouldn't require much.
First_X = 0.1;
Hole_Y = 0.3;
Peg_Y = 2.0;
Label_Y = 1.5;
Step_Y = 0.5; 
Space_X = 0.1;

Gusset_S = 1.5;

Text_Height = 0.05;

function sumSizes(idx) = ( idx == 0 ? Sizes[idx][0] : Sizes[idx][0] + sumSizes(idx-1) );

function xOffset(idx) = ( First_X + idx * Space_X + sumSizes(idx) );

// Parameters
Base_Z = 0.10; // thickness of base   
Base_Y = Peg_Y + 1.1;               // width of base
Base_X = First_X * 2 + xOffset(len(Sizes)-1) + 
         Sizes[len(Sizes)-1][0] * 0.5;  // length of base
  

module show_text(string, loc) {
    translate([loc[0], loc[1], loc[2] - Text_Height]) {
        rotate([0,0,90]) {      
            linear_extrude(height=(2 * Text_Height)) {
                scale([0.015, 0.018, 0.15]) {
                    text(text = string, 
                    halign="center", valign="center", 
                    font="DejaVu LGC Sans:style=Bold");
                }
            }
        }
    }
}

module RoundObj(size, x_offset, y_offset, z_offset) {
    translate([x_offset, y_offset, z_offset]) {
        cylinder(h = 2 * Base_Z, d=size);
    }
}

module SquareObj(size, x_offset, y_offset, z_offset) {
    translate([x_offset - size * 0.5, y_offset, z_offset]) {
       cube([size, size, 2*Base_Z]);
    }
}



module make_shapes(y_offset, z_offset) {
    for(i = [0:1:len(Sizes)-1]) {
        size = Sizes[i][0]; 
        x_offset = xOffset(i);
        RoundObj(size, x_offset, y_offset, z_offset);
        SquareObj(size, x_offset, y_offset + Step_Y, z_offset);
    }
}

module holes() {
    make_shapes(Hole_Y, -Base_Z * 0.5);
}

module pegs() {
    make_shapes(Peg_Y, 0);
}

module labels() {
    for(i = [0:1:len(Sizes)-1]) {
        x_offset = xOffset(i);
        show_text(Sizes[i][1], [x_offset, Label_Y, Base_Z]);
    }
}

module CalibrationSlab(orientation) {
    labels();
    show_text(orientation, [First_X * 2, Hole_Y + Step_Y * 0.5, Base_Z]);
    difference() {
        union() { 
            cube([Base_X, Base_Y, Base_Z]);
            pegs();
            labels();
        }
        holes(); 
    }
}

module Gusset(xloc) {
    translate([xloc, -Base_Z, 0]) {
        rotate([0, -90, 0])
        linear_extrude(height = Base_Z) {
            polygon(points=[ [0, 0], 
            [Gusset_S, 0], [0, Gusset_S], 
            [0, 0] ]);
        }
    }
}

module CalibrationBlock() {
    CalibrationSlab("H"); 

    translate([Base_X, 0, Base_Y]) {
        rotate([-90, 0, 180]) {
            CalibrationSlab("V");
        }
    }
}

scale([25.4,25.4,25.4]) {
    CalibrationBlock();
    Gusset(Base_Z);
    Gusset(Base_X);
}