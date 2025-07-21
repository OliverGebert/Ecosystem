from Eco.interfaces import IDecorator
from Eco.habitant import Habitant


class Human(Habitant):
    def __init__(self):
        super().__init__("h")

        self.habitantData["description"] = "HUMAN"
        self.description = "I'm human"
        self.danger = 3

    def getDescription(self):
        return self.description

    def getDanger(self):
        return self.danger

    def update(self, lakedanger):
        print(self.getDescription())


class Gadget(IDecorator, Human):

    def __init__(self, human: Human):
        super().__init__()
        self._human = human

    def update(self, lakedanger):
        print(self.getDescription())

    def getDescription(self):
        return self._human.getDescription()

    def getDanger(self):
        return self._human.getDanger()


class Foto(Gadget):

    def __init__(self, human):
        super().__init__(Human())

    def getDescription(self):
        return self._human.getDescription() + ", foto"

    def getDanger(self):
        return self._human.getDanger() + 1


class Gun(Gadget):

    def __init__(self, human):
        super().__init__(Human())

    def getDescription(self):
        return self._human.getDescription() + ", gun"

    def getDanger(self):
        return self._human.getDanger() + 5
