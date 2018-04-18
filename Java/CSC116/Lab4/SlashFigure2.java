/**
 * produce SlashFigure2 with class constant SIZE
 * @author Yan Chen
 */
 
public class SlashFigure2 {
    public static final int SIZE = 4;
    public static void main(String[] args) {
        for (int i = 1; i <= SIZE; i++) {
            /** print "\\" */
            for (int j = 1; j < i; j++) {
                System.out.print("\\\\");
            }
            /** print "!!" */
            for (int j = i; j <= 2 * SIZE - i; j++) {
                System.out.print("!!");
            }
            /** print "//" */
            for (int j = 2 * SIZE + 1 - i; j <= 2 * SIZE - 1; j++) {
                System.out.print("//");
            }
            System.out.println();
        }
    }
}