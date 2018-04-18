import java.util.*;

/**
 * Represents a calendar year/month/day date.
 * 
 * @author Reges & Stepp
 */
public class Date {
    /** January constant */
    private static final int JANUARY = 1;
    /** February constant */
    private static final int FEBRUARY = 2;
    /** December constant */
    private static final int DECEMBER = 12;
    /** Days per week constant */
    private static final int DAYS_PER_WEEK = 7;
    /** Names of days */
    private static final String[] DAY_NAMES = {
                    // 0, 1, 2, 3,
                    "Sunday", "Monday", "Tuesday", "Wednesday",
                    // 4, 5, 6
                    "Thursday", "Friday", "Saturday" };
    /** Days per month - note that index 0 is -1 */
    private static final int[] DAYS_PER_MONTH = { -1,
                    // 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
                    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, };

    /** Year */
    private int year;
    /** Month */
    private int month;
    /** Day */
    private int day;

    /**
     * Constructs a new Date to represent the specified year/month/day.
     * 
     * @param year given year
     * @param month given month
     * @param day given day
     */
    public Date(int year, int month, int day) {
        this.year = year;
        this.month = month;
        this.day = day;
    }

    /**
     * Constructs a new Date to represent today.
     */
    public Date() {
        this(1970, JANUARY, 1);
        // Date chosen from: System - public static long currentTimeMillis()
        // the difference, measured in milliseconds, between the current time
        // and midnight, January 1, 1970 UTC.

        // computes days since Jan 1, 1970
        int daysSinceEpoch = (int) ((System.currentTimeMillis() + TimeZone.getDefault()
                        .getRawOffset()) / 1000 / 60 / 60 / 24);

        addDays(daysSinceEpoch);
    }

    /**
     * Advances this Date by the given number of days. pre: days >= 0
     * 
     * @param days number of days to add
     */
    public void addDays(int days) {
        for (int i = 0; i < days; i++) {
            nextDay();
        }
    }

    /**
     * Advances this Date by the given number of weeks. pre: weeks >= 0
     * 
     * @param weeks number weeks to add
     */
    public void addWeeks(int weeks) {
        addDays(weeks * DAYS_PER_WEEK);
    }

    /**
     * Returns the number of days between this Date and the given other Date.
     * 
     * @param other other date to exam
     * @return number of days between this and other
     */
    public int daysTo(Date other) {
        if (other.year < year || (other.year == year && other.month < month)
                        || (other.year == year && other.month == month && other.day < day)) {
            // other is before this date; reverse the call
            return -other.daysTo(this);
        } else {
            // other is after this Date; count days between
            Date copy = new Date(year, month, day);
            int count = 0;
            while (!copy.equals(other)) {
                copy.nextDay();
                count++;
            }

            return count;
        }
    }

    /**
     * Returns whether the given object is a Date that refers to the same
     * year/month/day as this Date.
     * 
     * @param o another object
     * @return whether o is equal to this
     */
    public boolean equals(Object o) {
        // a well-behaved equals method returns false for null and non-Dates
        if (o instanceof Date) {
            Date other = (Date) o;
            return day == other.day && month == other.month && year == other.year;
        } else {
            return false;
        }
    }

    /**
     * Returns this Date's day.
     * 
     * @return day of this
     */
    public int getDay() {
        return day;
    }

    /**
     * Returns this Date's month.
     * 
     * @return month of this
     */
    public int getMonth() {
        return month;
    }

    /**
     * Returns this Date's year.
     * 
     * @return year of this
     */
    public int getYear() {
        return year;
    }

    /**
     * Returns the day of the week on which this Date occurred, such as "Sunday"
     * or "Wednesday".
     * 
     * @return day of week for this
     */
    public String getDayOfWeek() {
        int dayIndex = 1;
        Date temp = new Date(1753, JANUARY, 1);
        while (!temp.equals(this)) {
            temp.nextDay();
            dayIndex = (dayIndex + 1) % DAYS_PER_WEEK;
        }

        return DAY_NAMES[dayIndex];
    }

    /**
     * Returns whether this Date occurred during a leap year. Leap years are
     * every fourth year, except those that are divisible by 100 and not by 400.
     * 
     * @return whether this year is leap year
     */
    public boolean isLeapYear() {
        return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
    }

    /**
     * Advances this Date to the next day. This may cause a wrap-around into the
     * next month or year.
     */
    private void nextDay() {
        day++;
        if (day > getDaysInMonth()) {
            // wrap to next month
            month++;
            day = 1;
            if (month > DECEMBER) {
                // wrap to next year
                year++;
                month = JANUARY;
            }
        }
    }

    /**
     * Returns a String representation of this Date, such as "2005/9/22".
     * 
     * @return String representation of this Date
     */
    public String toString() {
        return year + "/" + month + "/" + day;
    }

    /**
     * A helper method to return the number of days in this Date's month.
     * 
     * @return number of days in this Date's month
     */
    private int getDaysInMonth() {
        int result = DAYS_PER_MONTH[month];
        if (month == FEBRUARY && isLeapYear()) {
            result++;
        }
        return result;
    }
}
