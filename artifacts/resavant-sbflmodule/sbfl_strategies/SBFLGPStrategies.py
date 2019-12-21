from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 
import math

class GP02(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return 2 * (nf + math.sqrt(np + np_not) + math.sqrt(np))

class GP03(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return math.sqrt(abs((nf * nf) - math.sqrt(np)))

class GP13(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return nf * (1 + (1/(2 * np * nf)))

class GP19(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return nf * math.sqrt(abs(nf_not - np_not))
