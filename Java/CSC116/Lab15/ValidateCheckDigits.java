import java.util.*;
import java.io.*;

/**
 * Program reads in a file and check if last digit is the remainder of sum of first 5 digits divided by 10
 * @author Yan Chen
 */
public class ValidateCheckDigits {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) throws FileNotFoundException {
        processFile();
    }

    /**
     * check if last digit is the remainder of sum of first 5 digits divided by 10
     */
    public static void processFile() throws FileNotFoundException {
        Scanner console = new Scanner(System.in);
        System.out.print("Enter filename for input file: ");
        String inname = console.next();        
        String outname = "VALID_" + inname;        
        File inf = new File(inname);
        Scanner input = new Scanner(inf);        
        File outf = new File(outname);        
        if (outf.exists()) {
            System.out.print("OK to overwrite outf? (y/n): ");
            String choice = console.next();
            if (choice.equals("n")){
                System.exit(1);
            } else {        
                PrintStream output = new PrintStream(outf);
                int sum =0;        
                while (input.hasNextLine()) {
                    String line = input.nextLine();
                    for (int i =0; i<5;i++) {
                        char element = line.charAt(i);                        
                        sum+=Character.getNumericValue(element);
                    }
                    char c_last = line.charAt(5);
                    int last = Character.getNumericValue(c_last);
                    if (last == sum % 10) {           
                        System.out.println(line + " is valid.");
                        output.println(line);
                    } else {
                        System.out.println(line + " is NOT valid.");
                    }
                }
            }
        
        }
        
    }
}