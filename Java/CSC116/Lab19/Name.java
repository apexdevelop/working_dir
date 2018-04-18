 /** A object represents first, last and middle name.
 *
*/
 public class Name {
        String first;
        String last;
        char mid;
        
        /**
        *Sets first name field to first
        * @param first
        */
        public void setFirstName(String first) {
            this.first = first;
        }
        
        /**
        *Sets last name field to last
        * @param last
        */
        public void setLastName(String last) {
            this.last = last;
        }
        
        /**
        *Sets middle initial field to mid
        *@param mid
        */
        public void setMiddle(char mid) {
            this.mid=mid;
        }
        
         /**
        *Gets first name
        * @return first
        */
        public String getFirst() {
            return first;
        }
        
        /**
        *Gets last name
        * @return last
        */
        public String getLast() {
            return last;
        }
        
       /**
        *Gets middle initial
        * @return mid
        */
        public char getMid() {
            return mid;
        }
        
        /**
        *Returns the person’s name in normal order
        */
        public String getNormalOrder() {
            String normalName=first + " " + mid + "." + " " +last;
            return normalName;
        }
        
        /**
        * Returns the person’s name in reverse order
        */
        public String getReverseOrder() {
            String reverseName=last + ", " + first + " " + mid + ".";
            return reverseName;
        }
        
        public String toString() {
            String normalName=first + " " + mid + "." + " " +last;
            return normalName;
        }
        
        public boolean equals(Object o) {
          if (o instanceof Name) {
            Name n = (Name) o;
            return first.equals(n.getFirst()) && last.equals(n.getLast()) && mid==n.getMid(); 
            } else {
                return false;
            }
        }
    }