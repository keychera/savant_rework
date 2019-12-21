from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 

class ER1a(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        if nf_not != 0:
            return -1
        else:
            return np_not

class ER1b(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return nf - (np / (np + np_not + 1))

class ER5a(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return nf

class ER5b(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        return nf / (nf + nf_not + np + np_not)

class ER5c(AbstractSBFLStrategy):
    def calc(np, np_not, nf, nf_not):
        if nf_not != 0:
            return 0
        else:
            return 1