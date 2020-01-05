package resavant.utils;

import java.util.Iterator;
import java.util.List;
import java.util.function.BiPredicate;

class GeneralUtils {
    public static <T,U> T findElementInList(List<T> list, BiPredicate<T,U> operator, U identifier) {
        Iterator<T> iterator = list.iterator();
        T currentElement = null;
        boolean found = false;
        while(iterator.hasNext() && !found) {
            currentElement = iterator.next();
            found = operator.test(currentElement, identifier);
        }
        if (found) {
            return currentElement;
        } else {
            return null;
        }
    }
}