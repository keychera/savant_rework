from abc import ABC, abstractmethod

class AbstractSBFLStrategy(ABC):
    @abstractmethod
    def calc(self, np, np_not, nf, nf_not):
        pass