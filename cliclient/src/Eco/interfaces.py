from abc import ABC, abstractmethod


class IObserver(ABC):

    @abstractmethod
    def update(self):
        pass

    @abstractmethod
    def getDescription(self) -> str:
        pass

    @abstractmethod
    def getDanger(self) -> int:
        pass


class ISubject(ABC):
    @abstractmethod
    def registerObserver(self, o: IObserver):
        pass

    @abstractmethod
    def removeObserver(self, o: IObserver):
        pass

    @abstractmethod
    def notifyObservers(self):
        pass


class IDecorator(ABC):

    @abstractmethod
    def getDescription(self):
        pass


class IBirdBehavior(ABC):
    @abstractmethod
    def move(self) -> str:
        pass
