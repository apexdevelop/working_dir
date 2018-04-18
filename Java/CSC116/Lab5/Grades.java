/**
 * Methods in class letter grade based on number grade.
 * 
 * @author Yan Chen
 */
public class Grades {

    /**
     * The method that is executed when the program is run
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        int score=63;
        double grade;
        grade = map(score);
        System.out.println("parameter = " + score + ", Return value = " + grade);
    }

    /**
     * Returns the letter grade with given score
     * 
     * @param score
     *
     * @return
     */
    public static double map(int score) {
        double grade;
        grade = score / 60 * (score - 60) * 0.1;
        return grade;
    }
}
