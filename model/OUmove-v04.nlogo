extensions [nw csv]
breed [trees tree]
breed [orangutans orangutan]
globals [cumulative-energy-gain trees-in-row trees-in-col max-rows max-cols tree-counter row-counter col-counter starting-col starting-row isolated-trees number-of-trees]
trees-own [energy-content fruiting-tree? transit-tree? targeted? neighbor-nodes close-neighbors crown-diameter height dbh temp-path visiting-orangutans]
orangutans-own [descent-costs climb-costs walk-cost sway-cost brachiation-cost sway-dist brachiation-dist walk-dist climb-dist descent-dist budget-travel budget-feeding budget-resting freq-brachiate freq-sway freq-climb freq-walk freq-descent basal-metabolic-cost count-move-all current-activity feeding-count resting-count travelling-count energy-acquired? body-mass feed-wait-time move-wait-time time-to-reach-next-tree travel-time-required cumulative-travel-length travel-length move-duration time-budget count-walk count-descent count-climb count-brachiation count-sway total-expended-energy energy-reserve last-sway energy-reserve location path-route destination pre-destination temp-path-me arm-length upcoming-link move-cost arm-length next-tree cumulative-movement-cost visited-fruiting-tree last-visited-fruiting-tree]
patches-own [affecting-tree]
links-own [link-type dist]

to save-network-simple
  csv:to-file "linksou.csv" [(list end1 end2 dist)] of links
  csv:to-file "nodesou.csv" [(list who xcor ycor dbh crown-diameter height)] of trees
end

to setup
  clear-all
  set-simulation-size
  set-patches
  setup-forest
  set-fruiting-trees
  set-orangutans
  reset-ticks
end

to go
  if ticks >= 43200
  [stop]
  ifelse check-hunger = TRUE
  [orangutan-move][rest]
  expend-basal-energy
  record-activity
 tick
  compute-frequencies
end

; compute frequencies of each movement type and activity budget, in percentages
to compute-frequencies
  ask orangutans
  [
    if count-move-all > 0
    [
      set freq-brachiate count-brachiation / count-move-all * 100
      set freq-climb count-climb / count-move-all * 100
      set freq-walk count-walk / count-move-all * 100
      set freq-descent count-descent / count-move-all * 100
      set freq-sway count-sway / count-move-all * 100
    ]

    if ticks > 0
    [
      set budget-travel travelling-count / ticks * 100
      set budget-feeding feeding-count / ticks * 100
      set budget-resting resting-count / ticks * 100
    ]
  ]
end

;add a record to the orangutans activity list
to record-activity
  ask orangutans
  [
    if current-activity = "feeding"
    [set feeding-count feeding-count + 1]
    if current-activity = "resting"
    [set resting-count resting-count + 1]
    if current-activity = "travelling"
    [set travelling-count travelling-count + 1]
  ]
end

to rest
  ask orangutans
  [
    set current-activity "resting"
  ]
end

to-report check-hunger
  ifelse [energy-reserve] of one-of orangutans < 0
  [
    ask orangutans [set color yellow]
    report TRUE
  ]
  [ ask orangutans [set color red]
    report FALSE
  ]
end

to expend-basal-energy
  ;basal energy unit: kcal / BW / hour
  ask orangutans
  [
    let energy-spent 1 / 3600 * (basal-energy * body-mass)
    set energy-reserve energy-reserve - energy-spent
    set basal-metabolic-cost basal-metabolic-cost + energy-spent ;+ cumulative-movement-cost
  ]
end

to clear-transit-flags
  ask trees with [color = yellow]
  [
    set color green + 20
          set transit-tree? FALSE
  ]
end

to orangutan-move
 ask orangutans
 [
    ;pen-down
    ;check if an arboreal route to destination exists, if not:
    ifelse path-route = [] ;if orangutan reached destination or there is no arboreal link
    [
      ;if this is a fruiting tree
      if [color] of one-of trees-here = red ;and one-of trees-here != last-visited-fruiting-tree
      [
        clear-transit-flags ;clear the transit tree markers from previous trip (transit tree: tree from which I had no more arboreal route to my destination)
        leave-visiting-stamp ;add myself to the tree's visitor list
        gain-energy

        ;proceed to this block only if energy acquiring process completed
        if energy-acquired? = TRUE
        [
          select-destination
          find-route
          set last-visited-fruiting-tree destination
          set visited-fruiting-tree lput destination visited-fruiting-tree
        ]
      ]
      ;if this is a transit tree, switch to terrestrial move
      if [color] of one-of trees-here = yellow
      [
        ;print "no arboreal route to destination! proceed with terrestrial move.."
        set upcoming-link nobody
        move-terrestrial
      ]
      ;if this is a non fruiting tree, find a target tree
      if [color] of one-of trees-here = green + 20
      [
        clear-transit-flags
        select-destination
        find-route
      ]
    ]
    ;if i have arboreal route to traverse
    [
      ;remove the first & current tree from list --> make sure it doesn't waste a timestep staying on the same tree
      if [who] of item 0 path-route = [who] of one-of trees-here
      [set path-route remove-item 0 path-route]

      ;if there is no connected tree from here
      ifelse path-route = []
      [
        let dstn destination
        ;is there no connection with the target tree? recheck
        ifelse one-of [link-with dstn] of trees-here != nobody
        [
          move-arboreal
        ]
        [
          move-terrestrial
        ]
      ]
      [
        move-arboreal
      ]
    ]
    set count-move-all count-walk + count-sway + count-descent + count-climb + count-brachiation
  ]
end

;process of food acquiring, this involve timer for the energy intake rate
to gain-energy
  ;based on the energy intake rate, I will stay in this tree for xxx more timesteps to handle my food, before I acquire energy
  set energy-acquired? FALSE
  let time-to-acquire-energy round(energy-gain / energy-intake)
  set feed-wait-time feed-wait-time + 1
  set current-activity "feeding"

  if feed-wait-time = time-to-acquire-energy
  [
    set energy-reserve energy-reserve + item 0 [energy-content] of trees-here
    set cumulative-energy-gain cumulative-energy-gain + item 0 [energy-content] of trees-here
    set energy-acquired? TRUE
    set feed-wait-time 0
  ]
end

;give the tree a record of attendance (which orangutan has visited me?)
to leave-visiting-stamp
  ask trees-here
  [
    set visiting-orangutans (turtle-set myself visiting-orangutans)
  ]
end

to move-arboreal
    set next-tree item 0 path-route
    let linknya nobody
    let d 0
    ask trees-here
    [
       set linknya link-with [next-tree] of myself
    ]

    if linknya != nobody
    [
      set d [link-length] of linknya
      set travel-length d
    ]

    set upcoming-link item 0 [linknya] of trees-here ; <-- this is the link that the orangutan would use to travel, IMPORTANT: UPCOMING LINK



    ;calculate distance and time required to reach the next tree
    if upcoming-link != nobody
    [
      let dist-to-next-tree [link-length] of upcoming-link
      let ltyp [link-type] of upcoming-link
      let mvspeed 0

      ;take the brachiation / sway / walking speed
      if ltyp = "brachiation"
      [set mvspeed brachiation-speed]
      if ltyp = "sway"
      [set mvspeed sway-speed]

      let dist-that-i-can-travel-in-one-second mvspeed
      set time-to-reach-next-tree dist-to-next-tree / mvspeed

      ifelse dist-to-next-tree <= dist-that-i-can-travel-in-one-second
      [
        set current-activity "travelling"
        move-to next-tree
      ]
      ;wait routine
      [
        set current-activity "travelling"
        set move-wait-time move-wait-time + 1
        if move-wait-time >= time-to-reach-next-tree ;compare waiting time (time elapsed) and time required to reach target tree
        [
          ;here, calculate the energy cost to reach the next tree
          calculate-arboreal-cost
          move-to next-tree
          ;when successfully moved to the next tree, then remove the element from list
          set path-route remove-item 0 path-route
          ;sum up the travel length
          set cumulative-travel-length cumulative-travel-length + travel-length
          ;also, reset the counter!
          set move-wait-time 0
        ]
      ]
    ]

end

;important: do not forget to add the calculation to the cumulative energy cost
to calculate-climb-cost [move-category]
  if move-category = "arboreal"
  [
    ifelse [dbh] of next-tree < 20 and [dbh] of one-of trees-here < 20 ; if both trees are small (swaying trees), then no need for climbing
    [] ;print "=> no climb" ]
    [
      ifelse [height] of next-tree > [height] of one-of trees-here
      [
        let height-dif [height] of next-tree - [height] of one-of trees-here
        set move-cost descent abs(height-dif)
        set descent-costs descent-costs + move-cost
        set move-duration climb-time abs(height-dif)
        ;output-print (word "=> descent, energy cost: " move-cost " kCal")
        ;DESCENT not accounted
        set count-descent count-descent + 1
      ]
      [
        let height-dif [height] of next-tree - [height] of one-of trees-here
        set move-cost climb abs(height-dif)
        set climb-costs climb-costs + move-cost
        set move-duration climb-time abs(height-dif)
        ;output-print (word "=> climb, energy cost: " move-cost " kCal")
        ;CLIMB not accounted
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
    let descent-cost descent [height] of one-of trees-here ; added 20.4.2021 assuming descent is 1/3 costly than climbing
    set descent-costs descent-cost
    set move-cost descent-cost
    set move-duration climb-time [height] of one-of trees-here
    ;output-print (word "=> descent to ground, energy cost: " move-cost " kCal")
    set count-descent count-descent + 1
  ]
  if move-category = "climb from ground"
  [
    let climb-cost climb [height] of destination
    set climb-costs climb-cost
    set move-cost climb-cost
    set move-duration climb-time [height] of one-of trees-here
    ;output-print (word "=> climb from ground, energy cost: " move-cost " kCal")
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
      set sway-cost sway-cost + move-cost
      set move-duration sway-time [link-length] of upcoming-link
      ;output-print (word "locomotor type: " [link-type] of upcoming-link ", energy cost: " move-cost " kCal")
      set count-sway count-sway + 1
      ;print [link-length] of upcoming-link
    ]
    if [link-type] of upcoming-link = "brachiation"
    [
      set move-cost brachiate [link-length] of upcoming-link
      set brachiation-cost brachiation-cost + move-cost
      set move-duration brachiation-time [link-length] of upcoming-link
      ;output-print (word "locomotor type: " [link-type] of upcoming-link ", energy cost: " move-cost " kCal")
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
  set walk-cost walk-cost + move-cost
  ;output-print (word "locomotor type: walk on ground, energy cost: " move-cost " kCal")
  set cumulative-movement-cost cumulative-movement-cost + move-cost ; add the walking cost
  set energy-reserve energy-reserve - move-cost
  set count-walk count-walk + 1

  calculate-climb-cost "climb from ground" ;calculate climb cost -> move-cost
  set cumulative-movement-cost cumulative-movement-cost + move-cost ; add the climbing cost
  set energy-reserve energy-reserve - move-cost
end

to move-terrestrial
  set next-tree destination

  ;time required to descent and climb the next tree!
  ;repeat the same procedure ==> DESCENT
  ;1. calculate the distance to be descended
  let dist-to-descent [height] of one-of trees-here
  ;2. how far can I descent in one second
  let dist-i-can-descent-per-second descent-speed
  ;3. calculate time to descent to the ground
  let time-to-descent-to-ground dist-to-descent / descent-speed

  ;sebelum move to next tree, perlu disini adanya penghitungan waktu yang diperlukan untuk mencapai pohon selanjutnya
  ;ulangi prosedur sebelumnya yaitu
  ;1. menghitung jarak antara posisi saya dan pohon selanjutnya
  let dist-to-next-tree distance next-tree
  ;2. how far can I travel in one second?
  let dist-i-can-travel-per-second walking-speed
  ;3. calculate time to reach the next-tree
  let time-to-walk dist-to-next-tree / walking-speed

  ;==> CLIMB
  let dist-to-climb [height] of next-tree
  let dist-i-can-climb-per-second climb-speed
  let time-to-climb-from-ground dist-to-climb / climb-speed

  ;==> CALCULATE THE OVERALL TIME
  set time-to-reach-next-tree time-to-descent-to-ground + time-to-walk + time-to-climb-from-ground
  ; no need because it is almost impossible set dist-that-i-can-travel-in-one-second

  ;NOW THE WAITING TIME
  set travel-length dist-to-next-tree ;get the travel length
  set move-wait-time move-wait-time + 1
  if move-wait-time >= time-to-reach-next-tree ;compare waiting time (time elapsed) and time required to reach target tree
  [
     calculate-terrestrial-cost
     set current-activity "travelling"
     move-to next-tree
     set cumulative-travel-length cumulative-travel-length + travel-length
     ;when successfully moved to the next tree, then remove the element from list
     if path-route != []
     [set path-route remove-item 0 path-route]
     ;also, reset the counter!
     set move-wait-time 0
  ]
  ;move-to next-tree
end

to-report sway-time[d]
  report d / sway-speed
end

to-report sway [d]
  ;pi^2 * d^2 * m
  ;set sway-count sway-count + 1
  set sway-dist sway-dist + d
  report precision (ceiling (pi ^ 2 * d ^ 2 * body-mass) / 0.15 * 0.239 / 1000) 3 ;convert to kilocalories
end

to-report brachiation-time[d]
  report d / brachiation-speed
end

to-report brachiate [d]
  ;cost of brachiation is 1.5 * cost of walking
  ;set brachiation-count brachiation-count + 1
  set brachiation-dist brachiation-dist + d
  let energy-cost 1.5 * (0.91 * body-mass * d) / 1000
  report precision (ceiling (energy-cost)) 3
end

to-report walk-time [d]
  report d / walking-speed
end

to-report walk [d]
  ;from Pontzer et al 2010 (from Sockol et al 2007):
  ;energy cost for walking = 0.91 calories * body-mass * distance
  ;set walk-count walk-count + 1
  set walk-dist walk-dist + d
  report precision (ceiling (0.91 * body-mass * d) / 1000) 3 ;convert to kilocalories
end

to-report climb-time [d]
  report d / climb-speed
end

to-report climb [d]
  ;from Pontzer et al 2010
  ;body-mass * gravity * height / 15% energy efficiency
  ;set climb-count climb-count + 1
  set climb-dist climb-dist + d
  report precision (ceiling ((body-mass * 9.8 * d / 0.20) * 0.239) / 1000) 3 ;convert to kilocalories
end

to-report descent-time [d]
  report d / descent-speed
end

to-report descent [d]
  set descent-dist descent-dist + d
  report precision(ceiling (1 / 3 * (body-mass * 9.8 * d / 0.20) * 0.239) / 1000) 3 ;convert to kilocalories
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
  if simulation-size = "500 x 500"
  [resize-world 0 499 0 499 set-patch-size 1]
end

to set-patches
  ask patches [set pcolor black]
  if show-grid = true
  [ask patches with [(pycor mod 2 = 0 and pxcor mod 2 != 0) or (pxcor mod 2 = 0 and pycor mod 2 != 0)]
    [set pcolor black + 1]]
  ask patches [set affecting-tree turtle-set no-turtles]
end

to setup-forest
  if tree-dist = "regular"
  [regular-setup]
  if tree-dist = "random"
  [random-setup]
  if tree-dist = "from-file"
  [from-csv]
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
    set budget-travel 0
    set budget-feeding 0
    set budget-resting 0
    set freq-brachiate 0
    set freq-sway 0
    set freq-climb 0
    set freq-walk 0
    set freq-descent 0
    set feeding-count 0
    set travelling-count 0
    set resting-count 0
    set move-wait-time 0
    set feed-wait-time 0
    set energy-acquired? FALSE
    set shape "person"
    set size 4
    set color red
    set body-mass body-weight
    set arm-length 1
    set location one-of trees with [count my-links > 0 and any? orangutans-here = false]
    set visited-fruiting-tree []
    set-energy-reserve
    ifelse location != nobody
    [move-to location]
    [move-to one-of trees]
    select-destination
    find-route
]
  ]
end

to set-energy-reserve
  set energy-reserve initial-satiation
end

to find-route
    ask trees-here
    [
      set temp-path nw:turtles-on-path-to [destination] of myself
    ]

    ;when there is no path
    if [temp-path] of trees-here = [FALSE] or [temp-path] of trees-here = nobody or [temp-path] of trees-here = [] or length [temp-path] of trees-here = 0
    [

      ;find a route that can get me as close as possible to the fruiting tree
      set pre-destination get-alternative-route
      ask trees-here
      [
        set temp-path nw:turtles-on-path-to [pre-destination] of myself
      ]
    ]

      ;pass the route to orangutans-own variable
      set path-route [temp-path] of trees-here
      ;need to extract the list from list
  set path-route item 0 path-route
end


to select-destination
  ;select a fruiting tree that havent been visited, which is the nearest from me
  let dest min-one-of other trees with [color = red and ([visiting-orangutans] of self) = [] and self != [one-of trees-here] of myself] [distance myself]; and targeted? = false]

  ifelse dest != nobody
  [set destination dest]
  ;if there is no fruiting tree that can be visited, move to non-fruiting tree (at random)
  [set destination one-of other trees with [color != red and self != [one-of trees-here] of myself]]

  ;show the destination (make the target tree look bigger)
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

to-report get-alternative-route
  ;identify the tree that is the nearest to destination tree, but still connected to me
  ;from the destination tree, examine the immediate neighbors (use radius)
  let nearest-connected-tree nobody
  ask destination ;tree agent
  [
    let origin one-of [trees-here] of myself
    ;print one-of [trees-here] of myself
    ;find a nearest tree from the destination tree which is still connected to my tree
    set nearest-connected-tree one-of other trees with [nw:path-to one-of [trees-here] of one-of orangutans != false] with-min [distance one-of [trees-here] of myself]
    ;what if there is no nearest connected tree (both are isolated)

    ifelse nearest-connected-tree != nobody
    [
      ask nearest-connected-tree
      [
        ;print nw:path-to one-of [trees-here] of one-of orangutans
        set color yellow
        set transit-tree? TRUE
        ;set size 2
      ]
    ]
    [
      ;I am not connected to any other tree
    ]
  ]
  report nearest-connected-tree
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
    set transit-tree? FALSE
    set targeted? false
    set neighbor-nodes turtle-set no-turtles
    set close-neighbors turtle-set no-turtles
    set dbh abs(random-normal avg-dbh 1)
    set height abs(random-normal avg-tree-height 10)
    set visiting-orangutans []
    set energy-content energy-gain

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

;add data from csv file
;data format: TreeID / x / y / dbh / crown / height / fruiting / species
to from-csv
  file-close-all
  file-open "tree_data.csv"
  let headings csv:from-row file-read-line

  while [ not file-at-end? ] [
    let data csv:from-row file-read-line
    create-trees 1 [
      set energy-content energy-gain
      set transit-tree? FALSE
      set targeted? false
      set neighbor-nodes turtle-set no-turtles
      set visiting-orangutans []
      set dbh item 4 data
      set height item 6 data
      set crown-diameter item 5 data
      ifelse item 7 data = 1 [set fruiting-tree? TRUE][set fruiting-tree? FALSE]
      setxy item 2 data item 3 data
      set size 1

      ifelse fruiting-tree? = TRUE
      [set color red][set color green + 20]

      set shape "circle"

      ask patches in-radius ceiling(crown-diameter / 2) [
        if show-crown = true and [dbh] of myself > 20
        [set pcolor (green) - [height] of myself mod 5]

        ;each patch will record the id of tree which crown shadows the patch, it is saved in a "turtle-set" named "affecting-tree"
        let newset turtle-set myself
        ;show newset
        set affecting-tree (turtle-set newset affecting-tree);affecting-tree will always be zero at first because this is not executed sequentially
      ]
    ]
  ]
  file-close-all
end

;the tree density parameter should be adjustable so that it gives number of trees / Hectares
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
   set close-neighbors (trees with [distance myself <= 2])
   if close-neighbors != nobody
   [ ;link with close neighbors
    repeat count close-neighbors
    [
      let node-connect one-of close-neighbors with [not link-neighbor? myself and who != [who] of myself]
      if node-connect != nobody
      [
        create-link-with node-connect
        [set link-type "sway" set color green set thickness 0.1]
      ]
    ]
    ]

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
          if link-length > 2 ;[set link-type "sway" set color green set thickness 0.1] ;edit
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
399
52
832
486
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
868
455
952
488
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
11
85
132
130
tree-dist
tree-dist
"regular" "random" "from-file"
2

SLIDER
202
432
353
465
reg-dist-between-trees
reg-dist-between-trees
1
5
3.0
1
1
m
HORIZONTAL

MONITOR
1209
55
1313
100
Avg. Node Degree
mean [count my-links] of trees
2
1
11

SLIDER
10
184
162
217
tree-density
tree-density
20
10000
520.0
500
1
ind / Ha
HORIZONTAL

SLIDER
9
221
160
254
avg-tree-height
avg-tree-height
15
50
20.0
5
1
m
HORIZONTAL

SLIDER
11
261
159
294
avg-crown-diameter
avg-crown-diameter
0
10
4.0
1
1
m
HORIZONTAL

SLIDER
12
300
159
333
avg-dbh
avg-dbh
5
50
22.0
1
1
cm
HORIZONTAL

SWITCH
10
411
122
444
show-crown
show-crown
0
1
-1000

SWITCH
11
377
121
410
show-grid
show-grid
1
1
-1000

SLIDER
12
340
160
373
fruiting-tree
fruiting-tree
0
100
0.0
0.1
1
%
HORIZONTAL

MONITOR
1209
107
1272
152
sway-links
count links with [link-type = \"sway\"]
17
1
11

MONITOR
1279
108
1369
153
brachiation-links
count links with [link-type = \"brachiation\"]
17
1
11

CHOOSER
10
135
133
180
simulation-size
simulation-size
"100 x 100" "75 x 75" "50 x 50" "25 x 25" "500 x 500"
0

BUTTON
961
455
1080
488
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
10
451
111
484
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
1802
50
2007
95
NIL
[destination] of one-of orangutans
17
1
11

MONITOR
1800
102
2475
147
NIL
[path-route] of one-of orangutans
17
1
11

MONITOR
1800
265
2212
310
visited-fruiting-tree
[visited-fruiting-tree] of one-of orangutans
17
1
11

PLOT
866
55
1029
186
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
"default" 1.0 0 -16777216 true "" "if plot-update = true [plot [cumulative-movement-cost] of one-of orangutans]"

MONITOR
1045
292
1146
337
move-cost (kCal)
round [cumulative-movement-cost] of one-of orangutans
2
1
11

MONITOR
1195
238
1252
283
walk%
[freq-walk] of one-of orangutans
2
1
11

MONITOR
1045
239
1115
284
brachiate %
[freq-brachiate] of one-of orangutans
2
1
11

MONITOR
1124
238
1181
283
sway%
[freq-sway] of one-of orangutans
2
1
11

MONITOR
1259
238
1329
283
descent%
[freq-descent] of one-of orangutans
2
1
11

MONITOR
1337
238
1394
283
climb%
[freq-climb] of one-of orangutans
2
1
11

SLIDER
200
260
374
293
walking-speed
walking-speed
0.5
3
1.0
0.5
1
m/s
HORIZONTAL

SLIDER
200
359
373
392
brachiation-speed
brachiation-speed
0.5
3
0.5
0.5
1
m/s
HORIZONTAL

SLIDER
200
325
373
358
sway-speed
sway-speed
0.5
3
0.5
0.5
1
m/s
HORIZONTAL

BUTTON
1088
455
1151
488
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
201
150
373
183
energy-gain
energy-gain
10
1000
130.0
1
1
kCal / tree
HORIZONTAL

PLOT
865
188
1028
315
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
"default" 1.0 0 -16777216 true "show [cumulative-energy-gain] of one-of orangutans" "if plot-update = true [plot [cumulative-energy-gain] of one-of orangutans]"

MONITOR
1043
343
1159
388
energy-gain (kCal)
[cumulative-energy-gain] of one-of orangutans
2
1
11

MONITOR
1278
341
1417
386
day range (m) - horizontal
[cumulative-travel-length] of one-of orangutans
2
1
11

SLIDER
201
187
373
220
initial-satiation
initial-satiation
-500
500
-500.0
1
1
kcal
HORIZONTAL

MONITOR
1802
155
1999
200
NIL
[next-tree] of one-of orangutans
17
1
11

MONITOR
1800
207
2069
252
NIL
[upcoming-link] of one-of orangutans
17
1
11

SLIDER
200
393
374
426
climb-speed
climb-speed
0.5
3
0.5
0.5
1
m/s
HORIZONTAL

SLIDER
200
293
373
326
descent-speed
descent-speed
0.5
3
0.5
0.5
1
m/s
HORIZONTAL

BUTTON
1209
162
1358
195
NIL
save-network-simple
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1041
55
1203
185
node degree
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
"default" 1.0 1 -16777216 true "" "if plot-update = true\n[let max-degree max [count link-neighbors] of trees\nplot-pen-reset  ;; erase what we plotted before\nset-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar\nhistogram [count link-neighbors] of trees]"

SLIDER
201
117
374
150
energy-intake
energy-intake
1
15
10.0
1
1
kcal / min
HORIZONTAL

SLIDER
200
224
375
257
basal-energy
basal-energy
1
1.5
1.4
0.1
1
kcal / BW / hr
HORIZONTAL

TEXTBOX
210
61
379
79
ORANGUTAN PROPERTIES
13
0.0
1

TEXTBOX
19
66
169
84
FOREST PROPERTIES
12
0.0
1

TEXTBOX
1804
22
1954
40
ROUTE TRAVERSING
12
0.0
1

SLIDER
201
84
373
117
body-weight
body-weight
30
100
35.0
1
1
kg
HORIZONTAL

TEXTBOX
1151
216
1301
234
OUTPUT METRICS
12
0.0
1

TEXTBOX
1120
24
1270
42
NETWORK PROPERTIES
12
0.0
1

MONITOR
1044
396
1124
441
satiation
[energy-reserve] of one-of orangutans
2
1
11

PLOT
864
315
1028
444
satiation
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
"default" 1.0 0 -16777216 true "" "if plot-update = true [plot [energy-reserve] of one-of orangutans]"

TEXTBOX
907
24
982
42
ENERGETICS
12
0.0
1

MONITOR
1164
341
1273
386
visited fruiting trees
length ([visited-fruiting-tree] of one-of orangutans)
17
1
11

MONITOR
1127
395
1207
440
travelling %
[budget-travel] of one-of orangutans
2
1
11

MONITOR
1208
396
1279
441
feeding %
[budget-feeding] of one-of orangutans
2
1
11

MONITOR
1280
396
1347
441
resting %
[budget-resting] of one-of orangutans
2
1
11

MONITOR
1154
292
1255
337
basal-cost (kCal)
[basal-metabolic-cost] of one-of orangutans
2
1
11

MONITOR
1265
291
1411
336
energy-expenditure (kCal)
[cumulative-movement-cost] of one-of orangutans + [basal-metabolic-cost] of one-of orangutans
2
1
11

PLOT
1436
185
1609
308
tree dbh distribution
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" "if plot-update = true [histogram [dbh] of trees]"
PENS
"default" 1.0 1 -16777216 true "" "if plot-update = true [histogram [dbh] of trees]"

MONITOR
1621
52
1731
97
max-tree-height (m)
max ([height] of trees)
17
1
11

MONITOR
1622
102
1732
147
min-tree-height (m)
min [height] of trees
17
1
11

MONITOR
1625
181
1728
226
max-tree-dbh (cm)
max [dbh] of trees
17
1
11

PLOT
1436
52
1606
183
tree height distribution
NIL
NIL
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "if plot-update = true [histogram [height] of trees]"

MONITOR
1626
233
1730
278
min-tree-dbh (cm)
min [dbh] of trees
17
1
11

PLOT
1436
309
1609
435
crown distribution
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
"default" 1.0 1 -16777216 true "" "if plot-update = TRUE [histogram [crown-diameter] of trees]"

BUTTON
1311
453
1374
486
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

MONITOR
1623
312
1772
357
max-crown-diameter (m)
max [crown-diameter] of trees
2
1
11

MONITOR
1625
367
1748
412
min-crown-diameter
min [crown-diameter] of trees
2
1
11

TEXTBOX
1533
23
1683
41
FOREST PROPERTIES
12
0.0
1

SWITCH
1318
55
1422
88
plot-update
plot-update
1
1
-1000

MONITOR
1623
497
1712
542
next-distance
[travel-length] of one-of orangutans
17
1
11

MONITOR
390
501
463
546
swaycount
[count-sway] of one-of orangutans
17
1
11

MONITOR
599
500
695
545
brachiation-cnt
[count-brachiation] of one-of orangutans
17
1
11

MONITOR
465
501
531
546
sway-dist
[sway-dist] of one-of orangutans
17
1
11

MONITOR
697
501
795
546
brachiation-dist
[brachiation-dist] of one-of orangutans
2
1
11

MONITOR
881
500
954
545
walk-count
[count-walk] of one-of orangutans
17
1
11

MONITOR
956
500
1018
545
walk-dist
[walk-dist] of one-of orangutans
17
1
11

MONITOR
1084
503
1159
548
climb-count
[count-climb] of one-of orangutans
17
1
11

MONITOR
1162
504
1226
549
climb-dist
[climb-dist] of one-of orangutans
2
1
11

MONITOR
533
501
598
546
swaycost
[sway-cost] of one-of orangutans
17
1
11

MONITOR
799
500
880
545
brachiatecst
[brachiation-cost] of one-of orangutans
17
1
11

MONITOR
1024
502
1081
547
walkcst
[walk-cost] of one-of orangutans
17
1
11

MONITOR
1227
504
1284
549
climbcst
[climb-costs] of one-of orangutans
2
1
11

MONITOR
1287
504
1380
549
descent-count
[count-descent] of one-of orangutans
2
1
11

MONITOR
1382
505
1463
550
descent-dist
[descent-dist] of one-of orangutans
2
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
