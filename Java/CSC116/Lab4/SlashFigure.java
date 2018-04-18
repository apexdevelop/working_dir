/**
 * produce SlashFigure
 * @author Yan Chen
 */
 
public class SlashFigure {
    public static void main(String[] args) {
        for (int i = 1; i <= 6; i++) {
            /** print "\\" */
            for (int j = 1; j < i; j++) {
                System.out.print("\\\\");
            }
            /** print "!!" */
            for (int j = i; j <= 11 - i + 1; j++) {
                System.out.print("!!");
            }
            /** print "//" */
            for (int j = 11 - i + 2; j <= 11; j++) {
                System.out.print("//");
            }
            System.out.println();
        }
    }
}