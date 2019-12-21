from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 

class SBFLTest1(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return np_not - np

class SBFLTest2(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return nf_not - nf

