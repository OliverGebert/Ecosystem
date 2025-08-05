---
title: Hex-Based Ecosystem Simulation
author: "Oliver Gebert"
date: "2025-07-22"
highlight_theme: darkula
toc: false
---

\newpage
\tableofcontents

\newpage

# Introduction and Motivation

The Ecosystem is an interactive simulation designed to model a dynamic and self-sustaining virtual landscape. It aims to capture the complexity of real-world ecosystems by simulating the behavior of various animal species within a shared environment. The application allows the user to observe the ecosystem as it evolves over time, with the option to influence its development in two primary ways: by issuing direct commands to a special “human” agent that can navigate the terrain, and by modifying environmental conditions across the landscape. The player has full oversight of the map, making it possible to watch individual animal movements, monitor resource changes, and understand the interplay between species.

Before starting a simulation, the player can define the size of the map, the terrain types it contains, and the density and variety of animal populations. The map is built as a hexagonal grid, ensuring that each patch has exactly six neighboring patches, which supports natural movement patterns and balanced adjacency. Each patch is defined by static terrain attributes, such as vegetation, elevation, or water availability, and can be occupied by one or more animals depending on the simulation rules. Animals themselves have dynamic attributes, such as species type, vision range, strength, energy level, and fear level, which influence their decisions and survival chances.

In later extensions, the simulation can incorporate environmental effects such as weather and time of day, introducing conditions like daylight, darkness, heat, cold, sun, and rain. These global influences can alter animal behavior by affecting sight, energy, and fear, thereby creating more realistic and varied ecosystem dynamics. The simulation progresses in discrete rounds, during which each animal perceives its surroundings, makes movement decisions, resolves conflicts, and updates its state. This structured turn-based approach makes it possible to analyze the ecosystem in detail, trace cause-and-effect relationships, and apply deliberate interventions to shape the outcome.

# Map and Patches

The game world is represented as a **hexagon-based map** where each patch has exactly **six possible neighbors**.  
The hex layout uses an **axial coordinate system** where each patch is identified by a pair of integers `(q, r)`.

## Hex Coordinates and Neighbors

Neighbor positions are determined by adding one of six fixed offsets:

| Direction  | Offset (q, r) |
|------------|---------------|
| East       | (1, 0)        |
| North-East | (1, -1)       |
| North-West | (0, -1)       |
| West       | (-1, 0)       |
| South-West | (-1, 1)       |
| South-East | (0, 1)        |

This ensures:
- Equal movement cost in all directions.
- No diagonal bias.
- Simple distance calculations.

## Landscape Patches

The simulation map is composed of interconnected hexagonal patches, each representing a specific type of terrain. These terrain types define the static attributes of a patch, which remain constant throughout the simulation unless altered by an external influence such as a player command or a weather event. The patch type directly affects the resources and shelter available to animals occupying it, influencing their movement, survival, and interaction decisions.

![Ecosystem](./Ecosystem.png)

### Patch Types and Attributes

Each patch belongs to one of the following terrain types:

| Patch Type | Water | Food | Cover | Description |
|------------|-------|------|-------|-------------|
| **Lake**   | High  | Low  | Low   | Open water source, supports aquatic or water-dependent species, little cover for hiding. |
| **Sand**   | Low   | Low  | Low   | Arid terrain with minimal vegetation and shelter, difficult for many species to inhabit. |
| **Grass**  | Medium| High | Low   | Open plains with abundant grazing opportunities, limited cover from predators. |
| **Wood**   | Low   | Medium| High  | Forested terrain with moderate food availability and strong cover for concealment and safety. |

Water, food, and cover values influence how attractive a patch is to different animals based on their needs and survival strategies.

### Visual Representation

Each hexagonal patch is displayed with a distinct color corresponding to its terrain type:

| Patch Type | Suggested Color |
|------------|-----------------|
| Lake       | Blue            |
| Sand       | Beige / Light Yellow |
| Grass      | Bright Green    |
| Wood       | Dark Green / Brown |

This immediate visual cue allows the player to identify terrain distribution across the map at a glance.

Animals present on a patch are shown using **overlay icons** positioned at the center of the hexagon.  
- **One animal per patch**: The icon can be displayed at up to **60–70% of the hex’s width**, making it easily visible without obscuring the terrain color.  
- **Multiple animals per patch**: Options include stacking small icons in a cluster or displaying a single icon with a **small numeric counter** in the corner (e.g., “×3” to indicate three animals).  
- **Special human agent**: Displayed with a unique icon (e.g., a human silhouette or flag) that is visually distinct from animal icons.

### Sizing and Screen Fit

On a modern iPhone screen (approx. 1170×2532 pixels for iPhone 13 as a reference):
- **Hexagon width**: Around **80–100 pixels** is comfortable for visibility and interaction.
- **Icons**: Typically **50–70 pixels** wide when representing a single animal, scaling down proportionally for multiple animals.
- **Number of patches visible**: At this size, around **8–10 hexes across** the short axis and **12–14 rows** vertically can be displayed without scrolling or zooming.  
- **Zooming**: The interface should allow pinch-zoom to see more of the map at once or zoom in for detail.

This balance ensures the map is readable, the icons are distinguishable, and the terrain context remains visible, even on smaller screens.
it provides a system of elements like landscape, plants and animals, which require certain frame conditions to prosper and also provide constraints or attractors to animals in the same ecosystem.

# Animals

The simulation includes a variety of animal species, each with unique attributes and behavioral motivations. These differences affect how animals move, seek resources, and interact with other species. Attributes are expressed on a relative scale (e.g., Low, Medium, High) to simplify balancing in early development, but can be refined to numeric values for more precise simulation control.

## Animal Attributes

| Species  | Food Preference         | Strength | Fear   | Sight  | Speed  |
|----------|-------------------------|----------|--------|--------|--------|
| Seagull  | Fish, small invertebrates| Low      | Medium | High   | High   |
| Duck     | Aquatic plants, insects | Low      | Medium | Medium | Medium |
| Deer     | Grass, leaves           | Medium   | High   | Medium | High   |
| Boar     | Roots, plants, small animals | High | Medium | Medium | Medium |
| Wolf     | Large herbivores, small mammals | High | Low | High | High   |
| Lynx     | Small to medium mammals | High     | Low    | High  | Medium |

## Motivations by Species

- **Seagull**  
  Can travel over water and is an opportunistic feeder. Motivated primarily by food availability near water. Highly mobile, often moving towards visible feeding grounds. Less concerned about predators when in flight, but will avoid high predator density areas on land.

- **Duck**  
  Prefers lakes and grass near water, but is vulnerable to predators. Motivated strongly by proximity to water and aquatic vegetation. Balances food-seeking with high predator avoidance, especially when predators are in nearby patches.

- **Deer**  
  Grazing herbivore that is cautious and quick to flee. Primarily motivated by safety, avoiding predators aggressively even at the cost of reduced food intake. Moves towards open grassy areas with good visibility but low predator density.

- **Boar**  
  Omnivore that can defend itself aggressively if threatened. Motivated by a balance between food and territory. Will enter predator zones if food is abundant, relying on strength to deter attacks. Less fearful than deer, more willing to risk confrontation.

- **Wolf**  
  Pack-hunting predator, opportunistic and bold. Motivated mainly by prey presence, hunting actively and targeting herbivores. Less motivated by safety, but will retreat if outnumbered or injured. Prefers open or semi-open terrain for pursuit.

- **Lynx**  
  Stealth predator that prefers ambush hunting. Motivated by stealth and prey density, choosing patches with good cover to approach prey undetected. Less aggressive in open terrain, more inclined to stalk than to chase over long distances.

## Motivation Weighting Table

This table provides example numeric weights (0.0 to 1.0) for each species, defining the importance of **Food**, **Safety**, and **Opportunity** (e.g., hunting chances for predators, territorial advantage for others). The decision score for a move is calculated by multiplying observed patch values by these weights.

| Species  | Food Weight | Safety Weight | Opportunity Weight |
|----------|-------------|---------------|--------------------|
| Seagull  | 0.7         | 0.2           | 0.1                |
| Duck     | 0.5         | 0.4           | 0.1                |
| Deer     | 0.4         | 0.6           | 0.0                |
| Boar     | 0.5         | 0.3           | 0.2                |
| Wolf     | 0.3         | 0.1           | 0.6                |
| Lynx     | 0.3         | 0.2           | 0.5                |

- **Food Weight**: Influence of food resources on movement choice.  
- **Safety Weight**: Influence of avoiding danger or seeking cover.  
- **Opportunity Weight**: Influence of hunting chances, ambush opportunities, or territorial advantage.
Animals are autonomous agents with **species-specific traits** and **motivations**.

# Turn-Based Simulation Phases

The simulation runs in **discrete turns**, each consisting of several phases.

## Phase Overview

| Phase                  | Description |
|------------------------|-------------|
| **Perception phase**   | Animals observe six neighbors, collect data on food, predators, safety. |
| **Decision phase**     | Animals score possible moves using motivation weights; ties resolved by preference or randomness. |
| **Movement resolution**| Animals move simultaneously; collisions handled by predefined rules. |
| **Conflict resolution**| Animals in same patch after movement interact (fight, flee, coexist). |
| **Outcome phase**      | Update states (hunger, injury recovery, motivation); replenish patch resources. |
| **Next round**         | Loop repeats with updated world state. |


Animals choose the best patch to move into using a scoring system.

## Scoring Formula
score = (food_value * hunger_weight) - (danger_value * fear_weight)

Additional terms can be added for terrain bonuses or special behaviors.

## Tie Resolution Options

- Random choice.
- Preference for same direction as previous move.
- Preference for food over safety when scores match.

## Conflict Resolution Rules

When two or more animals end up in the same patch:

| Situation            | Possible Outcome |
|----------------------|------------------|
| Predator vs Prey     | Prey flees if safe neighbor exists; otherwise combat. |
| Predator vs Predator | Strongest wins, possibly injured. |
| Prey vs Prey         | Usually coexist unless competing for limited food. |

Fleeing can occur immediately or be scheduled for the next round.

## Outcome Phase Details

At the end of each round:

- **Animals**: Hunger increases, injuries heal or worsen, motivation values adjust.
- **Patches**: Food resources replenish at a rate determined by terrain type.
- **Map state**: Updated to reflect new occupant positions and resource levels.

