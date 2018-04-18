import java.util.*;
import java.io.*;

/**
* Program reads in a file and collapse spaces between words to single space
* @author Yan Chen
*/
public class CollapseSpaces {
    
    /**
    * Starts the program
    *
    * @param args array of command line arguments
    */
    public static void main(String[] args) throws FileNotFoundException {
        collapseSpaces();
    }
    
    /**
    * collapse spaces between words to single space
    */
    public static void collapseSpaces() throws FileNotFoundException {
        String inname = "input.txt";
        String outname = "output.txt";
        File inf = new File(inname);
        Scanner input = new Scanner(inf);
        File outf = new File(outname);
        PrintStream output = new PrintStream(outf);
        while (input.hasNextLine()) {
            String line = input.nextLine();
            Scanner lineScan = new Scanner(line);
            while (lineScan.hasNext()) {
                output.print(lineScan.next() + " ");
            }
            output.println();
        }
    }
}
