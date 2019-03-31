public class test {
    public static bool verbose = false;

    public static void main (string args[]) {
        Intl.setlocale ();
        print (parse_string ("J'interdis aux marchands de vanter trop leur marchandises. Car ils se font vite p=C3=A9dagogues et t'enseignent comme but ce qui n'est par essence qu'un moyen, et te trompant ainsi sur la route =C3=A0 suivre les voil=C3=A0 bient=C3=B4t qui te d=C3=A9gradent, car si leur musique est vulgaire ils te fabriquent pour te la vendre une =C3=A2me vulgaire.") + "\n");
    }

    public static string parse_string (string str, StringBuilder builder = new StringBuilder ()) {
        if (str[0] == '=') {
            uint8[] chari = new uint8[2];
            var needle = str.slice (1,3).down ();
            print ("NEEDLE: " + needle + "\t");
            for (int i=0; i<2; i++) {
                switch(needle[i]) {
                    case 'a':
                      chari[i] = 10;
                      break;
                    case 'b':
                      chari[i] = 11;
                      break;
                    case 'c':
                      chari[i] = 12;
                      break;
                    case 'd':
                      chari[i] = 13;
                      break;
                    case 'e':
                      chari[i] = 14;
                      break;
                    case 'f':
                      chari[i] = 15;
                      break;
                    default:
                      chari[i] = (uint8) int.parse(needle[i].to_string ());
                      break;
                }
                print ("chari: " + chari[i].to_string () + "\t");
            }
            print (((int) chari[0]).to_string () + "*16 + " + ((int) chari[1]).to_string ());
            chari[0] = chari[0] * 16 + chari[1];
            print (" = " + chari[0].to_string () + "\n");
            builder.append (((char) chari[0]).to_string ());
            return parse_string (str.slice (3, str.length), builder);
        } else if (str == "") {
            return builder.str;
        } else {
            builder.append (str[0].to_string ());
            return parse_string (str.slice (1, str.length), builder);
        }
    }
}
