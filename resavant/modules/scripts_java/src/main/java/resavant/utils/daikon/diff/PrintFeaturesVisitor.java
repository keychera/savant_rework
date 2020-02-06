package resavant.utils.daikon.diff;

import java.io.PrintStream;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import daikon.Global;
import daikon.diff.*;
import daikon.Ppt;
import daikon.inv.Invariant;
import daikon.inv.Null;

/*>>>
import org.checkerframework.checker.nullness.qual.*;
*/

/**
 * Prints all the invariant pairs, including pairs containing identical
 * invariants.
 **/
public class PrintFeaturesVisitor extends DepthFirstVisitor {

	public Map<String, Map<ClassPair, Integer>> getFeaturePairCount() {
		return featurePairCount;
	}

	public Map<String, Integer> getMethodDiffInvariantCount() {
		return methodDiffInvariantCount;
	}

	// Protected so subclasses can use it.
	protected static final String lineSep = Global.lineSep;

	protected static boolean HUMAN_OUTPUT = false;

	private static DecimalFormat CONFIDENCE_FORMAT = new DecimalFormat("0.####");

	private PrintStream ps;
	private PrintWriter wrt;
	private boolean verbose;
	private boolean printEmptyPpts;
	private Map<String, Map<ClassPair, Integer>> featurePairCount = new TreeMap<String, Map<ClassPair, Integer>>();
	private Map<String, Integer> methodDiffInvariantCount = new TreeMap<String, Integer>();
	private Set<String> toPrintFeatureString = new TreeSet<String>();
	private String currentMethod = null;

	// private Map<String, Integer> methodDiffConfidenceCount = new
	// TreeMap<String, Integer>();
	private Map<String, Map<String, List<Double>>> averageConfidenceRatio = new TreeMap<String, Map<String, List<Double>>>();
	/**
	 * Stores the output generated when visiting invariant nodes. This output
	 * cannot be printed directly to the print stream, because the Ppt output
	 * must come before the Invariant output.
	 **/
	private StringBuffer bufOutput = new StringBuffer();

	private boolean printUninteresting;

	public PrintFeaturesVisitor(PrintStream ps, PrintWriter writer, boolean verbose, boolean printEmptyPpts,
			boolean printUninteresting) {
		this.ps = ps;
		this.wrt = writer;
		this.verbose = verbose;
		this.printEmptyPpts = printEmptyPpts;
		this.printUninteresting = printUninteresting;
	}

	public Set<String> getMethodList() {
		return this.methodDiffInvariantCount.keySet();
	}

	public StringBuffer getFeatureString(String methodName) {
		StringBuffer sb = new StringBuffer();
		boolean empty = true;
		if (this.methodDiffInvariantCount.containsKey(methodName) == true) {
			empty = false;
			sb.append("1:" + this.methodDiffInvariantCount.get(methodName) + " ");
			Map<ClassPair, Integer> pairCountLocal = this.featurePairCount.get(methodName);
			if (pairCountLocal != null) {
				for (ClassPair pair : pairCountLocal.keySet()) {
					int featureId = ExtractInvariantType.getFeatureID(pair);
					sb.append(featureId);
					sb.append(":");
					sb.append(pairCountLocal.get(pair));
					sb.append(" ");
				}
			}
		}
//		if (this.averageConfidenceRatio.containsKey(methodName)) {
//			Map<String, List<Double>> mp = this.averageConfidenceRatio.get(methodName);
//			empty=false;
//			for (Entry<String, List<Double>> e : mp.entrySet()) {
//				int fid = ExtractInvariantType.getConfidenceID(e.getKey());
//				double avg = Lib.averageOf(e.getValue());
//				sb.append(fid + ":" + avg + " ");
//			}
//		}
		if (empty) {
			return null;
		}
		sb.append("# " + methodName);
		return sb;
	}

	/**
	 * Prints the pair of program points, and all the invariants contained
	 * within them.
	 **/
	public void visit(PptNode node) {
		// Empty the string buffer
		bufOutput.setLength(0);
		Ppt ppt1 = node.getPpt1();
		Ppt ppt2 = node.getPpt2();
		if (ppt1 != null) {
			this.currentMethod = ppt1.name();
		} else {
			this.currentMethod = ppt2.name();
		}

		super.visit(node);

		if (bufOutput.length() > 0 || printEmptyPpts) {

			ps.print("<");
			if (ppt1 == null) {
				ps.print((/* @Nullable */ String) null);
			} else {
				ps.print(ppt1.name());
			}

			if (ppt1 == null || ppt2 == null || !ppt1.name().equals(ppt2.name())) {
				ps.print(", ");
				if (ppt2 == null) {
					ps.print((/* @Nullable */ String) null);
				} else {
					ps.print(ppt2.name());
				}
			}
			ps.println(">");
			ps.print(bufOutput.toString());
			StringBuffer sb = getFeatureString(currentMethod);
			if (sb != null) {
				ps.println(sb);
				// wrt.println(sb);
				this.toPrintFeatureString.add(sb.toString());
			}

		}

	}

	public Set<String> getToPrintFeatureString() {
		return toPrintFeatureString;
	}

	/**
	 * Prints a pair of invariants. Includes the type of the invariants and
	 * their relationship.
	 **/
	public void visit(InvNode node) {

		if (HUMAN_OUTPUT) {
			printHumanOutput(node);
			return;
		}

		Invariant inv1 = node.getInv1();
		Invariant inv2 = node.getInv2();
		if (!shouldPrint(inv1, inv2))
			return;
		if (uninteresting_diff(inv1, inv2) == false) {
			{
				if (this.methodDiffInvariantCount.containsKey(currentMethod) == false) {
					this.methodDiffInvariantCount.put(currentMethod, 0);
				}
				Integer cnt = this.methodDiffInvariantCount.get(currentMethod);
				this.methodDiffInvariantCount.put(currentMethod, cnt + 1);
			}
			/*************************************************************/
			List<Class<?>> invTypes = ExtractInvariantType.process();
			boolean flag = false;
			// System.out.println("Finding ...");
			for (Class<?> t1 : invTypes) {
				for (Class<?> t2 : invTypes) {
					inv1 = (inv1 == null) ? new Null() : inv1;
					inv2 = (inv2 == null) ? new Null() : inv2;
					if (t1.isInstance(inv1) && t2.isInstance(inv2)) {
						ClassPair p = new ClassPair(t1, t2);
						flag = true;
						if (this.featurePairCount.containsKey(this.currentMethod) == false) {
							this.featurePairCount.put(this.currentMethod, new TreeMap<ClassPair, Integer>());
						}
						Map<ClassPair, Integer> methodFeatureMap = this.featurePairCount.get(this.currentMethod);

						if (methodFeatureMap.containsKey(p) == false) {
							methodFeatureMap.put(p, 0);
						}
						Integer cnt = methodFeatureMap.get(p);
						methodFeatureMap.put(p, cnt + 1);

					}
					if (inv1 instanceof Null) {
						inv1 = null;
					}
					if (inv2 instanceof Null) {
						inv2 = null;
					}
				}
			}
			if (!flag) {
				System.out.println("Missing case:");
				if (inv1 != null) {
					System.out.println(inv1.getClass());
				} else {
					System.out.println("inv1 == null");
				}
				if (inv2 != null) {
					System.out.println(inv2.getClass());
				} else {
					System.out.println("inv2 == null");
				}
			}
		} else {
			inv1 = (inv1 == null) ? new Null() : inv1;
			inv2 = (inv2 == null) ? new Null() : inv2;
			if (inv1.getClass().toString().compareTo(inv2.getClass().toString()) == 0) {
				double conf1 = inv1.getConfidence();
				double conf2 = inv2.getConfidence();
				// if (Math.abs(conf2 - conf1) >= 1e-10) {
				// System.out.println("UDiff:\t" + currentMethod + "\t" + conf1
				// + " " + conf2 + " " + inv1.getClass());
				// }
				for (Class<?> clzz : ExtractInvariantType.process()) {
					if (clzz.isInstance(inv1) == false) {
						continue;
					}
					if (Math.abs(conf2 - conf1) >= 1e-10) {
						Map<String, List<Double>> mp = this.averageConfidenceRatio.get(currentMethod);
						if (mp == null) {
							mp = new TreeMap<String, List<Double>>();
							this.averageConfidenceRatio.put(currentMethod, mp);
						}
						String tname = clzz.toString();
						List<Double> ent = mp.get(tname);
						if (ent == null) {
							ent = new LinkedList<Double>();
							mp.put(tname, ent);
						}
						ent.add((conf2 + 0.0001) / (conf1 + 0.0001));
					}
				}
			}
			if (inv1 instanceof Null) {
				inv1 = null;
			}
			if (inv2 instanceof Null) {
				inv2 = null;
			}
		}
		/*************************************************************/
		bufPrint("  " + "<");

		if (inv1 == null) {
			bufPrint(null);
		} else {
			printInvariant(inv1);

		}
		bufPrint(", ");
		if (inv2 == null) {
			bufPrint((/* @Nullable */ String) null);
		} else {
			printInvariant(inv2);
		}
		bufPrint(">");

		int type = DetailedStatisticsVisitor.determineType(inv1, inv2);
		String typeLabel = DetailedStatisticsVisitor.TYPE_LABELS[type];
		int rel = DetailedStatisticsVisitor.determineRelationship(inv1, inv2);
		String relLabel = DetailedStatisticsVisitor.RELATIONSHIP_LABELS[rel];

		bufPrint(" (" + typeLabel + "," + relLabel + ")");

		bufPrintln();
	}

	private boolean uninteresting_diff(Invariant inv1, Invariant inv2) {
		int type = DetailedStatisticsVisitor.determineType(inv1, inv2);
		if (type == DetailedStatisticsVisitor.TYPE_NULLARY_UNINTERESTING
				|| type == DetailedStatisticsVisitor.TYPE_UNARY_UNINTERESTING) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Returns true if the pair of invariants should be printed, depending on
	 * their type, relationship, and printability.
	 **/
	protected boolean shouldPrint(/* @Nullable */ Invariant inv1, /* @Nullable */ Invariant inv2) {
		int type = DetailedStatisticsVisitor.determineType(inv1, inv2);
		if (type == DetailedStatisticsVisitor.TYPE_NULLARY_UNINTERESTING
				|| type == DetailedStatisticsVisitor.TYPE_UNARY_UNINTERESTING) {
			return printUninteresting;
		}

		int rel = DetailedStatisticsVisitor.determineRelationship(inv1, inv2);
		if (rel == DetailedStatisticsVisitor.REL_SAME_JUST1_JUST2
				|| rel == DetailedStatisticsVisitor.REL_SAME_UNJUST1_UNJUST2
				|| rel == DetailedStatisticsVisitor.REL_DIFF_UNJUST1_UNJUST2
				|| rel == DetailedStatisticsVisitor.REL_MISS_UNJUST1
				|| rel == DetailedStatisticsVisitor.REL_MISS_UNJUST2) {

			return false;
		}

		if ((inv1 == null || !inv1.isWorthPrinting()) && (inv2 == null || !inv2.isWorthPrinting())) {

			return false;
		}

		return true;
	}

	/**
	 * This method is an alternate printing procedure for an InvNode so that the
	 * output is more human readable. The format resembles cvs diff with '+' and
	 * '-' signs for the differing invariants. There is no information on
	 * justification or invariant type.
	 **/
	public void printHumanOutput(InvNode node) {

		Invariant inv1 = node.getInv1();
		Invariant inv2 = node.getInv2();

		// bufPrint(" " + "<");

		if (inv1 != null && inv2 != null && (inv1.format().equals(inv2.format()))) {
			return;
		}

		if (inv1 == null) {
			// bufPrint((String) null);
		} else {
			// printInvariant(inv1);
			bufPrintln(("- " + inv1.format()).trim());
		}
		// bufPrint(", ");
		if (inv2 == null) {
			// bufPrint((String) null);
		} else {
			bufPrintln(("+ " + inv2.format()).trim());
			// printInvariant(inv2);
		}
		// bufPrint(">");

		int type = DetailedStatisticsVisitor.determineType(inv1, inv2);
		int rel = DetailedStatisticsVisitor.determineRelationship(inv1, inv2);

		// String typeLabel = DetailedStatisticsVisitor.TYPE_LABELS[type];
		// String relLabel = DetailedStatisticsVisitor.RELATIONSHIP_LABELS[rel];
		// bufPrint(" (" + typeLabel + "," + relLabel + ")");

		bufPrintln();
	}

	/**
	 * Prints an invariant, including its printability and possibly its
	 * confidence. Example: "argv != null {0.9999+}"
	 **/
	protected void printInvariant(Invariant inv) {
		if (verbose) {
			bufPrint(inv.repr_prob());
			bufPrint(" {");
			printPrintability(inv);
			bufPrint("}");
		} else {
			bufPrint(inv.format());
			bufPrint(" {");
			printConfidence(inv);
			printPrintability(inv);
			bufPrint("}");
		}
	}

	/**
	 * Prints the confidence of the invariant. Confidences between .9999 and 1
	 * are rounded to .9999.
	 **/
	private void printConfidence(Invariant inv) {
		double conf = inv.getConfidence();
		if (.9999 < conf && conf < 1) {
			conf = .9999;
		}
		bufPrint(CONFIDENCE_FORMAT.format(conf));
	}

	/** Prints '+' if the invariant is worth printing, '-' otherwise. **/
	// XXX This routine takes up most of diff's runtime on large .inv
	// files, and is not particularly interesting. There should perhaps
	// be an option to turn it off. -SMcC
	private void printPrintability(Invariant inv) {
		if (inv.isWorthPrinting()) {
			bufPrint("+");
		} else {
			bufPrint("-");
		}
	}

	// "prints" by appending to a string buffer
	protected void bufPrint(/* @Nullable */ String s) {
		bufOutput.append(s);
	}

	protected void bufPrintln(/* @Nullable */ String s) {
		bufPrint(s);
		bufPrintln();
	}

	protected void bufPrintln() {
		bufOutput.append(Global.lineSep);
	}

}
