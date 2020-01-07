package resavant.utils;

import java.util.Collection;
import java.util.Iterator;
import java.util.function.BiPredicate;

class GeneralUtils {
    public static <T,U> T findElementInCollection(Collection<T> collection, BiPredicate<T,U> operator, U identifier) {
        Iterator<T> iterator = collection.iterator();
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