extensions [nw]
breed [trees tree]
breed [orangutans orangutan]
globals [trees-in-row trees-in-col max-rows max-cols tree-counter row-counter col-counter starting-col starting-row isolated-trees]
trees-own [neighbor-nodes crown-diameter height dbh temp-path]
orangutans-own [last-sway body-mass age-sex-class energy-reserve location path-route destination pre-destination temp-path-me]
patches-own [affecting-tree]
links-own [link-type dist]

to setup
  clear-all
  set-simulation-size
  set-patches
  setup-forest
  set-fruiting-trees
  set-orangutans
  reset-ticks
end

to go-2
  ask orangutans
  [
    let new-location one-of [link-neighbors] of location
    move-to new-location
  ]
  tick
end

to go
 ask orangutans
 [
    ifelse path-route = 0
    [print "no connected route to destination!"]
    [
      move
      ifelse length path-route > 0
      [ set path-route remove-item 0 path-route ]
      [
        ifelse [color] of one-of trees-here = yellow
        [walk-on-ground]
        [print "at destination"]
      ]
    ]

  ]
  tick
end

to move
  ifelse length path-route > 0
  [
    let next-tree item 0 path-route
    let linknya nobody
    let d 0
    ask trees-here
    [
      set linknya link-with next-tree
    ]
    move-to next-tree

    if linknya != nobody
    [
      set d [link-length] of linknya
    ]
    set last-sway sway d
  ]
  []
end

to-report sway [x]
  ;pi^2 * d^2 * m
  report pi ^ 2 * x ^ 2 * body-mass
end


to update-view
  ifelse show-crown = true
  [
    ask trees
    [
      ask patches in-radius floor(crown-diameter / 2) [
      if [dbh] of myself > 20
      [set pcolor (green) + [height] of myself mod 10]
      ]
    ]
  ]
  [
    ifelse show-grid = true
    [
      ask patches [set pcolor black]
      ask patches with [(pycor mod 2 = 0 and pxcor mod 2 != 0) or (pxcor mod 2 = 0 and pycor mod 2 != 0)]
      [set pcolor black + 1]
    ]
    [ ask patches [set pcolor black] ]
  ]

end

to set-simulation-size
  if simulation-size = "100 x 100"
  [resize-world 0 99 0 99 set-patch-size 4.25]
  if simulation-size = "75 x 75"
  [resize-world 0 74 0 74 set-patch-size 5.5]
  if simulation-size = "50 x 50"
  [resize-world 0 49 0 49 set-patch-size 8.5]
  if simulation-size = "25 x 25"
  [resize-world 0 24 0 24 set-patch-size 16.5]
end

to set-patches
  ask patches [set pcolor black]
  if show-grid = true
  [ask patches with [(pycor mod 2 = 0 and pxcor mod 2 != 0) or (pxcor mod 2 = 0 and pycor mod 2 != 0)]
    [set pcolor black + 1]]
  ask patches [set affecting-tree turtle-set no-turtles]
end

to setup-forest
  ifelse tree-dist = "regular"
  [regular-setup][random-setup]
  link-trees
end

to set-fruiting-trees
  ask n-of floor(fruiting-tree / 100 * count trees) trees
  [
    set color red
  ]
end

to set-orangutans
  create-orangutans 1
  [
    set shape "person"
    set size 2
    set color orange
    set location one-of trees with [count my-links > 0 and any? orangutans-here = false]
    ifelse location != nobody
    [move-to location]
    [move-to one-of trees]
    ;select destination
    ;1. select the nearest fruiting tree from all other fruiting trees
    let a min [distance myself] of trees with [color = red]
    set destination one-of trees with [color = red and distance myself = a]
    ; show the destination (make the tree look bigger)
    ask destination
    [
      set size 2
    ]

    ;however, the selected destination might not be connected to my place
    ;check whether the selected destination is connected to my place
    ask trees-here
    [
      set temp-path get-path-route [destination] of myself
    ]

    ;what if there is no path?
    if [temp-path] of trees-here = [FALSE]
    [
      ;when there is no path
      print "not connected to fruiting tree...need to walk on ground!"
      ;find a route that can get me as close as possible to the fruiting tree
      ;called by orangutan agent
      set pre-destination get-alternative-route
      ask trees-here
      [
        set temp-path get-path-route [pre-destination] of myself
      ]
    ]

      ;pass the route to orangutans-own variable
      set path-route [temp-path] of trees-here
      ;need to extract the list from list
      set path-route item 0 path-route
  ]
end

to walk-on-ground
  move-to destination
end

to-report get-alternative-route
  print "i need alternative route / destination"
  ;identify the tree that is the nearest to destination tree, but still connected to me
  ;from the destination tree, examine the immediate neighbors (use radius)
  ;how to determine maximum radius? (that is still feasible / desirable for the orangutans to walk through)
  let nearest-connected-tree nobody
  ask destination ;tree agent
  [
    let origin one-of [trees-here] of myself
    print one-of [trees-here] of myself
    ;find a nearest tree from the destination tree which is still connected to my tree
    set nearest-connected-tree one-of other trees with [nw:path-to one-of [trees-here] of one-of orangutans != false] with-min [distance one-of [trees-here] of myself]
    ;what if there is no nearest connected tree (both are isolated)

    ifelse nearest-connected-tree != nobody
    [
      ask nearest-connected-tree
      [
        print nw:path-to one-of [trees-here] of one-of orangutans
        set color yellow
        set size 2
      ]
    ]
    [
      ;I am not connected to any other tree
    ]
  ]
  report nearest-connected-tree
end

to-report get-path-route [desti]
  report nw:turtles-on-path-to desti
end

;to get-path-to-fruit
  ;set temp-path nw:turtles-on-weighted-path-to [destination] of myself dist
;  set temp-path nw:turtles-on-path-to [destination] of myself
;end

to calculate-row-col
  ;calculate plot size
  ; - take number of trees
  ; - define trees-in-row & trees-in-col
  ; - max pxcor = trees-in-row + (reg-dist-between-trees * (trees-in-row - 1)) + 2opsional
  ; - max pycor = trees-in-col + (reg-dist-between-trees * (trees-in-row - 1)) + 2opsional
  let temp-factor-x floor(sqrt(tree-density))
  while [tree-density mod temp-factor-x != 0]
    [set temp-factor-x temp-factor-x - 1]
    set trees-in-row temp-factor-x
    set trees-in-col tree-density / temp-factor-x

  set max-rows trees-in-row + ((reg-dist-between-trees - 1) * (trees-in-row - 1)) ;+ 2
  set max-cols trees-in-col + ((reg-dist-between-trees - 1) * (trees-in-col - 1)) ;+ 2
end

to set-starting-patch
  set starting-col ceiling(max-pxcor / 2) - ceiling(max-cols / 2) + 1
  set starting-row ceiling(max-pycor / 2) - ceiling(max-rows / 2)
end

to regular-setup
  calculate-row-col
  set-starting-patch

  set row-counter starting-row
  set col-counter starting-col
  set tree-counter 0

  while [tree-counter < tree-density]
  [
    while [col-counter < starting-col + max-cols]
    [
      set row-counter starting-row
      while [row-counter < starting-row + max-rows]
      [
        ask patches with [pxcor = col-counter and pycor = row-counter]
        [
          establish-tree
        ]
        set row-counter row-counter + reg-dist-between-trees
      ]
    set col-counter col-counter + reg-dist-between-trees
    ]
    set tree-counter tree-counter + 1
  ]
end

to establish-tree
  sprout-trees 1
  [
    set neighbor-nodes turtle-set no-turtles
    set dbh abs(random-normal avg-dbh 1)
    set height abs(random-normal avg-tree-height 1)

    ifelse dbh <= 20 [set crown-diameter 0 set size 0.5]
    [set crown-diameter abs(random-normal avg-crown-diameter 1) set size 1]

    set color green + 20

    set shape "circle"
    ask patches in-radius floor(crown-diameter / 2) [
      if show-crown = true and [dbh] of myself > 20
      [set pcolor (green) + [height] of myself mod 10]

      ;each patch will record the id of tree which crown shadows the patch, it is saved in a "turtle-set" named "affecting-tree"
      let newset turtle-set myself
      set affecting-tree (turtle-set newset affecting-tree)
    ]
  ]
end

to random-setup
  ask n-of tree-density patches [
    if one-of other trees-here = nobody
    [
      establish-tree
    ]
  ]
end

to link-trees
  ask trees
  [
    ;get the affecting-trees from the patches in-radius of my crown
    set neighbor-nodes (turtle-set neighbor-nodes ([affecting-tree] of patches in-radius floor(crown-diameter / 2)))
    ;set neighbor-nodes (turtle-set neighbor-nodes turtles-on neighbors) <-- what is this for?

    ;NOTE: the patches within 2 meters (which crown dont overlap) are not detected!
    repeat count neighbor-nodes
    [
      let node-connect one-of neighbor-nodes with[not link-neighbor? myself and who != [who] of myself]
      if node-connect != nobody ;and node-connect != myself
      [
        create-link-with node-connect
        [
          ifelse link-length <= 2 [set link-type "sway" set color red]
          [set link-type "brachiation" set color blue]
          set dist link-length
        ]
      ]
    ]
  ]
  ;add-walking-links
end

to add-walking-links
  ;NEXT: add link to all other trees to represent walking path
  ; 1. identify isolated trees (how?) / find a tree which has node-degree = 0
  ; 2. create a "walking-link" to surrounding tree (how much? only one?) - start with only one link
  set isolated-trees (turtle-set trees with [count my-links = 0])
  ask isolated-trees
  [
    ;from the isolated tree, find one other tree which is within radius (gradually increase the radius, if possible? eg. 5, 10, 30, etc)
    let walking-distance-tree one-of other trees in-radius 5
    if walking-distance-tree != nobody
    [
      create-link-with walking-distance-tree
      [
        set color brown
        set thickness 0.5
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
309
10
742
444
-1
-1
8.5
1
10
1
1
1
0
0
0
1
0
49
0
49
1
1
1
ticks
30.0

BUTTON
9
10
93
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
9
62
156
107
tree-dist
tree-dist
"regular" "random"
0

SLIDER
8
181
159
214
reg-dist-between-trees
reg-dist-between-trees
1
5
4.0
1
1
m
HORIZONTAL

MONITOR
748
11
864
56
Avg. Node Degree
mean [count my-links] of trees
2
1
11

SLIDER
6
224
158
257
tree-density
tree-density
0
10000
80.0
20
1
ind / Ha
HORIZONTAL

BUTTON
1167
524
1273
557
NIL
regular-setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1177
432
1258
477
NIL
trees-in-row
17
1
11

MONITOR
1177
487
1252
532
NIL
trees-in-col
17
1
11

MONITOR
1271
487
1333
532
NIL
max-cols
17
1
11

MONITOR
1272
431
1339
476
NIL
max-rows
17
1
11

MONITOR
1178
540
1259
585
NIL
starting-row
17
1
11

MONITOR
1269
541
1344
586
NIL
starting-col
17
1
11

SLIDER
7
271
158
304
avg-tree-height
avg-tree-height
15
50
30.0
5
1
m
HORIZONTAL

SLIDER
171
181
306
214
avg-crown-diameter
avg-crown-diameter
1
10
5.0
1
1
m
HORIZONTAL

SLIDER
171
227
304
260
avg-dbh
avg-dbh
5
50
20.0
1
1
cm
HORIZONTAL

MONITOR
747
63
871
108
NIL
mean [dbh] of trees
2
1
11

MONITOR
747
116
919
161
NIL
mean [crown-diameter] of trees
2
1
11

MONITOR
747
169
885
214
NIL
mean [height] of trees
2
1
11

SWITCH
174
100
289
133
show-crown
show-crown
0
1
-1000

SWITCH
175
63
285
96
show-grid
show-grid
0
1
-1000

SLIDER
170
271
306
304
fruiting-tree
fruiting-tree
0
100
5.0
5
1
%
HORIZONTAL

MONITOR
977
10
1047
55
sway-links
count links with [link-type = \"sway\"]
17
1
11

MONITOR
976
61
1078
106
brachiation-links
count links with [link-type = \"brachiation\"]
17
1
11

CHOOSER
9
113
155
158
simulation-size
simulation-size
"100 x 100" "75 x 75" "50 x 50" "25 x 25"
2

BUTTON
112
11
175
44
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
174
137
275
170
NIL
update-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
749
221
954
266
NIL
[destination] of one-of orangutans
17
1
11

MONITOR
750
276
954
321
NIL
[path-route] of one-of orangutans
17
1
11

MONITOR
750
335
1038
380
NIL
[temp-path] of [trees-here] of one-of orangutans
17
1
11

@#$#@#$#@
# OUmove: OrangUtan Movement Agent-based Model

## Purpose and Patterns

The purpose of this model is to simulate the effect of forest structure variation on orangutan energy cost for locomotion

## EXTENDING THE MODEL

Animate the turtles as they move from node to node.

## RELATED MODELS

* Lattice-Walking Turtles Example
* Grid-Walking Turtles Example

<!-- 2007 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
random-seed 2
setup
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
