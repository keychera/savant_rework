package resavant.utils.daikon.diff;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OptionalDataException;
import java.io.StreamCorruptedException;
import java.util.Arrays;

public class RunExample {
	public static void main(String[] args) throws StreamCorruptedException, OptionalDataException,
			FileNotFoundException, ClassNotFoundException, InstantiationException, IllegalAccessException, IOException {
		args = Arrays.asList(
				"/home/square/Documents/projects/savant_rework/resavant/modules/daikon/tempChart/temp_daikon_result/0/failing.inv.gz",
				"/home/square/Documents/projects/savant_rework/resavant/modules/daikon/tempChart/temp_daikon_result/0/selected.inv.gz",
				"-o", "temp3.txt").toArray(new String[0]);
		SimplifiedDiff.main(args);
	}
}
