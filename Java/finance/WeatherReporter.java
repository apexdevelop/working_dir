import java.io.*;
import java.util.*;

/**
 * Report weather
 * 
 * @author Yan Chen
 */
public class WeatherReporter {

    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        processFile();
    }

    /**
     * read the file
     */
    public static void processFile() {
        Scanner console = new Scanner(System.in);
        Scanner fileScanner = getInputScanner(console);
        //scan title
        String title = fileScanner.nextLine();
        while (fileScanner.hasNextLine()) {
            String line = fileScanner.nextLine();
            processLine(line);
        }
    }

    /**
     * read each line in the file
     * print each line
     * 
     * @param String line
     */
    public static void processLine (String line) {
        Scanner lineScan = new Scanner(line);
        while (lineScan.hasNext()) {
            String date = lineScan.next();
            String mm = date.substring(4, 6);
            String dd = date.substring(6);
            String yyyy= date.substring(0,4);
            System.out.print(mm + "/" + dd + "/" + yyyy + " ");
            double avg = lineScan.nextDouble();
            //System.out.print(avg + " ");
            double high = lineScan.nextDouble();
            
            double low = lineScan.nextDouble();
            System.out.print("Low:  " + low + " ");
            System.out.print("High:  " + high + " ");
            String event = lineScan.next();
            //get rain
            int n1= Character.getNumericValue(event.charAt(1));
            if (n1==1){
                System.out.print("Rain:  yes ");
            } else {
                System.out.print("Rain:  no ");
            }
            //get snow
            int n2= Character.getNumericValue(event.charAt(2));
            if (n2==1){
                System.out.print("Snow:  yes");
            } else {
                System.out.print("Snow:  no");
            }
            System.out.println();
        }
    }

    /**
     * Reads filename from user until the file exists, then return a file
     * scanner
     * 
     * @param console Scanner that reads from the console
     * 
     * @return a scanner to read input from the file
     */
    public static Scanner getInputScanner(Scanner console) {
        System.out.print("Enter a file name to process: ");
        File file = new File(console.next());
        while (!file.exists()) {
            System.out.print("File doesn't exist. " + "Enter a file name to process: ");
            file = new File(console.next());
        }
        Scanner fileScanner = null;// null signifies NO object reference
                                   // while (result == null) {
        try {
            fileScanner = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.out.println("Input file not found. ");
            System.out.println(e.getMessage());
            System.exit(1);
        }
        return fileScanner;
    }

}