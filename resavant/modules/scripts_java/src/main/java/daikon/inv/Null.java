package daikon.inv;

import daikon.inv.Invariant;
import daikon.inv.OutputFormat;

public class Null extends Invariant {

	@Override
	protected double computeConfidence() {
		return 0.0;
	}

	@Override
	public String format_using(OutputFormat arg0) {
		return null;
	}

	@Override
	protected Invariant resurrect_done(int[] arg0) {
		return null;
	}

}
