# lovely little experiments
 is a collection of small projects you can run with [löve](https://love2d.org/)

### angular ship
 shows how to use fixed timestep and complex numbers to get rid of trigonometric functions at runtime --currently broken :(

### codenames
 codenames implementation for playing on streams

### glowybits
 blending/postprocessing effect for banded dithered lights

### palette
 palette rendering example

### pong
 simple pong game that features pretty much everything a pong game needs

### ponger
 same pong with interpolation, extrapolation, fixed/relaxed timestep, and adjustable tickrate and framerate
 - space to pause the game and bring up simulation settings
 - there are four gamestates you can color differently
 - use fixed to toggle beetwen fixed/relaxed timestep
 - tickrate defines physics updates per second for a fixed timestep
 - frametime sets a minimum time for a frame to update + render in ms to simulate lower framerates, affects relaxed timestep simulation
 - fluctuation adds random time in ms to each frame rendered to simulate unstable framerate

### shady grass
 instanced grass generated and animated in a shader

### voxter
 voxel space algorithm that runs in a shader
