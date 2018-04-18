 /** An object represents ingredient, bread and price of a sandwich.
 *
*/
 public class Sandwich {
        private String ingredient;
        private String bread;
        private double price;
        
        /**
        *Sets ingredient field to ingredient
        * @param ingredient
        */
        public void setIngredient(String ingredient) {
            this.ingredient = ingredient;
        }
        
        /**
        *Sets bread field to bread
        * @param bread
        */
        public void setBread(String bread) {
            this.bread = bread;
        }
        
        /**
        *Sets price field to price
        *@param price
        */
        public void setPrice(double price) {
            this.price=price;
        }
        
        /**
        *Gets ingredient field
        */
        public String getIngredient() {
            return ingredient;
        }
        
        /**
        *Gets bread field
        */
        public String getBread() {
            return bread;
        }
        
        /**
        *Gets price field
        */
        public double getPrice() {
            return price;
        }
    }