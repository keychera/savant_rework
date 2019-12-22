from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 

class SBFLTest1(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return np - ep

class SBFLTest2(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return nf - ef

