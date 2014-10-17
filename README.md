OpenSCAD MCAD Library [![](http://stillmaintained.com/elmom/MCAD.png)](http://stillmaintained.com/elmom/MCAD)
=====================


Disclaimer:
I forked hyperair's good work, because I was unhappy with the fastener/threads.scad code.
I fixed some bugs and made the threads more accurate. The old code had the issue that it
used fixed angles for the thread's cut through 2D plane which created inaccurate
nuts(internal = true). If you printed them, you may have to use a file to let them fit.
Anyway, I liked the code very much and just made it more exact.
Later I added backlash as a parameter for the threads.
Maybe hyperair will include it in his work. Maybe not. My confidence is too big 
to be unhappy if he didn't.  ;-))




This library contains components commonly used in designing and moching up
mechanical designs. It is currently unfinished and you can expect some API
changes, however many things are already working.

This library was created by various authors as named in the individual
files' comments. All the files except those ThingDoc are licensed under
the LGPL 2.1 (see http://creativecommons.org/licenses/LGPL/2.1/ or the
included file lgpl-2.1.txt), some of them allow distribution under more
permissive terms (as described in the files' comments).

## Usage ##

You can import these files in your scripts with `use <MCAD/filename.scad>`, 
where 'filename' is one of the files listed below like 'motors' or 
'servos'. Some files include useful constants which will be available 
with `include <MCAD/filename.scad>`, which should be safe to use on all 
included files (ie. no top level code should create geometry). (There is 
a bug/feature that prevents including constants from files that 
"include" other files - see the openscad mailing list archives for more 
details. Since the maintainers aren't very responsive, may have to work 
around this somehow)

If you host your project in git, you can do `git submodule add URL PATH` in your
repo to import this library as a git submodule for easy usage. Then you need to do
a `git submodule update --init` after cloning. When you want to update the submodule,
do `cd PATH; git checkout master; git pull`. See `git help submodule` for more info.
"./get_submodules.py" is shortcut that initializes and updates submodules.

Currently Provided Tools:

* regular_shapes.scad
    - regular polygons, ie. 2D
    - regular polyhedrons, ie. 3D

* involute_gears.scad (http://www.thingiverse.com/thing:3575):
    - gear()
    - bevel_gear()
    - bevel_gear_pair()

* gears.scad (Old version):
    - gear(number_of_teeth, circular_pitch OR diametrial_pitch, pressure_angle OPTIONAL, clearance OPTIONAL)

* motors.scad:
    - stepper_motor_mount(nema_standard, slide_distance OPTIONAL, mochup OPTIONAL)

Other tools (alpha and beta quality):

* nuts_and_bolts.scad: for creating metric and imperial bolt/nut holes
* bearing.scad: standard/custom bearings
* screw.scad: screws and augers
* materials.scad: color definitions for different materials
* stepper.scad: NEMA standard stepper outlines
* servos.scad: servo outlines
* boxes.scad: box with rounded corners
* triangles.scad: simple triangles
* 3d_triangle.scad: more advanced triangles

Very generally useful functions and constants:

* math.scad: general math functions
* constants.scad: mathematical constants
* curves.scad: mathematical functions defining curves
* units.scad: easy metric units
* utilities.scad: geometric funtions and misc. useful stuff
* teardrop.scad (http://www.thingiverse.com/thing:3457): parametric teardrop module
* shapes.scad: DEPRECATED simple shapes by Catarina Mota
* polyholes.scad: holes that should come out well when printed

External utils that generate and and process openscad code:

* openscad_testing.py: testing code, see below
* openscad_utils.py: code for scraping function names etc.
* SolidPython: An external Python library for solid cad

## Development ##

You are welcome to fork this project in github and request pulls. I will try to
accomodate the community as much as possible in this. If for some reason you
want collaborator access, just ask.

Github is fun (and easy), but I can include code submissions and other
improvements directly, and have already included code from various sources
(thingiverse is great :)

### Code style ###
I'd prefer to have all included code nicely indented, at least at the block
level, and no extraneous whitespace. I'm used to indent with four spaces as
opposed to tabs or other mixes of whitespace, but at least try to choose a style
and stick to it.

### Testing ###
I've started a minimal testing infrastucture for OpenSCAD code. It's written in
python and uses py.test (might be compatible with Nose also). Just type `py.test`
inside the lib dir in a terminal and you should see a part of the tests passing
and tracebacks for failing tests. It's very simplistic still, but it should test
that no syntax errors occur at least.

The code is included in openscad_testing.py, and can be imported to be
used in other codebases.
