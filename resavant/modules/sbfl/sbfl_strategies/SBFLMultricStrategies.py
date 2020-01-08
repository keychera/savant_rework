from .abstract_strategy.AbstractSBFLStrategy import AbstractSBFLStrategy 
import math

class Multric(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return 0

class Tarantula(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = ef / (ef + nf)
        b = ep / (ep + np)
        return a / (a + b)

class Ochiai(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef / math.sqrt((ef + nf) * (ef + ep))

class Jaccard(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef / (ef + ep + nf)

class Ample(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = ef / (ef + nf)
        b = ep / (ep + np)
        return abs(a - b)

class RussellRao(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef / (ef + ep + nf + np)

class Hamann(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = ef + np - ep - nf
        b = ef + ep + nf + np
        return a / b

class SorensenDice(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return 2 * ef / ((2 * ef) + ep + nf)

class Dice(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return (2 * ef)/(ef + ep + nf)

class Kulczynski1(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef / (nf + ep)

class Kulczynski2(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = ef / (ef + nf)
        b = ef / (ef + ep)
        return 0.5 * (a + b)

class SimpleMatching(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef + np / (ef + ep + nf + np)

class Sokal(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = (2 * ef) + (2 * np)
        b = nf + ep
        return a / (a + b)

class M1(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return (ef + np)/(nf + ep)

class M2(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        divisor = ef + np + (2 * nf) + (2 * ep)
        if (divisor != 0):
            return ef / divisor
        else:
            return 0

class RogersTanimoto(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef + np / (ef + np + (2 * nf) + (2 * ep))

class Goodman(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = (2 * ef) - nf - ep
        b = (2 * ef) + nf + ep
        return a / b

class Hamming(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef + np

class Euclid(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return math.sqrt(ef + np)

class Overlap(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = (min(ef,ep,nf))
        if a == 0:
            return 0
        else:
            return ef / a

class Anderberg(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef / (ef + (2 * ep) + (2 * nf))
        
class Ochiai2(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        a = ef * np
        b = (ef + ep)*(nf + np)*(ef + np)*(ep + nf)
        if b == 0:
            return 0
        else:
            c = math.sqrt(b)
            return a / c

class Zoltar(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        if (ef == 0):
            return 0
        a = (10000 * nf * ep) / ef
        divisor = (ef + ep + nf + a)
        if (divisor != 0):
            return ef / divisor
        else:
            return 0

class Wong1(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef

class Wong2(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        return ef - ep

class Wong3(AbstractSBFLStrategy):
    def calc(ep, np, ef, nf):
        if ep <= 2:
            h = ep
        elif ep > 2 and ep <= 10:
            h = 2 + (0.1 * (ep - 2))
        else:
            h = 2.8 + (0.01 * (ep - 10))
        return ef - h
