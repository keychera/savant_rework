from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 
import math

class GP02(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return 2 * (ef + math.sqrt(ep + np) + math.sqrt(ep))

class GP03(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return math.sqrt(abs((ef * ef) - math.sqrt(ep)))

class GP13(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        divisor = (2 * ep * ef)
        if (divisor != 0):
            return ef * (1 + (1/divisor))
        else:
            return 0

class GP19(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef * math.sqrt(abs(nf - np))
