import java.io.*;

public class Register {

	public static void main(String args[]) {


		System.out.println("Enter Your Meetup API key to activate public signing: ");
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		String key = null;

      		try {
         		key = br.readLine();
      		} catch (IOException ioe) {
         		System.out.println("IO error trying to read your key");
         		System.exit(1);
      		}

		System.out.println("Your key is: "+key);

		FileOutputStream out; // declare a file output object
       		PrintStream p; // declare a print stream object

        	try {
             		out = new FileOutputStream("src/meetupnow/RegDev.java");
             		p = new PrintStream( out );
             		p.println ("package meetupnow;");
			p.println ("public class RegDev extends SignedURLGen{");
			p.println ("public RegDev() {");
			p.println ("super(\""+key+"\");");
			p.println ("}");
			p.println ("}");
             		p.close();
       		}catch (Exception e){
                        System.err.println ("Error writing to file");
                }

	}

}
