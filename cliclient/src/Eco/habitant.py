import copy
from Eco.interfaces import IObserver


class Habitant(IObserver):
    habitantDict = {
        "e": {
            "name": "Empty",
            "description": "none",
            "char": "*",
            "dominance": 0
        },
        "b": {
            "name": "Bird",
            "description": "",
            "char": "B",
            "dominance": 2
        },
        "p": {
            "name": "Predator",
            "description": "",
            "char": "P",
            "dominance": 6
        },
        "h": {
            "name": "Human",
            "description": "",
            "char": "H",
            "dominance": 8
        }
    }
    habitantTypes = list(habitantDict.keys())   # Mammel, Predator

    def __init__(self, type):
        self.habitantData = copy.deepcopy(Habitant.habitantDict[type])

    def returnName(self):
        return self.habitantData["name"]

    def returnDescription(self):
        return self.habitantData["description"]

    def returnChar(self):
        return self.habitantData["char"]

    def returnDominance(self):
        return self.habitantData["dominance"]

    def update(self):
        pass

    def getDescription(self) -> str:
        return ""

    def getDanger(self) -> int:
        return 0

    def returnHabitantID(self):
        return self.habitantData["char"]
