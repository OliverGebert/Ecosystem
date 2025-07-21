from Eco.habitant import Habitant

class Predator(Habitant):
    def __init__(self):
        super().__init__("p")
        self.habitantData["description"] = "HUMAN"
        self.description = "I'm a predator"
        self.danger = 0

    def getDescription(self):
        return self.description

    def getDanger(self):
        return self.danger

    def update(self, lakeDanger):
        print(self.getDescription())


class Wolf(Predator):
    def __init__(self):
        super().__init__()
        self.habitantData["description"] = "WOLF"
        self.description = "I'm a wolf"
        self.danger = 10


class Fox(Predator):
    def __init__(self):
        super().__init__()
        self.habitantData["description"] = "FOX"
        self.description = "I'm a fox"
        self.danger = 6
