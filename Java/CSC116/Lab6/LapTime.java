import java.util.Scanner;

/**
 * Read integers from user and calculate time for each lap when running x miles at mm:ss pace.
 * @author Yan Chen
 */
 public class LapTime {
     public static final int N_LAP_PER_MILE = 4; //number of laps per mile;
     /**
      * Starts the program.
      * @param args command line
      */
      public static void main(String[] args) {
          // Set up Scanner for console
          Scanner in = new Scanner(System.in);
          // Prompt for number of miles and read in value
          System.out.print(" How many miles?(Value should be an integer.): ");
          int numMiles = in.nextInt();
          System.out.print(" What pace (min/mile)? Format: MM SS (e.g., 7 32):  ");
          int minute = in.nextInt();
          int second = in.nextInt();
          //System.out.println(minute);
          //System.out.println(second);
          double pace = minute + (double) second/60;
          System.out.println(" Lap Times for running " + numMiles + " mile(s) at a pace of " + minute + " minute(s), " + second + " second(s).");
          double pace_per_lap = pace / N_LAP_PER_MILE;
          for (int i = 1; i <= N_LAP_PER_MILE * numMiles; i++) {
              double new_pace = i * pace_per_lap;
              int new_minute = (int) new_pace; //minute is the integer part
              int new_second = (int) (60 * (new_pace - new_minute)); //second is the fractional part
              System.out.println("Lap " + i + ": " + new_minute + " minutes(s), " + new_second + " second(s).");
          }
      }
 }