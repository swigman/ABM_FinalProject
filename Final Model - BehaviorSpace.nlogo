globals
[
  week-counter ;; Counts the ticks, is reset after 156 weeks (ticks)
  mun-list ;; List for the numbers of 5 municipalities
  color-list ;; List for the colors of 5 municipalities
  total-waste ;;Total waste accumulated over 20 years in the system
  tick-counter ;; Counts ticks, is not reset
  rec-list ;; List of IDs for the recycle companies
  neg-mun ;; The municipalitie in negotiation
  neg-col-type ;; The type of waste collection system of the negotiating municipality
  neg-rec ;; The recycling companie in negotiation
  lowest-tender ;; The lowest tender offered by recycling companies
  year-counter ;; The current year to calculate the base waste
]

breed [households household] ;; Household breed
breed [municipalities municipality] ;; Municipalities breed
breed [rec-companies rec-company] ;; Recycle companies breed

households-own
[
  household-type ;; Type of household
  waste ;; Waste per household
  waste-contract ;; Waste per household per contract period
  waste-total ;; Waste per household in total
  rec-perception ;; Perception of importance of recycling
  rec-knowledge ;; Knowledge about recycling
  mun-belong ;; To which municipality does the agent belong
  plastic-waste ;; Amount of plastic per household
  plastic-waste-total ;; Plastic waste per household in total
  plastic-waste-contract ;; Plastic waste per household per contract period
  plastic-waste-recyclable ;; Amount of plastic that is recyclable
  plastic-waste-recyclable-contract ;; Plastic waste that is recyclable per household per contract period
  plastic-waste-recyclable-total ;; Plastic waste that is recyclable per household in total
  actual-plastic-waste ;; Actual household output of plastic waste
  actual-recyclable-waste ;; Actual household output of recyclable plastic
  collection-type ;; Type of collection for households
]

municipalities-own
[
  expenditures ;; Expenditures over the 20 years
  plastic-waste-volume ;; Volume of plastic waste
  recyclable-plastic-volume ;; Volume of plastic waste that is recyclable
  recycled-plastic-volume ;; Volume of recyclable plastic waste that is recycled
  expected-plastic-waste-volume ;; Expected plastic waste volume for contract negotiation
  mun ;; Which municipality
  type-collection ;;Type of waste collection
  contract? ;; Do the municipalities have a contract with a recycle company
  contracted-weight ;; Weight of plastic-waste that municipalities agreed upon with recycle company
  efficiency-linked-rec ;; The efficiency of the recycle company the municipality has a contract with
  total-plastic-waste-volume ;; Total plastic waste volume of municipality
  total-recyclable-plastic-volume ;; Total recyclable plastic volume of municipality
  total-recycled-plastic-volume  ;; Total recycled plastic volume of municipality
  contract-plastic-waste-volume ;; Plastic waste volume during contract
  contract-recyclable-plastic-volume ;; Recyclable plastic waste volume during contract
  contract-recycled-plastic-volume ;; Recycled plastic waste volume during contract
  recycle-target ;; Recycle target given by government
  target-failed ;; Number of times recycling targets are not met
  recycling-fraction ;; Fraction of plastic waste that is recycled
]

rec-companies-own
[
  ID ;; ID to identify recycle company
  capacity ;; How many municipalities are under contract with recycle company. Recycle company can have max 2 contracts
  tender ;; Offer recycle company propose to a municipality
  price-per-kilo-home ;; Price per kg that is collected from homes
  price-per-kilo-central ;; Price per kg that is collected from a central location
  efficiency ;; Efficiency of the recycling plant
]

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Setup procedures
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to setup
  clear-all ;; Clear the canvas
  set year-counter 0
  set mun-list [1 2 3 4 5] ;; Set the values for the mun-list
  set rec-list [1 2 3] ;; Set the values for the rec-list
  set color-list [orange blue white yellow red] ;; Set the colors for the color-list
  set-default-shape municipalities "house colonial" ;; Set defaulft shape municipalities
  set-default-shape households "house" ;; Set default shape households
  set-default-shape rec-companies "factory" ;; Set default shape rec-companies
  create-municipalities 5 [setup-municipalities] ;;5 municipalities in the model
  create-rec-companies 3 [setup-rec_companies] ;;3 recycling companies in the model
  create-households 210 [setup-households] ;; 350 households per turtle so: 75000 households with on average 2.7 people --> 202500 people --> 40500 people per municipality
  foreach mun-list [a -> ask n-of 42 households with [mun-belong = 0][set mun-belong a]] ;; Set the munucipality to which households belong
  (foreach mun-list color-list [ [a b] -> ask households with [mun-belong = a][set color b] ask municipalities with [mun = a][set color b]]) ;; Set the colors for the municipalities
  foreach mun-list [ a -> ask n-of 20 households with [(household-type = "NA") and (mun-belong = a)] [set household-type "Family"] ;; 20 Family households per municipality
   ask n-of 2 households with [(household-type = "NA") and (mun-belong = a)] [set household-type "Old"] ;; 2 Old households per municipality
    ask n-of 10 households with [(household-type = "NA") and (mun-belong = a)] [set household-type "Single"] ;; 10 Single households per municipality
     ask n-of 10 households with [(household-type = "NA") and (mun-belong = a)] [set household-type "Couple"]] ;; 10 Single households per municipality
  reset-ticks ;; Reset ticks
end

to setup-households ;; Setup procedure for the households
  set size 1 ;; Size is 1
  set xcor -11 + random 27 ;; Location on the canvas x-axis
  set ycor -12 + random 28 ;; Location on the canvas y-axis
  set mun-belong 0 ;; Default municipality households belong to is 0
  set household-type "NA" ;; No household type specified yet
  set rec-knowledge 0.6 ;; Initial knowledge about recycling in the neighbourhood of 0.6
  set rec-perception 0.6 ;; Initial perception about recycling in the neighbourhood of 0.6
  set-collection-type
  ask households with [collection-type = "Central"][set rec-perception rec-perception + 0.1]; rec-perception +0.1"
end

to set-collection-type
  if municipalities-with-central-collection = 1 [ask households with [mun-belong = 1][set collection-type "Central"]]
  if municipalities-with-central-collection = 2 [ask households with [(mun-belong = 1) and (mun-belong = 2)] [set collection-type "Central"]]
  if municipalities-with-central-collection = 3 [ask households with [(mun-belong = 1) and (mun-belong = 2) and (mun-belong = 3)] [set collection-type "Central"]]
  if municipalities-with-central-collection = 4 [ask households with [(mun-belong = 1) and (mun-belong = 2 )and (mun-belong = 3) and (mun-belong = 4)] [set collection-type "Central"]]
  if municipalities-with-central-collection = 5 [ask households [set collection-type "Central"]]


end

to setup-rec_companies ;; Setup procedure for the recycling companies
  ask rec-companies [set ID 0] ;; Standard ID for the recycling companies is 0
  set size 3 ;; Increase size to 3
  set color green ;; Color recycling companies green
  set xcor -11 + random 27 ;; Position on the x-axis
  set ycor -15 ;; Always on -15 on the y-axis
  ask rec-companies [set price-per-kilo-home initial-price-per-kilo-home] ;; Set price per kilo home collection to the values specified with the slider
  ask rec-companies [set price-per-kilo-central initial-price-per-kilo-central] ;; Set price per kilo central collection to the values specified with the slider
  foreach rec-list [x -> ask n-of 1 rec-companies with [ID = 0] [set ID x]] ;; Give each of the recycling companies an ID
  set efficiency 1 ;; <===============  Efficiency of the recycling company
end

to setup-municipalities
  ask municipalities [set expected-plastic-waste-volume random-near initial-expected-waste-volume ] ;; Initial expected waste volume
  set size 2 ;; Increase size to 2
  set contract? false ;; Initially the municipalities do not have contracts
  set color white ;; Give municipalities the color white
  set ycor -11 + random 27 ;; Position on the y-axis
  set xcor -15 ;; Position on the x-axis is always -15
  ask municipalities [set mun 0] ;; By default, set the municipality to 0
  foreach mun-list [x -> ask n-of 1 municipalities with [mun = 0] [set mun x]] ;; TSet their municipality
  ask municipalities [set label mun] ;; Show label of the municipality that they are
  ask municipalities [set type-collection "Home"] ;; By default, set the municipalities collection system as home
  ask n-of municipalities-with-central-collection municipalities with [type-collection = "Home"][set type-collection "Central"] ;; The slider defined number of municipalities with central collection system
  set recycle-target 0.5 ;;<=============== Set the initial recycling target
end

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Go procedure
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to go
  if week-counter = 52 [ask municipalities [increase-target]]
  if week-counter = 156 [increase-prices] ;; Increase the prices of waste collection every 3 years
  if week-counter = 156 [ask municipalities [check-contracts] end-contracts ask households [reset-values-contract]] ;; Every 3 years check if the agreed upon waste volume is met and end the current contracts
  if any? municipalities with [contract? = false][start-contract-procedure] ;; If there are any municipalities without contracts, start the contract procedure
  if tick-counter != 0 [ ;; if the tick counter is not zero
    ;; let the year-counter increase every 52 weeks. Also, set the recycling fraction for last year and check of this. The households set waste back to zero
    if remainder tick-counter 52 = 0 [set year-counter year-counter + 1 ask municipalities [set-recycling-fraction check-target] ask households [set waste 0]]
    if (remainder tick-counter 52 = 0) and (increase-perception? = true) [increase-perception] ;; Increase perception every year if this is turned on
    if (remainder tick-counter 52 = 0) and (increase-knowledge? = true )[increase-knowledge]] ;; Increase knowledge every year if this is turned on
  ask households [produce-waste] ;; Ask the households to produce waste
  ask municipalities [set-plastic-waste-mun] ;; Ask the municipalities to set their plastic waste
  ask municipalities [set-recyclable-plastic-volume] ;; Ask the municipalities to set their plastic waste volume
  ask municipalities [set-expected-plastic-waste-volume] ;; Ask the municipalities to set the expected plastic waste volume
  ask municipalities [set-recycled-plastic-mun] ;; Ask the municipalities to set their recycled plastic
  set week-counter week-counter + 1 set tick-counter tick-counter + 1 ;; Increase the week-counter and tick-counter by 1
  if ticks >= 1040 [stop] ;; if ticks is equal or greater than, stop the simulation <======== dit moet volgens mij weg als er experimenten gedaan worden
  tick
end

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Waste procedures
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to produce-waste ;; Produce waste procedure
  if household-type = "Family" ;; Only for family households
  [set waste (waste + ((waste-households year-counter) * 350) * 2) ;; Set the waste as the waste produced by 1 household * 350 (350 households per turtle) * 2 (ratio of waste production)
    set waste-contract (waste-contract + ((waste-households year-counter) * 350) * 2) ;; Same but then store this for the contract duration
     set waste-total (waste-total + ((waste-households year-counter) * 350) * 2) ;; Same but store it for the complete simulation
      set total-waste (total-waste + ((waste-households year-counter) * 350) * 2)  ;; Same but store it in a global every household type stores its waste production in
    set-other-wastes]

  if household-type = "Old" ;; Same as family household but now with different ratio of waste production (0.5)
  [set waste (waste + ((waste-households year-counter) * 350) * 0.5)
    set total-waste (total-waste + ((waste-households year-counter) * 350) * 0.5)
     set waste-contract (waste-contract + ((waste-households year-counter) * 350) * 0.5)
      set waste-total (waste-total + ((waste-households year-counter) * 350) * 0.5)
    set-other-wastes]

  if household-type = "Couple" ;; Same as family household but now with different ratio of waste production (1)
  [set waste (waste + ((waste-households year-counter) * 350) * 1)
    set total-waste (total-waste + ((waste-households year-counter) * 350) * 1)
     set waste-contract (waste-contract + ((waste-households year-counter) * 350) * 1)
      set waste-total (waste-total + ((waste-households year-counter) * 350) * 1)
    set-other-wastes]

  if household-type = "Single" ;; Same as family household but now with different ratio of waste production (0.75)
  [set waste (waste + ((waste-households year-counter) * 350) * 0.75)
    set total-waste (total-waste + ((waste-households year-counter) * 350) * 0.75)
     set waste-contract (waste-contract + ((waste-households year-counter) * 350) * 0.75)
      set waste-total (waste-total + ((waste-households year-counter) * 350) * 0.75)
    set-other-wastes]

end

to set-other-wastes
set actual-plastic-waste (fraction-plastic waste) ;; Actual household output of plastic waste
set actual-recyclable-waste (fraction-plastic-recyclable actual-plastic-waste) ;; Actual household output of recyclable plastic waste
set plastic-waste (waste * fraction-plastic rec-perception) ;; Set the plastic waste as a fraction of the waste
set plastic-waste-contract (waste-contract * fraction-plastic rec-perception) ;; Same but then store this for the contract duration
set plastic-waste-total (waste-total * fraction-plastic rec-perception) ;; Same but then store this for the complete simulation
set plastic-waste-recyclable (plastic-waste * fraction-plastic-recyclable rec-knowledge) ;; Set the ratio of recyclable plastic
set plastic-waste-recyclable-contract (plastic-waste-contract * fraction-plastic-recyclable rec-knowledge) ;; Same but then for the contract duration
set plastic-waste-recyclable-total (plastic-waste-total * fraction-plastic-recyclable rec-knowledge)  ;; Same but then for the complete simulation
end


to-report waste-households [x] ;; Yearly decreasing base waste function
  report 40 - 0.04 * x - exp(-0.01 * x) * sin(0.3 * x)
end

to set-plastic-waste-mun ;; Set the plastic waste for municipalities
  foreach mun-list [ a -> ask municipalities with [mun = a] ;; For every municipality
    [
    set plastic-waste-volume ((sum [plastic-waste] of households with [mun-belong = a])) ;; Set the plastic volume as the sum of the plastic waste of households
     set total-plastic-waste-volume ((sum [plastic-waste-total] of households with [mun-belong = a])) ;; Set the plastic volume as the sum of the plastic waste of households for the complete simulation
      set contract-plastic-waste-volume ((sum [plastic-waste-contract] of households with [mun-belong = a]))] ;; Set the plastic volume as the sum of the plastic waste of households for the contract duration
    ]
end

to set-recyclable-plastic-volume
  foreach mun-list [ a -> ask municipalities with [mun = a] ;; For every municipality
    [
    set recyclable-plastic-volume ((sum [plastic-waste-recyclable] of households with [mun-belong = a])) ;; Set the recyclable plastic volume as the sum of the plastic waste of households
     set total-recyclable-plastic-volume ((sum [plastic-waste-recyclable-total] of households with [mun-belong = a])) ;; Set the recyclable plastic volume for the complete simulation

      ;; Set the recyclable plastic volume as the sum of the plastic waste of households for the contract duration
      set contract-recyclable-plastic-volume ((sum [plastic-waste-recyclable-contract] of households with [mun-belong = a])) ] ]
end

to set-expected-plastic-waste-volume ;; Set the expected waste value
  if tick-counter > 0  ;; Only if the tick-counter is greater than 0
  [ifelse increase-perception? = true [set expected-plastic-waste-volume (((plastic-waste-volume / tick-counter) * 156) * 1.1)] ;; If perception up, then expected plastic waste volume up.
    [set expected-plastic-waste-volume ((plastic-waste-volume / tick-counter) * 156)]] ;; Expected value = average plastic waste per tick multiplied by three years
end

to set-recycled-plastic-mun ;; set the recycled plastic
  set recycled-plastic-volume (recyclable-plastic-volume * efficiency-linked-rec) ;; Recycled plastic = recyclable plastic multiplied with the efficiency of the recycle company
  set total-recycled-plastic-volume (total-recyclable-plastic-volume * efficiency-linked-rec) ;; Same but for complete simulation
  set contract-recycled-plastic-volume (contract-recyclable-plastic-volume * efficiency-linked-rec) ;; Same but stored for contracting period
end

to reset-values-contract ;; Reset the waste values when contract has ended
  set  waste-contract 0
end


;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Campaign procedures
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to increase-perception ;; Increase the perception of households
  ask households [set rec-perception rec-perception + ((1 - rec-perception) * 0.25)] ; every year, perception wil increase by 10% of the remaining range
end

to increase-knowledge ;; Increase the knowledge of households
  ask households [set rec-knowledge rec-knowledge + ((1 - rec-knowledge) * 0.25)] ; every year, knowledge wil increase by 10% of the remaining range
end

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Contracting procedures
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to start-contract-procedure ;; Start the contracting procedure
  while [any? municipalities with [contract? = false]][ask one-of municipalities with [contract? = false] ;; While there are municipalities without contracts
    [set neg-mun mun check-collection-type]] ;; Start procedure to check what collection system the negotiating municipality has
end

to check-collection-type ;; Check the collection type of negotiating municipality
  set neg-col-type [type-collection] of municipalities with [mun = neg-mun] ;; Store the collection type
  ifelse neg-col-type = "Home" [set-tender-home][set-tender-central] ;; Start the corresponding tender procedure
end

to set-tender-home ;; The tender for home collection procedure
  ask rec-companies with [ID = 1][if capacity < 2 [set tender (bid-home 1 neg-mun)]] ;; Recycle companies set a tender
  ask rec-companies with [ID = 2][if capacity < 2 [set tender (bid-home 2 neg-mun)]]
  ask rec-companies with [ID = 3][if capacity < 2 [set tender (bid-home 3 neg-mun)]]
  select-lowest-tender
end

to set-tender-central ;; The tender for centralized collection procedure
  ask rec-companies with [ID = 1][if capacity < 2 [set tender (bid-central 1 neg-mun + 1)]] ;; Recycle companies set a tender
  ask rec-companies with [ID = 2][if capacity < 2 [set tender (bid-central 2 neg-mun + 2)]]
  ask rec-companies with [ID = 3][if capacity < 2 [set tender (bid-central 3 neg-mun + 3)]]
  select-lowest-tender
end

to select-lowest-tender ;; Select the lowest tender
  set lowest-tender min [tender] of rec-companies with [(capacity < 2)] ;; THe municipalities select the lowest tender from a recycle company that has capacity left
  ask rec-companies with [(tender = lowest-tender)][create-link] ;; Start the link procedure between recycle company and municipality
end

to create-link
  ask rec-companies with [(tender = lowest-tender)][create-links-with municipalities with [mun = neg-mun]] ;; Create a link between the recycle company with lowest tender and negotiating recycle company
  ;; The municipalities pay the amount agreed up and set the contracted weight
  ask municipalities with [mun = neg-mun][set contract? true set expenditures expenditures + lowest-tender set contracted-weight calc-contracted-weight neg-mun]
  ;; The municipalities set the efficiency of the recycle companies
  ask rec-companies with [tender = lowest-tender][set capacity capacity + 1 ask link-neighbors [set efficiency-linked-rec ([efficiency] of myself)]]
end

to end-contracts ;; End the contracts
  ask municipalities [set contract? false] ;; Set contracts to false
  ask rec-companies [set capacity 0] ;; Rec-companies have all capacity again
  ask links [die] ;; Links are terminated
  set week-counter 0 ;; week-counter is set to 0
end

to-report bid-home [a b] ;; The bid for home collection systems
  report (max [price-per-kilo-home] of rec-companies with [ID = a])  * (max [expected-plastic-waste-volume] of municipalities with [mun = b])
end

to-report bid-central [a b] ;; The bid for central collection systems
  report (max [price-per-kilo-central] of rec-companies with [ID = a])  * (max [expected-plastic-waste-volume] of municipalities with [mun = b])
end

to-report calc-contracted-weight [a] ;; The contracted weight
  report max [expected-plastic-waste-volume] of municipalities with [mun = a]
end

to check-contracts ;; If the volume is smaller than the contracted waste, a fine is given. If it is larger, the costs increase
  ifelse contract-plastic-waste-volume < contracted-weight [fine][add-extra-costs]
end

to add-extra-costs ;; The additional costs procedures
  ifelse type-collection = "Home"
  [set expenditures expenditures + (plastic-waste-volume - contracted-weight) * (max [price-per-kilo-home] of link-neighbors * 1.1)] ;; Price waste above contract is 10% higher <================
    [set expenditures expenditures + (plastic-waste-volume - contracted-weight) * (max [price-per-kilo-central] of link-neighbors * 1.1)] ;; Price waste above contract is 10% higher <================
end

to fine ;; The fine procedure
  set expenditures expenditures + 10000000 ;; <============== fine of 1 million is added to the expenditures of the municipality
end

to increase-prices ;; Prices of waste collection increase every 3 years
  ask rec-companies [set price-per-kilo-home price-per-kilo-home * 1.05 set price-per-kilo-central price-per-kilo-central * 1.05] ;prices increase with 5% every 3 years
end

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Check target procedures
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to check-target ;; Check if the targets given by government are met, if not store that
  if recycle-target > (recycled-plastic-volume / plastic-waste-volume) [set target-failed target-failed + 1] ;; DIT MOET ANDERS --> Via actual-plastic-waste van households!
end

to increase-target ;; The recycling targets increase every year
  set recycle-target recycle-target + 0.01 ;<======= recycling target increases with 10% each year
end

to set-recycling-fraction ;; Calculate the fraction of recycling
  ask municipalities [set recycling-fraction (plastic-waste-volume / recycled-plastic-volume)] ;;<============ recycling fraction is the recycled percentage of all plastics
end

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Fraction procedures
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to-report fraction-plastic [a] ;; Fraction of plastic in waste
  report 0.07 * a  ;;0.07 is the maximal fraction of plastic, times the perception to have the fraction of plastic that is in the base waste
end

to-report fraction-plastic-recyclable [a] ;; Fraction of recycable plastic in plastic-waste
  report 0.8 * a  ;;0.8 80% of the plastic is recyclable, this times the knowledge about recycling gives the fraction of recyclable plastic
end

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Additional procedures
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

to-report random-near [center]  ;; sets values with an approximately "normal" distribution around the given value. (Adopted from the AIDS model)
  let result 0
  repeat 40
    [ set result (result + random-float center) ]
  report result / 20
end
@#$#@#$#@
GRAPHICS-WINDOW
232
10
838
617
-1
-1
18.12121212121212
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
7
10
184
43
setup
setup\n
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
7
48
183
81
Go forever
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
7
87
183
120
Go once
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

MONITOR
1214
108
1509
153
NIL
count households with [household-type = \"Family\"]
17
1
11

MONITOR
1214
160
1493
205
NIL
count households with [household-type = \"Old\"]
17
1
11

MONITOR
1215
212
1508
257
NIL
count households with [household-type = \"Single\"]
17
1
11

MONITOR
1219
318
1488
363
NIL
count households with [mun-belong = 5]
17
1
11

MONITOR
1213
61
1323
106
NIL
count households
17
1
11

MONITOR
1216
265
1515
310
NIL
count households with [household-type = \"Couple\"]
17
1
11

MONITOR
1210
11
1483
56
Average waste per municipality (in Kton / year)
((total-waste / 20) / 5)/ 1000000
17
1
11

SLIDER
5
160
182
193
initial-price-per-kilo-central
initial-price-per-kilo-central
0
2
0.6
0.1
1
NIL
HORIZONTAL

SLIDER
6
123
183
156
initial-price-per-kilo-home
initial-price-per-kilo-home
0
2
0.72
0.1
1
NIL
HORIZONTAL

SWITCH
7
236
180
269
increase-perception?
increase-perception?
0
1
-1000

SWITCH
7
274
178
307
increase-knowledge?
increase-knowledge?
0
1
-1000

SLIDER
6
198
182
231
municipalities-with-central-collection
municipalities-with-central-collection
0
5
3.0
1
1
NIL
HORIZONTAL

MONITOR
1219
429
1442
494
Recycling targets failed
round ((sum[target-failed] of municipalities) / 5)
17
1
16

PLOT
846
10
1205
311
Expenditures per collection type
week
€
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Home" 1.0 0 -13345367 true "" "plot (sum[expenditures] of municipalities with [type-collection = \"Home\"]) / (count municipalities with [type-collection = \"Home\"])"
"Central" 1.0 0 -2674135 true "" "plot (sum[expenditures] of municipalities with [type-collection = \"Central\"]) / (count municipalities with [type-collection = \"Central\"])"

PLOT
4
313
224
468
Knowledge & Perception
week
fraction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"know" 1.0 0 -10899396 true "" "plot (sum[rec-knowledge] of households) / count households\n"
"perc" 1.0 0 -5825686 true "" "plot (sum[rec-perception] of households) / count households"

PLOT
845
316
1206
618
Separated & recycled plastic fraction
week
fraction
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Recycled" 1.0 0 -8630108 true "" "if tick-counter > 0 [plot (sum[recycled-plastic-volume] of municipalities) / (sum[actual-plastic-waste] of households)]"
"Separated" 1.0 0 -955883 true "" "if tick-counter > 0 [plot (sum[actual-plastic-waste * rec-perception] of households) / (sum[actual-plastic-waste] of households)]"

PLOT
5
471
222
619
Target recycled fraction
week
fraction
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ((sum[recycle-target] of municipalities) / (5))"

SLIDER
189
10
222
309
initial-expected-waste-volume
initial-expected-waste-volume
1500000
3500000
2500000.0
1000
1
kg
VERTICAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

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

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

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

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>(sum[rec-knowledge] of households) / count households</metric>
    <metric>(sum[rec-perception] of households) / count households</metric>
    <metric>sum[recycle-target] of municipalities</metric>
    <metric>count municipalities with [type-collection = "Home"]</metric>
    <metric>(sum[expenditures] of municipalities with [type-collection = "Home"]) / (count municipalities with [type-collection = "Home"])</metric>
    <metric>count municipalities with [type-collection = "Central"]</metric>
    <metric>(sum[expenditures] of municipalities with [type-collection = "Central"]) / (count municipalities with [type-collection = "Central"])</metric>
    <metric>sum[recycled-plastic-volume] of municipalities / (sum[actual-plastic-waste] of households)</metric>
    <metric>sum[actual-plastic-waste * rec-perception] of households / (sum[actual-plastic-waste] of households)</metric>
    <metric>round ((sum[target-failed] of municipalities) / 5)</metric>
    <enumeratedValueSet variable="increase-perception?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="increase-knowledge?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-expected-waste-volume" first="1500000" step="250000" last="3500000"/>
    <enumeratedValueSet variable="initial-price-per-kilo-central">
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-price-per-kilo-home">
      <value value="0.72"/>
    </enumeratedValueSet>
    <steppedValueSet variable="municipalities-with-central-collection" first="0" step="1" last="5"/>
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
