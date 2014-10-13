// MIT license

include <constants.scad>

function deg(angle) = 360*angle/const_tau;

// transformations.scad
// License: GNU LGPL 2.1 or later.
// © 2010 by Elmo Mäntynen
// Version 1.0   2010   Elmo Mäntynen
// Version 1.1   2014-10-11   indazoo
//                            Accurate trigonometric functions.
//                            Until OpenScad 2014.01 angles like 30/45/60/90
//                            delivered inaccurate or non-zero values.
//                            sin() and cos() were fixed in 2010.QX but tan() not. 
//                            2010.QX is not released yet.
module local_scale(v, reference=[0, 0, 0]) {
    translate(-reference) scale(v) translate(reference) children(0);
}


function accurateCos(x) = 
(x%30)!=0?cos(x): (x<360?simpleCos(x):simpleCos(x-floor(x/360)*360));
function simpleCos(x) =
x==0 ? 1 :
x==60 ? 0.5 :
x==90 ? 0 :
x==120 ? -0.5 :
x==180 ? -1 :
x==240 ? -0.5 :
x==270 ? 0 :
x==300 ? 0.5 :
x==360 ? 1 : cos(x);
// TEST
/*
echo("cos");
for (angle = [0:1:361]) 
{
	if((cos(angle)-accurateCos(angle)) != 0)	
		echo(angle," ", cos(angle)-accurateCos(angle));
}
*/
function accurateSin(x) = 
(x%15)!=0?sin(x): (x<360?simpleSin(x):simpleSin(x-floor(x/360)*360));
function simpleSin(x) =
x==0 ? 0 :
x==30 ? 0.5 :
x==90 ? 1 :
x==150 ? 0.5 :
x==180 ? 0 :
x==210 ? -0.5 :
x==270 ? -1 :
x==330 ? -0.5 :
x==360 ? 0 : sin(x);
//TEST
/*
echo("sin");
for (angle = [0:1:361]) 
{
	if((sin(angle)-accurateSin(angle)) != 0)	
		echo(angle," ", sin(angle)-accurateSin(angle));
}
*/

function accurateTan(x) = 
(x%15)!=0?tan(x): (x<360?simpleTan(x):simpleTan(x-floor(x/360)*360));
function simpleTan(x) =
x==0 ? 0 :
x==30 ? 1/sqrt(3):
x==45 ? 1 :
x==60 ? sqrt(3):
x==120 ? -sqrt(3):
x==135 ? -1 :
x==150 ? -1/sqrt(3):
x==180 ? 0 :
x==210 ? 1/sqrt(3):
x==225 ? 1 :
x==240 ? sqrt(3):
x==300 ? -sqrt(3):
x==315 ? -1 :
x==330 ? -1/sqrt(3):
x==360 ? 0 : tan(x);
// TEST
/*
echo("tan");
for (angle = [0:1:721]) 
{
   if((tan(angle)-accurateTan(angle)) != 0)
   echo(angle, tan(angle)-accurateTan(angle));
}
*/