import java.io.*;
import java.util.Scanner;

/**
 * Collapses spaces in file
 * 
 * @author Jessica Young Schmidt
 */
public class CollapseSpaces {
    /**
     * Starts program
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {
        Scanner console = new Scanner(System.in);
        Scanner in = getInput(console);
        System.out.print("output file name? ");
        String filename = console.next();
        File f = new File(filename);
        PrintStream out = null;
        if (!f.exists()) {
            try {
                out = new PrintStream(f);
            } catch (FileNotFoundException e) {
                System.out.println(e.getMessage());
                System.exit(1);
            }
            collapseSpaces(in, out);
            in.close(); // Close the Scanner
            out.close(); // Close the PrintStream
        } else {
            System.out.println("Ouput file already exists!");
        }
    }

    /**
     * Outputs collapsed input file into output file
     * 
     * @param in Scanner for input file
     * @param out PrintStrem for output file
     */
    public static void collapseSpaces(Scanner in, PrintStream out) {
        while (in.hasNextLine()) {
            String line = in.nextLine();
            Scanner lineScan = new Scanner(line);
            while (lineScan.hasNext()) {
                out.print(lineScan.next() + " ");
            }
            out.println();
        }
    }

    /**
     * Prompts the user for an input file name, then creates and returns a
     * Scanner tied to the file
     * 
     * @param console console input scanner
     * 
     * @return scanner for input file
     */
    public static Scanner getInput(Scanner console) {
        Scanner result = null; // null signifies NO object reference while
                               // (result == null) {
        System.out.print("input file name? ");
        String name = console.next();
        try {
            result = new Scanner(new File(name));
        } catch (FileNotFoundException e) {
            System.out.println("Input file not found. ");
            System.out.println(e.getMessage());
            System.exit(1);
        }
        return result;
    }
}
