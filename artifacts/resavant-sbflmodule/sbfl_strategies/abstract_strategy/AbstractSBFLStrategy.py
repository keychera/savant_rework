from abc import ABC, abstractmethod

class AbstractSBFLStrategy(ABC):
    @staticmethod
    @abstractmethod
    def calc(ep, np, ef, nf):
        pass