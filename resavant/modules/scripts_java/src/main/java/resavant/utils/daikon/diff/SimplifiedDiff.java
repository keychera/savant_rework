package resavant.utils.daikon.diff;

import daikon.*;
import daikon.diff.Diff;
import daikon.diff.InvMap;
import daikon.diff.RootNode;

import java.io.*;
import plume.*;
import gnu.getopt.*;

/*>>>
import org.checkerframework.checker.initialization.qual.*;
import org.checkerframework.checker.nullness.qual.*;
import org.checkerframework.checker.signature.qual.*;
import org.checkerframework.dataflow.qual.*;
*/

/**
 * Diff is the main class for the invariant diff program. The invariant diff
 * program outputs the differences between two sets of invariants.
 *
 * The following is a high-level description of the program. Each input file
 * contains a serialized PptMap or InvMap. PptMap and InvMap are similar
 * structures, in that they both map program points to invariants. However,
 * PptMaps are much more complicated than InvMaps. PptMaps are output by Daikon,
 * and InvMaps are output by this program.
 *
 * First, if either input is a PptMap, it is converted to an InvMap. Next, the
 * two InvMaps are combined to form a tree. The tree is exactly three levels
 * deep. The first level contains the root, which holds no data. Each node in
 * the second level is a pair of Ppts, and each node in the third level is a
 * pair of Invariants. The tree is constructed by pairing the corresponding Ppts
 * and Invariants in the two PptMaps. Finally, the tree is traversed via the
 * Visitor pattern to produce output. The Visitor pattern makes it easy to
 * extend the program, simply by writing a new Visitor.
 **/
public final class SimplifiedDiff {

    private static String usage = UtilMDE.joinLines("Usage:", "    java resavant.utils.daikontools.InvariantDiff [flags...] file1 [file2]",
            "  file1 and file2 are serialized invariants produced by Daikon.",
            "  Daikon distribution and also at http://plse.cs.washington.edu/daikon/.");

    /**
     * Read two PptMap or InvMap objects from their respective files. Convert the
     * PptMaps to InvMaps as necessary, and diff the InvMaps.
     **/
    public static void main(String[] args) throws FileNotFoundException, StreamCorruptedException,
            OptionalDataException, IOException, ClassNotFoundException, InstantiationException, IllegalAccessException {
        try {
            mainHelper(args);
        } catch (Daikon.TerminationMessage e) {
            System.err.println(e.getMessage());
            System.exit(1);
        }
        // Any exception other than Daikon.TerminationMessage gets propagated.
        // This simplifies debugging by showing the stack trace.
    }

    /**
     * This does the work of main, but it never calls System.exit, so it is
     * appropriate to be called progrmmatically. Termination of the program with a
     * message to the user is indicated by throwing Daikon.TerminationMessage.
     * 
     * @see #main(String[])
     * @see daikon.Daikon.TerminationMessage
     **/
    public static void mainHelper(final String[] args) throws FileNotFoundException, StreamCorruptedException,
            OptionalDataException, IOException, ClassNotFoundException, InstantiationException, IllegalAccessException {

        boolean includeUnjustified = true;
        String outputFilename = "";

        LongOpt[] longOpts = new LongOpt[] { new LongOpt(Daikon.help_SWITCH, LongOpt.NO_ARGUMENT, null, 0) };

        Getopt g = new Getopt("resavant.utils.daikontools.InvariantDiff", args, "ho:", longOpts);
        int c;
        while ((c = g.getopt()) != -1) {
            switch (c) {
            case 'h':
                System.out.println(usage);
                throw new Daikon.TerminationMessage();
            case 'o':
                outputFilename = g.getOptarg();
                break;
            case '?':
                // getopt() already printed an error
                System.out.println(usage);
                throw new Daikon.TerminationMessage("Bad argument");
            default:
                System.out.println("getopt() returned " + c);
                break;
            }
        }
        Diff diff = new Diff();

        // The index of the first non-option argument -- the name of the
        // first file
        int firstFileIndex = g.getOptind();
        int numFiles = args.length - firstFileIndex;

        InvMap invMap1 = null;
        InvMap invMap2 = null;
        
        if (numFiles == 2) {
            String filename1 = args[firstFileIndex];
            String filename2 = args[firstFileIndex + 1];
            invMap1 = readInvMap(new File(filename1));
            invMap2 = readInvMap(new File(filename2));
        } else {
            System.out.println(usage);
            throw new Daikon.TerminationMessage();
        }

        RootNode root = diff.diffInvMap(invMap1, invMap2, includeUnjustified);

        // extract features

        PrintFeaturesVisitor featureExtractionVisitor = new PrintFeaturesVisitor(System.out, null, false, false, false);
        root.accept(featureExtractionVisitor);
        if (featureExtractionVisitor.getToPrintFeatureString().size() > 0) {
            File of = new File(outputFilename);
            if (of.getParentFile() != null && of.getParentFile().isDirectory() == false) {
                of.getParentFile().mkdirs();
            }
            PrintWriter writer = new PrintWriter(new BufferedWriter(new FileWriter(outputFilename)), true);
            for (String st : featureExtractionVisitor.getToPrintFeatureString()) {
                writer.println(st);
            }
            writer.close();
        } else {
            System.out.println("No invariant diff");
        }
    
    }

      /**
     * Reads an InvMap from a file that contains a serialized InvMap or PptMap.
     **/
    private static InvMap readInvMap(File file) throws IOException, ClassNotFoundException {
        Object o = UtilMDE.readObject(file);
        if (o instanceof InvMap) {
            return (InvMap) o;
        } else {
            PptMap pptMap = FileIO.read_serialized_pptmap(file, false);
            return new Diff().convertToInvMap(pptMap);
        }
    }
}