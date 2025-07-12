# The Ecosystem
it provides a system of elements like landscape, plants and animals, which require certain frame conditions to prosper and also provide constraints or attractors to animals in the same ecosystem.

![Ecosystem](./Ecosystem.png)

## Landscape
A Landscape has a size (lxw), e.g. 5x5 and each tile is of one type
- water
- beach
- wood

Every tile can be entered by multiple habitants. In case more than one habitant enters the tile, following options exist:
- a carnivore kills the other habitant
- the strongest habitant pushes the other habitants to one of the connected tiles.
- later: birds might fly away from earth predator

## Tiles
- Every tile has a fixed position (x/y coordinate)
- every tile owns a certain type of landscape
- every tile can have max one habitant at the end of the progression

## Landscape
- every landscape has a type (water, beach, wood)
- every landscape has a vision indicator (0-10)
 
## Habitant
- Every habitant is of a type (seagull, fox, human)
- later: every habitant has a current hydration level
- every habitant as possible motion levels, one of them is active per round (air, surface):w
- every habitant has a current food level
- every habitant has preferred landscapes for motion
- every habitant has preferred landscape for food
- every habitant has a vision attribute, indicating how far he can see
- every habitant has a predator level (1-10) to indicate its level in the food chain
- every habitant has a pace attribute (1-10) In case of multiple habitants, the higher habitant in the food chain chases the lower one. If the lower one is faster, it escapes to another tile. If not it will be killed.

## Progression
The Ecosystem has a live in discrete rounds/progressions. In each round the following happens:
1 for each habitant the current food level is recalculated based on landscape offerings
2 For each tile potential habitants analyse their most attractive next tile
3 Each habitant moves to its most attractive tile
4 If there are multiple habitants on one tile they either push others away or kill them (based on individual pace comparison)
5 repeat from previous step2 until there are no more clashes on tiles

### Attraction
attraction is defined by evaluating a score for each connected tile, including current tile
attraction value starts with 5. Lowest possible value is 0, this means the habitant will not go there   
1. increase value if prey is on the tile
2. decrease value if predator is on the tile
3. set value to zero, if landscape type is not possible

# Feature todo list
It has the following features:
- birds can be duck types, gull or swans, they can fly, swim or duck
- predators can be wolf and lynx, they can walk or hide
- humans can be hunter or ranger, they can walk, sit or hide. They can have a gun, binocular or backsack, or all of which.
- different creatures are attracted by different eco system states: humans are attracted by weather condition and number of birds and predators. Birds are attracted by other birds and absence of predators or humans. Predators are attracted by birds and absence of humans.
- eco system knows all creatures at lake side, weather conditions, number of birds, humans and predators and total danger index.

# Implementation Detail

![PackageDiagram](./packages_Ecosystem.png)
![ClassDiagram](./classes_Ecosystem.png)
