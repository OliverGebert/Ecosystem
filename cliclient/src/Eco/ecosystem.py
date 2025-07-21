#import numpy as np
from random import choice
from enum import Enum
from Eco.BirdFactory import createBird, BirdAttributes
from Eco.HumanFactory import createHuman, GadgetAttributes
from Eco.PredatorFactory import createPredator, PredatorAttributes
from Eco.habitant import Habitant


class PatchType(Enum):
    NONE = "o"
    FOREST = "f"
    WATER = "w"
    BEACH = "b"


PATCH_TYPE_PROPERTIES = {
    PatchType.NONE: {
        "name": "none",
        "char": "o",
        "color": "37m",
        "ground": 0,
        "view": 0,
    },
    PatchType.FOREST: {
        "name": "Forest",
        "char": "F",
        "color": "32m",
        "ground": 1,
        "view": 2,
    },
    PatchType.WATER: {
        "name": "Water",
        "char": "W",
        "color": "34m",
        "ground": 1,
        "view": 8,
    },
    PatchType.BEACH: {
        "name": "Beach",
        "char": "B",
        "color": "33m",
        "ground": 1,
        "view": 7,
    },
}


class Patch:
    def __init__(self, patch_type: PatchType):
        self.patch_type = patch_type
        self.properties = PATCH_TYPE_PROPERTIES[patch_type]
        self.habitant: Habitant = Habitant("e")

    @property
    def name(self):
        return self.properties["name"]

    @property
    def char(self):
        return self.properties["char"]

    @property
    def color(self):
        return self.properties["color"]

    @property
    def habitable(self):
        return self.properties["view"] != 0

    @property
    def view(self):
        return self.properties["view"]

    @property
    def habitant_id(self):
        return self.habitant.returnHabitantID()

    @property
    def habitant_description(self):
        return self.habitant.returnDescription()


class Ecosystem:
    def __init__(self, height: int, width: int, patch_codes):
        self.height = height
        self.width = width
        needed = height * width
        patch_codes = patch_codes[:]
        if len(patch_codes) < needed:
            patch_codes.extend([PatchType.NONE.value] * (needed - len(patch_codes)))
        self.grid = [
            [
                Patch(PatchType(code))
                for code in patch_codes[y*width:(y+1)*width]
            ]
            for y in range(height)
        ]

    def populate_ecosystem(self, hList):
        habitant_types = {
            "b": lambda: createBird(choice(BirdAttributes.birdList)),
            "h": lambda: createHuman(choice(GadgetAttributes.gadgetList)),
            "p": lambda: createPredator(choice(PredatorAttributes.predatorList)),
            "e": lambda: Habitant("e"),
        }
        hList = list(hList)
        idx = 0
        for row in self.grid:
            for patch in row:
                if patch.habitable:
                    if idx < len(hList):
                        habitant_type = hList[idx]
                        idx += 1
                        patch.habitant = habitant_types.get(habitant_type, habitant_types["e"])()
                    else:
                        patch.habitant = Habitant("e")

    def plot_ecosystem(self):
        report = []
        for row in self.grid:
            symbols = []
            infos = []
            for patch in row:
                patchcolor = patch.color
                symbol = patch.habitant_id or "="
                symbols.append(f"\033[{patchcolor}{symbol}\033[0m")
                infos.append(f"{patch.name} {patch.habitant_description},")
            print(" ".join(symbols))
            report.append(" ".join(infos) + "\n")
        print("", end="".join(report))

    def lap_ecosystem(self):
        pass


# Example setup
patch_list = list("wwbbbbwfffff")
habitant_list = list("bbhbbpppp")

e = Ecosystem(3, 5, patch_list)
e.plot_ecosystem()
e.populate_ecosystem(habitant_list)
e.plot_ecosystem()
