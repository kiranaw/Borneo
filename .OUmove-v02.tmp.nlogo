extensions [nw]
breed [trees tree]
breed [orangutans orangutan]
globals [cumulative-energy-gain trees-in-row trees-in-col max-rows max-cols tree-counter row-counter col-counter starting-col starting-row isolated-trees number-of-trees]
trees-own [targeted? neighbor-nodes crown-diameter height dbh temp-path visiting-orangutans]
orangutans-own [cumulative-travel-length travel-length move-duration time-budget count-walk count-descent count-climb count-brachiation count-sway total-expended-energy energy-reserve last-sway body-mass age-sex-class energy-reserve location path-route destination pre-destination temp-path-me arm-length upcoming-link move-cost arm-length next-tree cumulative-movement-cost visited-fruiting-tree last-visited-fruiting-tree]
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

to go-check-hunger

end

to go
 if ticks >= 72
 [stop]
 orangutan-move
  ifelse discrete-timesteps = FALSE
  [
    if [time-budget] of one-of orangutans <= 0
    [
      ask orangutans [set time-budget 120]
      tick
    ]
  ]
  [
    tick
  ]
end

to orangutan-move-old
 ask orangutans
 [
    pen-down
    ;check if an arboreal route to destination exists
    ifelse path-route = [] ;or length path-route = 0;if orangutan reached destination or there is no arboreal link
    [
      ;if this is a fruiting tree
      if [color] of one-of trees-here = red ;and one-of trees-here != last-visited-fruiting-tree
      [
        set time-budget 0
        leave-visiting-stamp
        gain-energy
        print "at destination"
        select-destination ;dibalik select destinationnya di atas sebelum ganti ini last-visited-fruiting-tree
        find-route

        set last-visited-fruiting-tree destination ; <- ini harus dicek dulu sebelum ganti isinya, supaya orangutannya nggak bolak balik
        set visited-fruiting-tree lput destination visited-fruiting-tree
      ]
      ;if this is a transit tree (nearest connected neighbor to fruiting tree)
      if [color] of one-of trees-here = yellow
      [
        print "no arboreal route to destination! proceed with terrestrial move.."
        set upcoming-link nobody
        move-terrestrial
      ]
      if [color] of one-of trees-here = green + 20
      [
        ;set destination one-of other trees with [color != red]
        select-destination
        find-route
       ; random-move
      ]
    ]
    ;if orangutan have not reached destination or there is no arboreal link
    [
      move-arboreal
      set path-route remove-item 0 path-route
    ]
    set cumulative-travel-length cumulative-travel-length + travel-length
  ]
end

to orangutan-move
 ask orangutans
 [
    pen-down
    ;check if an arboreal route to destination exists
    ifelse path-route = [] ;or length path-route = 0;if orangutan reached destination or there is no arboreal link
    [
      ;if this is a fruiting tree
      if [color] of one-of trees-here = red ;and one-of trees-here != last-visited-fruiting-tree
      [
        set time-budget 0
        leave-visiting-stamp
        gain-energy
        print "at destination"
        select-destination ;dibalik select destinationnya di atas sebelum ganti ini last-visited-fruiting-tree
        find-route

        set last-visited-fruiting-tree destination ; <- ini harus dicek dulu sebelum ganti isinya, supaya orangutannya nggak bolak balik
        set visited-fruiting-tree lput destination visited-fruiting-tree
      ]
      ;if this is a transit tree (nearest connected neighbor to fruiting tree)
      if [color] of one-of trees-here = yellow
      [
        print "no arboreal route to destination! proceed with terrestrial move.."
        set upcoming-link nobody
        move-terrestrial
      ]
      ;if this is a non fruiting tree destination
      if [color] of one-of trees-here = green + 20
      [
        ;set destination one-of other trees with [color != red]
        select-destination
        find-route
       ; random-move
      ]
    ]
    ;if orangutan have not reached destination or there is no arboreal link
    [
      move-arboreal
      set path-route remove-item 0 path-route
    ]
    set cumulative-travel-length cumulative-travel-length + travel-length
  ]
end

;assume an orangutan gain 300 kCal per fruiting tree
to gain-energy
  set energy-reserve energy-reserve + energy-gain
  set cumulative-energy-gain cumulative-energy-gain + energy-gain
end

to leave-visiting-stamp
  ask trees-here
  [
    set visiting-orangutans (turtle-set myself visiting-orangutans)
  ]
end

to move-arboreal
    ;if length path-route > 0
    set next-tree item 0 path-route
    let linknya nobody
    let d 0
    ask trees-here
    [
       set linknya link-with [next-tree] of myself
    ]

    set upcoming-link item 0 [linknya] of trees-here


    ;here, calculate the energy cost to reach the next tree
    calculate-arboreal-cost

    move-to next-tree

    if linknya != nobody
    [
      set d [link-length] of linknya
      set travel-length d
    ]
    set last-sway sway d
end

;important: do not forget to add the calculation to the cumulative energy cost
to calculate-climb-cost [move-category]
  if move-category = "arboreal"
  [
    ifelse [dbh] of next-tree < 20 and [dbh] of one-of trees-here < 20 ; if both trees are small (swaying trees), then no need for climbing
    [ print "=> no climb" ]
    [
      ifelse [height] of next-tree > [height] of one-of trees-here
      [
        let height-dif [height] of next-tree - [height] of one-of trees-here
        set move-cost climb abs(height-dif)
        set move-duration climb-time abs(height-dif)
        set time-budget precision (time-budget - move-duration) 2
        output-print (word "=> descent, energy cost: " move-cost " kCal")
        set count-descent count-descent + 1
      ]
      [
        let height-dif [height] of next-tree - [height] of one-of trees-here
        set move-cost climb abs(height-dif)
        set move-duration climb-time abs(height-dif)
        set time-budget precision (time-budget - move-duration) 2
        output-print (word "=> climb, energy cost: " move-cost " kCal")
        set count-climb count-climb + 1
      ]
    ]
  ]
  ;remember: terrestrial movement costs 2x climbing bouts (descent and climb)
    ;take the height of my tree, then plug into energy formula
    ;then, take the height of the destination tree, plug into the energy formula
    ;add both calculation (cost for descent and climb)
  if move-category = "descent to ground"
  [
    let descent-cost climb [height] of one-of trees-here
    set move-cost descent-cost
    set move-duration climb-time [height] of one-of trees-here
    set time-budget precision (time-budget - move-duration) 2
    output-print (word "=> descent to ground, energy cost: " move-cost " kCal")
    set count-descent count-descent + 1
  ]
  if move-category = "climb from ground"
  [
    let climb-cost climb [height] of destination
    set move-cost climb-cost
    set move-duration climb-time [height] of one-of trees-here
    set time-budget precision (time-budget - move-duration) 2
    output-print (word "=> climb from ground, energy cost: " move-cost " kCal")
    set count-climb count-climb + 1
  ]
end

to calculate-arboreal-cost
  if upcoming-link != nobody and upcoming-link != 0
  [
    calculate-climb-cost "arboreal"
    set cumulative-movement-cost cumulative-movement-cost + move-cost ;add the descent / climb cost
    set energy-reserve energy-reserve - move-cost

    if [link-type] of upcoming-link = "sway"
    [
      set move-cost sway [link-length] of upcoming-link
      set move-duration sway-time [link-length] of upcoming-link
      output-print (word "locomotor type: " [link-type] of upcoming-link ", energy cost: " move-cost " kCal")
      set count-sway count-sway + 1
      set time-budget precision (time-budget - move-duration) 2
      ;print [link-length] of upcoming-link
    ]
    if [link-type] of upcoming-link = "brachiation"
    [
      set move-cost brachiate [link-length] of upcoming-link
      set move-duration brachiation-time [link-length] of upcoming-link
      output-print (word "locomotor type: " [link-type] of upcoming-link ", energy cost: " move-cost " kCal")
      set count-brachiation count-brachiation + 1
    ]
    set cumulative-movement-cost cumulative-movement-cost + move-cost ;add the sway / brachiate cost
    set energy-reserve energy-reserve - move-cost
  ]
end

;gimana biar bisa urut? jadi orangutan turun dulu (descent), terus jalan (walk-on-ground), habis itu baru naik ke pohon (climb)
to calculate-terrestrial-cost
  calculate-climb-cost "descent to ground" ;calculate descent cost -> move-cost
  set cumulative-movement-cost cumulative-movement-cost + move-cost ; add the descent cost
  set energy-reserve energy-reserve - move-cost

  set move-cost walk distance destination
  output-print (word "locomotor type: walk on ground, energy cost: " move-cost " kCal")
  set cumulative-movement-cost cumulative-movement-cost + move-cost ; add the walking cost
  set energy-reserve energy-reserve - move-cost
  set count-walk count-walk + 1

  calculate-climb-cost "climb from ground" ;calculate climb cost -> move-cost
  set cumulative-movement-cost cumulative-movement-cost + move-cost ; add the climbing cost
  set energy-reserve energy-reserve - move-cost

  set travel-length distance destination
end

to move-terrestrial
  set next-tree destination
  calculate-terrestrial-cost
  move-to next-tree
end

to-report sway-time[d]
  report d * sway-speed
end

to-report sway [d]
  ;pi^2 * d^2 * m
  report precision (ceiling (pi ^ 2 * d ^ 2 * body-mass) * 0.239 / 1000) 3 ;convert to kilocalories
end

to-report brachiation-time[d]
  report d * brachiation-speed
end

to-report brachiate [d]
  ;m.g.L
  ;number of swing -> distance / 2 * arm-length
  ;assume intermediate-distance = 2 * arm-length
  let number-of-swing abs(d / 2 * arm-length)
  let energy-cost body-mass * 9.8 * 2 * arm-length ;* ((cos 45) - 1)
  report precision (ceiling (number-of-swing * energy-cost) * 0.239 / 1000) 3 ;convert to kilocalories
end

to-report walk [d]
  ;m.a.d
  ;report ceiling (body-mass * 1.2 * d)
  ;from Pontzer et al 2010 (from Sockol et al 2007):
  ;energy cost for walking = 0.91 calories * body-mass * distance
  report precision (ceiling (0.91 * body-mass * d) / 1000) 3 ;convert to kilocalories
end

to-report climb-time [d]
  report 1 * d
end

to-report climb [d]
  ;m.g.h
  report precision (ceiling (body-mass * 9.8 * d) * 0.239 / 1000) 3 ;convert to kilocalories
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
  ask n-of floor(fruiting-tree / 100 * count trees) trees with [dbh > 20]
  [
    set color red
  ]
end

to set-orangutans
  repeat 1
  [
  create-orangutans 1
  [
    set shape "person"
    set size 4
    set color red
    set body-mass 50
    set arm-length 1
    set time-budget 120
    set location one-of trees with [count my-links > 0 and any? orangutans-here = false]
    set visited-fruiting-tree []
    set-energy-reserve
    ifelse location != nobody
    [move-to location]
    [move-to one-of trees]
    ;select destination
    select-destination
    find-route
]
  ]
end

to set-energy-reserve
  ;from Knott et al 1999
  ;female in high fruiting period: 5892 kcal
  ;female in low fruiting period: 281 kcal
  set energy-reserve 2000
end

to find-route
  ;move this to go procedure, or first take it out of this procedure
    ;however, the selected destination might not be connected to my place
    ;check whether the selected destination is connected to my place
    ask trees-here
    [
      set temp-path get-path-route [destination] of myself
;      if temp-path = nobody
;      [ set temp-path lput [destination] of myself temp-path ]
    ]

    ;what if there is no path?
    if [temp-path] of trees-here = [FALSE] or [temp-path] of trees-here = nobody or [temp-path] of trees-here = [] or length [temp-path] of trees-here = 0
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
end

;perlu juga nyatet list of destination of orangutans in one timestep
;what happen if there is no fruiting tree that can be visited anymore?
to select-destination
  ;select the nearest fruiting tree from all other fruiting trees
  print "select destination"

  ;select a tree that I havent visited yet
  ;let dest one-of other trees with [color = red and (member? myself ([visiting-orangutans] of self)) = false and self != [one-of trees-here] of myself]

  ;select a tree that havent been visited
  let dest one-of other trees with [color = red and ([visiting-orangutans] of self) = [] and self != [one-of trees-here] of myself]; and targeted? = false]

  ifelse dest != nobody
  [set destination dest]
  [set destination one-of other trees with [color != red]]
  ; show the destination (make the tree look bigger)

  ask trees-here
  [
    set size 1
  ]
  ask destination
  [
    set size 2
    set targeted? true
  ]
end

;select a random destination and go towards it
;what happen after reaching the tree
to random-move

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
        ;set size 2
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

;remember: the tree density parameter should be adjustable so that it gives number of trees / Hectares
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
    set targeted? false
    set neighbor-nodes turtle-set no-turtles
    set dbh abs(random-normal avg-dbh 1)
    set height abs(random-normal avg-tree-height 1)
    set visiting-orangutans []

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

;remember: the tree density parameter should be adjustable so that it gives number of trees / Hectares
to random-setup
  ;check the size of world
  ;if there are 10000 patches, then trees-density =* 1
  ;make it proportional to the number of count patches

  set number-of-trees tree-density * (count patches / 10000)

  ask n-of number-of-trees patches [
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
          ifelse link-length <= 2 [set link-type "sway" set color green set thickness 0.1] ;edit
          [set link-type "brachiation" set color blue set thickness 0.1]
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
313
10
746
444
-1
-1
4.25
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
99
0
99
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
1

SLIDER
9
524
160
557
reg-dist-between-trees
reg-dist-between-trees
1
5
1.0
1
1
m
HORIZONTAL

MONITOR
1860
62
1976
107
Avg. Node Degree
mean [count my-links] of trees
2
1
11

SLIDER
4
175
156
208
tree-density
tree-density
100
3000
600.0
500
1
ind / Ha
HORIZONTAL

BUTTON
1551
562
1657
595
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
1543
441
1624
486
NIL
trees-in-row
17
1
11

MONITOR
1543
496
1618
541
NIL
trees-in-col
17
1
11

MONITOR
1637
496
1699
541
NIL
max-cols
17
1
11

MONITOR
1638
440
1705
485
NIL
max-rows
17
1
11

MONITOR
1562
578
1643
623
NIL
starting-row
17
1
11

MONITOR
1856
631
1931
676
NIL
starting-col
17
1
11

SLIDER
6
218
157
251
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
173
179
308
212
avg-crown-diameter
avg-crown-diameter
1
10
4.0
1
1
m
HORIZONTAL

SLIDER
174
218
307
251
avg-dbh
avg-dbh
5
50
30.0
1
1
cm
HORIZONTAL

MONITOR
1820
115
1944
160
NIL
mean [dbh] of trees
2
1
11

MONITOR
1821
169
1993
214
NIL
mean [crown-diameter] of trees
2
1
11

MONITOR
1821
217
1959
262
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
172
262
308
295
fruiting-tree
fruiting-tree
0
100
5.0
0.1
1
%
HORIZONTAL

MONITOR
1677
62
1747
107
sway-links
count links with [link-type = \"sway\"]
17
1
11

MONITOR
1676
113
1778
158
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
0

BUTTON
112
11
231
44
go
go
T
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
1539
176
1744
221
NIL
[destination] of one-of orangutans
17
1
11

MONITOR
1288
65
1492
110
NIL
[path-route] of one-of orangutans
17
1
11

MONITOR
1289
10
1577
55
NIL
[temp-path] of [trees-here] of one-of orangutans
17
1
11

MONITOR
1674
173
1876
218
NIL
[move-cost] of one-of orangutans
17
1
11

MONITOR
1701
250
1919
295
NIL
[upcoming-link] of one-of orangutans
17
1
11

MONITOR
1542
66
1616
111
cumulative movement cost
[cumulative-movement-cost] of one-of orangutans
2
1
11

MONITOR
1543
120
1615
165
move cost
[move-cost] of one-of orangutans
17
1
11

MONITOR
1538
231
1742
276
visited-fruiting-tree
[visited-fruiting-tree] of one-of orangutans
17
1
11

MONITOR
1538
288
1814
333
NIL
[last-visited-fruiting-tree] of one-of orangutans
17
1
11

OUTPUT
755
10
1171
96
11

PLOT
753
100
953
250
total energy expenditure
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot [cumulative-movement-cost] of one-of orangutans"

PLOT
971
99
1171
249
energy reserve dynamics
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot [energy-reserve] of one-of orangutans"

MONITOR
1161
629
1363
674
energy-reserve (kCal)
[energy-reserve] of one-of orangutans
2
1
11

MONITOR
752
264
956
309
move-cost (kCal)
round [cumulative-movement-cost] of one-of orangutans
2
1
11

MONITOR
1384
298
1441
343
walk
[count-walk] of one-of orangutans
17
1
11

MONITOR
1380
180
1445
225
brachiate
[count-brachiation] of one-of orangutans
17
1
11

MONITOR
1448
180
1505
225
sway
[count-sway] of one-of orangutans
17
1
11

MONITOR
1388
357
1445
402
descent
[count-descent] of one-of orangutans
17
1
11

MONITOR
1383
239
1440
284
climb
[count-climb] of one-of orangutans
17
1
11

MONITOR
191
352
271
397
moving-time
[time-budget] of one-of orangutans
17
1
11

SWITCH
171
310
308
343
discrete-timesteps
discrete-timesteps
1
1
-1000

SLIDER
6
262
162
295
walking-speed
walking-speed
0.5
3
1.0
0.1
1
m/s
HORIZONTAL

SLIDER
6
307
164
340
brachiation-speed
brachiation-speed
0.5
2
0.8
0.1
1
m/s
HORIZONTAL

SLIDER
6
351
165
384
sway-speed
sway-speed
0.5
2
0.5
0.1
1
m/s
HORIZONTAL

BUTTON
238
11
301
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

SLIDER
6
393
165
426
energy-gain
energy-gain
0
1000
350.0
1
1
kCal / tree
HORIZONTAL

MONITOR
979
265
1114
310
energy-reserve (kCal)
round [energy-reserve] of one-of orangutans
2
1
11

PLOT
760
321
960
471
energy-gain
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "show [cumulative-energy-gain] of one-of orangutans" "plot [cumulative-energy-gain] of one-of orangutans"

MONITOR
1286
130
1366
175
energy-gain
[cumulative-energy-gain] of one-of orangutans
2
1
11

MONITOR
982
326
1074
371
day range (m)
[cumulative-travel-length] of one-of orangutans
2
1
11

SLIDER
8
435
187
468
hunger-threshold
hunger-threshold
100
2000
2000.0
1
1
kCal
HORIZONTAL

SLIDER
7
480
179
513
full-threshold
full-threshold
4500
7000
6500.0
1
1
kCal
HORIZONTAL

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
NetLogo 6.2.0
@#$#@#$#@
random-seed 2
setup
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment2" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>[count-walk] of one-of orangutans</metric>
    <metric>[count-brachiation] of one-of orangutans</metric>
    <metric>[count-sway] of one-of orangutans</metric>
    <metric>[count-descent] of one-of orangutans</metric>
    <metric>[count-climb] of one-of orangutans</metric>
    <metric>[cumulative-movement-cost] of one-of orangutans</metric>
    <metric>[cumulative-energy-gain] of one-of orangutans</metric>
    <metric>[energy-reserve] of one-of orangutans</metric>
    <enumeratedValueSet variable="avg-dbh">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="discrete-timesteps">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-crown-diameter">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reg-dist-between-trees">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-grid">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sway-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="walking-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tree-dist">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="simulation-size">
      <value value="&quot;100 x 100&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="brachiation-speed">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fruiting-tree">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-crown">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tree-density">
      <value value="500"/>
      <value value="1000"/>
      <value value="1500"/>
      <value value="2000"/>
      <value value="2500"/>
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-tree-height">
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
