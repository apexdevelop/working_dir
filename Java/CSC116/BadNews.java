/**
 * print odd number until 21
 * @author Yan Chen
 */
 
 public class BadNews {
    public static final int MAX_ODD = 11;

    public static void writeOdds() {
        int odd;
        // print each odd number
        for (int count = 1; count <= MAX_ODD; count++) {
            odd = 2 * count - 1;
            System.out.print(odd + " ");
        }
    }

    public static void main(String[] args) {
        // write all odds up to 21
        writeOdds();
        //print an empty line
        System.out.println();
    }
}