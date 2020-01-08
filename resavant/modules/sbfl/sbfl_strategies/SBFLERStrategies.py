from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 

class ER1a(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        if nf != 0:
            return -1
        else:
            return np

class ER1b(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef - (ep / (ep + np + 1))

class ER5a(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef

class ER5b(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef / (ef + nf + ep + np)

class ER5c(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        if nf != 0:
            return 0
        else:
            return 1