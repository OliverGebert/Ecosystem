from dataclasses import dataclass
from Eco.bird import Duck, Gull, Swan

@dataclass
class BirdAttributes:
    birdList = ["duck", "gull", "swan"]


def createBird(type):
    match type:
        case "duck":
            bird = Duck()
        case "gull":
            bird = Gull()
        case "swan":
            bird = Swan()
    return bird
