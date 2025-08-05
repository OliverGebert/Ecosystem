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

The Ecosystem is an interactive simulation designed to model a dynamic and self-sustaining virtual landscape. It aims to capture the complexity, unpredictability, and feedback loops of natural ecosystems by simulating the behavior of various animal species, plant growth, and environmental change within a shared environment. Players can observe the emergent evolution of the ecosystem over many simulated years, with each agent and terrain feature interacting through clear, rule-driven logic.

The application allows users to:
- Observe the ecosystem as it evolves in real time or at accelerated rates.
- Influence the environment by issuing direct commands to a unique “human” agent, introducing or removing species, or changing climate/terrain variables.
- Pause, step through, and rewind simulation turns to analyze ecosystem dynamics and notable events.
- Adjust simulation parameters (map size, climate variability, species traits, etc) before and during a run to explore "what-if" scenarios.

The map is a **hexagonal grid** supporting rich, natural movement and realistic adjacency. Each patch has terrain (vegetation, elevation, water), seasonal resource levels, and weather exposure. Agents (animals and plants) continuously adapt to changing circumstances, with species-specific sensors and motivations.

Animal species are defined with:
- **Behavioral schemas** that blend innate drives (food, safety, territory, mating, sociality) and adaptive responses to local context (weather, population density, predator/prey abundance).
- A memory of previous experiences (e.g., dangerous spots, resource-rich patches), supporting advanced behaviors like migration, territory defense, and learning avoidance.
- Interactions with both abiotic (wind, rain, temperature) and biotic (predators, prey, conspecifics, plants, human agent) factors.

Environmental effects (weather, time of day, disasters) gradually shape the map, create migration waves, and influence plant growth cycles and animal well-being. Discrete rounds simulate perception, decision-making, movement, interaction/conflict, and patch/agent state updates for maximum transparency and debuggability. Each cycle supports animation and logging for deep analysis and replay.

A robust interface overlays visualization of animal movement, resource flows, and weather, and provides a console for intervention commands and replay control, enabling educational and research uses as well as sandbox play.

# Map and Patches

The world is a scalable **hex-based map** with exactly **six neighbors per patch**. dynamic terrain generation allows diverse layouts (lakes, forests, meadows, mountains, etc.) plus user-edited patches. The **axial coordinate system** `(q, r)` simplifies neighbor lookup and pathfinding. Persistently store the map state for replays and savegames.

## Hex Coordinates and Neighbors

Neighbor positions use six predefined offsets:

| Direction  | Offset (q, r) |
|------------|---------------|
| East       | (1, 0)        |
| North-East | (1, -1)       |
| North-West | (0, -1)       |
| West       | (-1, 0)       |
| South-West | (-1, 1)       |
| South-East | (0, 1)        |

- All directions have equal cost, allowing A* or Dijkstra pathfinding.
- Hex distance is `max(abs(q1-q2), abs(r1-r2), abs((-q1-r1)-(-q2-r2)))`.
- Static map regions (e.g., mountains) can define permanent obstacles.

## Landscape Patches

The map automatically generates interconnected terrain zones (lake, sand, grass, wood, mountain) using cellular automata or Perlin noise for realism. Patches track evolving resource values (food, water, cover), climate effects, and past event history (fires, floods, heavy grazing). This helps simulate long-term environmental feedback.

![Ecosystem](./Ecosystem.png)

### Patch Types and Attributes

| Patch Type | Water | Food | Cover | Special | Description |
|------------|-------|------|-------|---------|-------------|
| **Lake**   | High  | Low  | Low   | Fish    | Open water, supports aquatic/water-adapted species, little cover. |
| **Sand**   | Low   | Low  | Low   | Heat    | Arid, sparse vegetation, harsh for most animals. |
| **Grass**  | Medium| High | Low   | Seeds   | Grazing fields, rich food, little cover. |
| **Wood**   | Low   | Medium| High | Fruit   | Dense woodland, moderate food, high shelter value. |
| **Mountain**| Low  | Low  | High  | None    | Impassable or costly to enter, refuge for some. |


Each patch displays a color (terrain type), resource bar overlays (food/water/cover), and weather or event icons (e.g., rain, snow, fire indicators). Animals are overlayed as icons:
- Clustered icons with numeric counters when multiple animals occupy a patch, scaling shape/size for clarity.
- Special icons for unique/human agents, event markers (tracks, nests, fallen trees).
- Optional toggles for displaying agent vision cones or memory traces to visualize reasoning.

### Sizing and Screen Fit

- On target screens (e.g., iPhone 13), hex width **80–100 px** for easy tap/drag/select.
- Support flexible zoom (pinch, buttons), auto-crop for aspect ratio.
- GUI overlays for map scrolling, zoom level, patch/animal inspectors.
- Options to snap to agent moves or animate overlays for turn playback.

Supports 8–10 hexes across, 12–14 rows, and scrollable/zoomable map for very large worlds. Patch icons update in real time as simulation runs. Export full screenshot or replay as video/gif for sharing or analysis.

it provides a system of elements like landscape, plants and animals, which require certain frame conditions to prosper and also provide constraints or attractors to animals in the same ecosystem.

# Animals

The simulation features a diverse set of animals—herbivores, omnivores, carnivores, and opportunists—each with unique attributes, memory, and adaptive behaviors. Species modules support easy addition of new animals or behavioral variations. Each animal is an AI agent capable of learning and adapting to changing environments.

## Animal Attributes

| Species  | Food Preference          | Strength | Fear   | Sight  | Speed  | Social | Memory | Energy |
|----------|--------------------------|----------|--------|--------|--------|--------|--------|--------|
| Seagull  | Fish, invertebrates      | Low      | Med    | High   | High   | Flock  | Short  | High   |
| Duck     | Aquatic plants, insects  | Low      | Med    | Med    | Med    | Flock  | Medium | Medium |
| Deer     | Grass, leaves            | Medium   | High   | Med    | High   | Herd   | Medium | Med    |
| Boar     | Roots, plants, small animals | High | Med    | Med    | Med    | Solo   | High   | High   |
| Wolf     | Herbivores, mammals      | High     | Low    | High   | High   | Pack   | High   | High   |
| Lynx     | Small mammals            | High     | Low    | High   | Med    | Solo   | High   | Med    |

- **Social**: Behavioral grouping (solo, flock, herd, pack)—drives group tactics, sharing, coordinated movement.
- **Memory**: Determines how long threats/resources/paths are remembered; supports learned avoidance, path optimization, and migration.
- **Energy**: Fatigue/health tracker limiting travel, aggression, and activity per turn, requiring periodic rest and feeding.

Animals respond to:
- Local weather (e.g., seek cover from rain, avoid heat, migrate in winter).
- Seasonal/diurnal changes (day/night active periods, breeding/migration seasons).
- Dynamic resource distribution and population pressures.

Agent code supports easy modular expansion:
- Plug-in new species from a JSON/YAML definition.
- Custom behavior scripts for special animals.
- Event hooks for learning, migration, population booms/crashes.

## Motivations by Species

Each species blends internal needs (hunger, safety, social) and external cues (predator proximity, resource density, seasonality) according to their characteristic weighting profiles. Motivation parameters are configurable per species, supporting tuning and emergence of surprise behaviors.

- **Seagull**  
  Highly mobile, opportunistic. Primary motivator is visible food (especially near water); less predator-averse in open spaces. Flock dynamics influence flight and roosting spots, and limited memory leads to frequent scouting.

- **Duck**  
  Attracted to water and edge-of-water grass, but avoids crowded patches and visible predators. Responds to seasonal variation by migrating between patches. Social flocking increases survival probability, especially near danger.

- **Deer**  
  Cautious grazer. Values safety above all (avoids patches with recent predator presence or poor cover). Prefers large, contiguous grassy areas with escape routes and follows herd cues when moving or fleeing.

- **Boar**  
  Aggressive omnivore with strong memory. Explores high-yield terrain even under threat, fights if cornered or protecting young. May "remember" and revisit resource-rich sites after other animals leave.

- **Wolf**  
  Pack hunter. Prioritizes visible prey and opponent counts over food per se; coordinates with nearby pack members. Tolerates risk, but will retreat to woods/mountains to recover if heavily injured or outnumbered.

- **Lynx**  
  Stealth predator. Moves quietly between high-cover patches (woods, rocks), exploiting surprise on less wary prey. Avoids open spaces, prefers ambush to direct chase; memorizes successful hunting grounds.

Special parameters enable migration (seasonal, resource-driven), home-range fidelity, and social behaviors (herding, flocking, pack tactics).

## Motivation Weighting Table

| Species  | Food Wt | Safety Wt | Opportunity Wt | Social Wt | Memory Wt |
|----------|---------|-----------|----------------|-----------|-----------|
| Seagull  | 0.60    | 0.15      | 0.10           | 0.10      | 0.05      |
| Duck     | 0.40    | 0.30      | 0.05           | 0.15      | 0.10      |
| Deer     | 0.30    | 0.65      | 0.00           | 0.05      | 0.00      |
| Boar     | 0.40    | 0.20      | 0.15           | 0.00      | 0.25      |
| Wolf     | 0.20    | 0.10      | 0.55           | 0.10      | 0.05      |
| Lynx     | 0.15    | 0.10      | 0.50           | 0.00      | 0.25      |

Score = Food * hunger_wt + Safety * safety_wt + Opportunity * opportunity_wt + Social * social_wt + Memory * memory_wt (with adjustments for species behavior, time of day, group feedback, etc).

Special-cases:
- High memory supports migration, trap avoidance, home-range return.
- Social motivation synchronizes flock/herd/pack members, supports emergent group behaviors.

# Turn-Based Simulation Phases

The simulation advances in **discrete turns/rounds**, each broken into several sub-phases to maximize clarity and modularity for future expansion (e.g. disease, breeding, weather effects, etc).

## Phase Overview

| Phase                    | Description |
|--------------------------|-------------|
| **Perception**           | Update each animal's sense data (neighbor info, resource gradients, local events, patch memory). |
| **Behavior Evaluation**  | Compute motivation scores, weighing current state (hunger, fear, fatigue, etc), memory, and group signals. |
| **Decision**             | Each agent selects best target patch/move, optionally shares/accepts group suggestions. Tie-broken by prior direction, social cue, urgency, or random choice.|
| **Movement Execution**   | Animals move in lock-step; collisions and patch contention resolved by priority and interaction rules. |
| **Interaction & Conflict** | On-patch conflicts (predation, fighting, cooperation, reproduction) resolved. Outnumbering and group tactics possible. |
| **Outcome & Environment**| Animals update internal states (energy, health, hunger), patches adjust resource levels, global changes applied. |
| **Events & Logging**     | Update event log, trigger special effects (e.g., storms, fires, migrations), UI/animation refresh. |
| **Next Turn**            | Proceed. Custom triggers/conditions for pause, intervention, or end scenarios. |

All phases modular to support plug-in features, debug logging, and batch runs for analysis.

## Scoring Formula

score = (food_value * food_weight) + (safety_value * safety_weight) + (opportunity * opportunity_weight) + (social_input * social_weight) + (memory_bonus * memory_weight)

Adjust dynamically for species, state, time of day/season, group status, and environment. Bonus/penalty terms for events like recent predator attack, patch overgrazing, environmental hazards, or achieved goals (breeding, feeding, shelter).

## Tie Resolution Options
- Prefer same direction as previous move (momentum preservation).
- Use group consensus/leader-follow (for social species).
- Favor highest value for primary motivator (e.g., food for hungry, safety for injured).
- Random selection if all else is equal.

## Conflict Resolution Rules
| Situation            | Possible Outcome |
|----------------------|------------------|
| Predator vs Prey     | Prey attempts to flee reflexively to safest adjacent patch; if blocked, fight or evade check based on speed/cover/confusion. |
| Predator vs Predator | Strongest wins, possible injuries to all; opportunity for weaker party to escape under cover. |
| Prey vs Prey         | May coexist (social or tolerant) or compete for limited resources (food/fight); group members may cooperate. |

Future event hooks: disease, mating, cooperative hunting/fending off.

## Outcome Phase Details
- **Animals**: Increase or decrease hunger, fatigue, health, motivation. Enable opportunistic actions (e.g., mate, migrate, seek shelter) based on current season/state.
- **Patches**: Regenerate resources (food/cover), mutate after extreme events (fire, drought).
- **Environmental State**: Apply weather, disasters, time-of-day. Can affect movement, visibility, or resource growth.
- All relevant changes logged/visualized for replay/debugging.

Optional advanced features:
- Save/reload state for analysis or scenario construction.
- Replay with adjustable speed and information overlays.
- Achievement or challenge system (complete food webs, extreme survival, record migrations, etc).

