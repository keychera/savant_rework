from abc import ABC, abstractmethod

class AbstractSBFLStrategy(ABC):
    @staticmethod
    @abstractmethod
    def calc(np, np_not, nf, nf_not):
        pass