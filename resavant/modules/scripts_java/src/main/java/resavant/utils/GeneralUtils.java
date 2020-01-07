package resavant.utils;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.function.BiPredicate;

class GeneralUtils {
    public static <T,U> T findElementInCollection(Collection<T> collection, BiPredicate<T,U> identificator, U identifier) {
        Iterator<T> iterator = collection.iterator();
        T currentElement = null;
        boolean found = false;
        while(iterator.hasNext() && !found) {
            currentElement = iterator.next();
            found = identificator.test(currentElement, identifier);
        }
        if (found) {
            return currentElement;
        } else {
            return null;
        }
    }

    public static <T,U> Set<T> findElementsInCollection(Collection<T> collection, BiPredicate<T,U> identificator, U identifier) {
        Iterator<T> iterator = collection.iterator();
        T currentElement = null;
        Set<T> foundElements = new LinkedHashSet<>();
        while(iterator.hasNext()) {
            currentElement = iterator.next();
            if (identificator.test(currentElement, identifier)) {
                foundElements.add(currentElement);
            }
        }
        return foundElements;
    }
}