from dataclasses import dataclass
from Eco.predator import Wolf, Fox


@dataclass
class PredatorAttributes:
    predatorList = ["wolf", "fox"]

def createPredator(type):
    match type:
        case "wolf":
            predator = Wolf()
        case "fox":
            predator = Fox()
    return predator
