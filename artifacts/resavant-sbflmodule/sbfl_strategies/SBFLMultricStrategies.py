from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 
import math

class Multric(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return 0

class Ochiai(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return nf / math.sqrt((nf + nf_not) * (nf + np))