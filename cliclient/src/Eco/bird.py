from Eco.interfaces import IBirdBehavior
from Eco.habitant import Habitant


class Swim(IBirdBehavior):

    def move(self):
        return "I swim"


class Fly(IBirdBehavior):

    def move(self):
        return "I fly"


class Walk(IBirdBehavior):

    def move(self):
        return "I walk"


class Bird(Habitant):
    def __init__(self):
        super().__init__("b")
        self.habitantData["description"] = "bird"
        self.description = "bird"
        self.moveBehavior: IBirdBehavior
        self.danger = 1

    def getDescription(self):
        result = self.description + " and " + self.moveBehavior.move()
        return result

    def getDanger(self):
        return self.danger

    def performQuack(self) -> str:
        return "-----"

    def performMove(self):
        return self.moveBehavior.move()

    def update(self):
        pass


class Duck(Bird):

    def __init__(self):
        super().__init__()
        self.habitantData["description"] = "duck"
        self.description = "Duck"

    def performQuack(self) -> str:
        return "quack"

    moveBehavior = Fly()


class Gull(Bird):

    def __init__(self):
        super().__init__()
        self.habitantData["description"] = "gull"
        self.description = "Gull"

    def performQuack(self) -> str:
        return "squawk"

    moveBehavior = Walk()


class Swan(Bird):

    def __init__(self):
        super().__init__()
        self.habitantData["description"] = "swan"
        self.description = "Swan"

    def performQuack(self) -> str:
        return "honk"

    moveBehavior = Swim()
