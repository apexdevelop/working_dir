import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.util.Stack;

class Bracket {
    Bracket(char type, int position) {
        this.type = type;
        this.position = position;
    }

    boolean Match(char c) {
        if (this.type == '[' && c == ']')
            return true;
        if (this.type == '{' && c == '}')
            return true;
        if (this.type == '(' && c == ')')
            return true;
        return false;
    }

    char type;
    int position;
}

class check_brackets {
    public static void main(String[] args) throws IOException {
        InputStreamReader input_stream = new InputStreamReader(System.in);
        BufferedReader reader = new BufferedReader(input_stream);
        String text = reader.readLine();
        int err_pos = 0;
        Stack<Bracket> opening_brackets_stack = new Stack<Bracket>();
        for (int position = 0; position < text.length(); ++position) {
            char next = text.charAt(position);

            if (next == '(' || next == '[' || next == '{') {
                // Process opening bracket, write your code here
                Bracket bracket = new Bracket(next, position + 1);
                opening_brackets_stack.push(bracket);
            }

            if (next == ')' || next == ']' || next == '}') {
                // Process closing bracket, write your code here
                if (opening_brackets_stack.empty()) {
                    // This is bad, because the closing bracket cannot occur before the opening bracket.
                    err_pos = position + 1;
                    break;
                } else {
                    Bracket top = opening_brackets_stack.pop();

                    if (!top.Match(next)) {
                        err_pos = position + 1;
                        break;
                    }
                }
            }
        }
        
        //if (err_pos == 0 && opening_brackets_stack.size()>1) {
        //    err_pos = opening_brackets_stack.peek().position + 1;
        //}
    
        // Printing answer, write your code here
        if(err_pos==0 && opening_brackets_stack.empty())
			System.out.println("Success");
		else {
			if(err_pos == 0) {
				while(opening_brackets_stack.size()>1)
					opening_brackets_stack.pop();
				err_pos = opening_brackets_stack.peek().position;
			}
			System.out.println(err_pos);
			//System.out.println(opening_brackets_stack.peek().position);
			//System.out.println(opening_brackets_stack.size())
			
		}
    }
}
