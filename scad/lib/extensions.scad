/*
 * Copyright (c) 2019, Vigibot
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * 
 * Description: OpenSCAD extensions to scad language
 * Design:      Gilles Bouissac
 * Author:      Gilles Bouissac
 */


// Render children modules with mirroring on X
//   Each child is rendered twice
module mirrorX( mirrorx=true ) {
    mirror([0, 0, 0])
        children();
    if ( mirrorx )
        mirror([0, 1, 0])
            children();
}

// Render children modules with mirroring on Y
//   Each child is rendered twice
module mirrorY( mirrory=true ) {
    mirror([0, 0, 0])
        children();
    if ( mirrory )
        mirror([1, 0, 0])
            children();
}

// Render children modules with mirroring on X and Y
//   Each child is rendered twice
module mirrorXY( mirrorx=true, mirrory=true ) {
    mirrorY(mirrory)
        mirrorX(mirrorx)
            children();
}

// flatten([[0,1],[2,3]]) => [0,1,2,3]
function flatten(list) = [ for (i = list, v = i) v ];
