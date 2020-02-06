package resavant.utils.daikon.diff;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import org.reflections.Reflections;

import daikon.inv.Invariant;
import edu.emory.mathcs.backport.java.util.Collections;

public class ExtractInvariantType {
	// public static void main(String[] args) {
	// process();
	// }

	private static List<Class<?>> GET_SUBTYPES = null;
	private static Comparator cmp = new Comparator<Class>() {

		@Override
		public int compare(Class a, Class b) {
			return a.toString().compareTo(b.toString());
		}
	};

	public static void main(String[] args) throws IOException {
		List<Class<?>> lst = process();
		Set<String> pkgSet = new TreeSet<String>();
		//PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter("/usr2/btdle/TestcaseGenerationSpace/defects4j_data/results/invariant_types.list")));
		for (Class<?> clzz : lst) {
			String pkg = clzz.getPackage().getName();
			pkgSet.add(pkg);
			//writer.println(clzz.getName());
		}
		//writer.close();
		System.out.println("Total packages: " + pkgSet.size());
		for (String pkg : pkgSet) {
			System.out.println(pkg);
		}
	}

	public static List<Class<?>> process() {
		if (GET_SUBTYPES != null) {
			return new ArrayList<Class<?>>(GET_SUBTYPES);
		} else {
			Reflections reflections = new Reflections("daikon.inv");

			Set<Class<? extends Invariant>> subTypes = reflections.getSubTypesOf(Invariant.class);
			List<Class<?>> invTypes = new ArrayList();
			for (Class<? extends Invariant> e : subTypes) {
				invTypes.add(e);
			}
			GET_SUBTYPES = invTypes;
			Collections.sort(GET_SUBTYPES, cmp);
			System.out.println("Total invariant types:" + GET_SUBTYPES.size());
			return invTypes;
		}
	}

	static Map<ClassPair, Integer> FEATURE_ID = null;
	private static Map<String, Integer> CONFIDENCE_FEATURE_ID = null;

	public static int getConfidenceID(String invType) {
		if (FEATURE_ID == null) {
			init_FEATURE_ID();
		}
		if (CONFIDENCE_FEATURE_ID == null) {
			CONFIDENCE_FEATURE_ID = new TreeMap<String, Integer>();
			List<Class<?>> clazzList = process();
			int baseIndex = 1 + FEATURE_ID.size() + 1;
			for (Class<?> clazz : clazzList) {
				CONFIDENCE_FEATURE_ID.put(clazz.toString(), baseIndex);
				baseIndex++;
			}
		}
		return CONFIDENCE_FEATURE_ID.get(invType.toString());
	}

	public static int getFeatureID(ClassPair p) {
		if (FEATURE_ID == null) {
			init_FEATURE_ID();
		}
		return FEATURE_ID.get(p);

	}

	static void init_FEATURE_ID() {
		int index = 2;
		FEATURE_ID = new TreeMap<ClassPair, Integer>();
		// List<ClassPair> arr = new ArrayList<ClassPair>();
		List<Class<?>> l1 = process();
		List<Class<?>> l2 = process();
		// System.out.println(l1.size());
		// System.out.println(l2.size());
		for (Class t1 : l1) {
			for (Class t2 : l2) {
				ClassPair pair = new ClassPair(t1, t2);
				FEATURE_ID.put(pair, index);
				index++;
			}
		}
	}
}
