from Eco.interfaces import ISubject, IObserver
from typing import List


class Lake(ISubject):

    def __init__(self, cap, pred):
        self.capacity = int(cap)
        self.firsthabitant: IObserver
        self.habitantlist: List[IObserver] = []     # type: IObserver
        self.danger = 0

    def registerObserver(self, habitant: IObserver, danger):
        if (len(self.habitantlist) < self.capacity):
            self.habitantlist.append(habitant)
            self.danger += danger

    def removeObserver(self, habitant: IObserver):
        # missing implementation of removing habitants from lake,
        # also test_removeObserver not implemented
        pass

    def notifyObservers(self):
        print("****")
        print("Danger status: " + str(self.danger))
        print("predator at lake: " + str(self.hasPredator()))

        for h in self.habitantlist:
            h.update(self.danger)

    def getCount(self):
        return len(self.habitantlist)

    def getDanger(self):
        return self.danger

    def hasPredator(self):
        predator = False
        for habitant in self.habitantlist:
            if ("gun" in habitant.getDescription()) or ("wolf" in habitant.getDescription()):
                predator = True

        return predator

    def setCapacity(self, cap):
        self.capacity = cap
