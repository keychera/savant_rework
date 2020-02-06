package resavant.utils.daikon.diff;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OptionalDataException;
import java.io.StreamCorruptedException;
import java.util.Arrays;

public class RunExample {
	public static void main(String[] args) throws StreamCorruptedException, OptionalDataException,
			FileNotFoundException, ClassNotFoundException, InstantiationException, IllegalAccessException, IOException {
		args = Arrays.asList("-u",
				"/home/square/Documents/projects/savant_rework/resavant/modules/daikon/temp_ask/A.inv.gz",
				"/home/square/Documents/projects/savant_rework/resavant/modules/daikon/temp_ask/B.inv.gz",
				"temp.txt").toArray(new String[0]);
		Diff.main(args);
	}
}
