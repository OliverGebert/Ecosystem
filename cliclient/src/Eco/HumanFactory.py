from dataclasses import dataclass
from Eco.human import Human, Foto, Gun


@dataclass
class GadgetAttributes:
    gadgetList = ["foto", "gun"]


def createHuman(type):
    raw = Human()
    match type:
        case "foto":
            human = Foto(raw)
        case "gun":
            human = Gun(raw)
    return human
