from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 
import math

class Multric(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return 0

class Ochiai(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef / math.sqrt((ef + nf) * (ef + ep))