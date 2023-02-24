# lovely little experiments
 is a collection of small projects you can run with [löve](https://love2d.org/)

## ad astra
 simple starfield rendering exploration
 - uv scrolling
 - 2d points mesh scrolling
 - 3d mesh dome rotation

## big squares
 proof of concept for "pixelart" upscaling using huge mesh and MSAA, plaese don't take it seriously

## bit umbra
 an experiment with *sort of* stencil 2d shadows/visibility that draws 64 shadowcasting 2D lights

## blood sample
 port of my old SDF raymarching shadertoy demo

## codenames
 codenames implementation for playing on streams

## deferred
 deferred lighting example, assets provided by @flamendless

## filmgrain
 a simplistic decent looking film grain post-processing effect in five lines of shader code

## glowybits
 blending/postprocessing effect for banded dithered lights

## palette
 palette rendering example

## pong
 simple pong game that features pretty much everything a pong game needs

## ponger
 same pong with interpolation, extrapolation, fixed/relaxed timestep, and adjustable tickrate and framerate
 - space to pause the game and bring up simulation settings
 - there are four gamestates you can color differently
 - use fixed to toggle beetwen fixed/relaxed timestep
 - use slow to toggle slow mode to truly appreciat that 10 tickrate interpolation
 - tickrate defines physics updates per second for a fixed timestep
 - frametime sets a minimum time for a frame to update + render in ms to simulate lower framerates, affects relaxed timestep simulation
 - fluctuation adds random time in ms to each frame rendered to simulate unstable framerate

## R3helper examples
 a set of 3d rendering programs using R3helper functions to simplify 3d transformations in löve
 in ascending complexity
 - ### spinning_cube
   you would not believe what it does!
 - ### textures
   adds textures to a cube
 - ### instancing
   renders lots of cubes fast
 - ### depth peeling
   order independent transparency with 16 layers
 - ### camera
   it's almost like you're there!
 - ### shadows
   renders shadowmap with HW PCF

## shady grass
 instanced grass generated and animated in a shader

## voronoi
 exploration of voronoi diagrams rendering using gpu thech

## voxter
 voxel space algorithm that runs in a shader
