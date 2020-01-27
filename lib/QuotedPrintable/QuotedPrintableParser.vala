/*
* Copyright (c) {{yearrange}} Alex Angelou ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNEs FOR A PARTICULAR PURPOsE.  see the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free software Foundation, Inc., 51 Franklin street, Fifth Floor,
* Boston, MA 02110-1301 UsA
*
* Authored by: Alex Angelou <>
*/

namespace QuotedPrintableHelper {

    private string parse_quoted_printable_line (owned string line = "") {
        Regex quoted;
        Regex quoted2;
        try {
            quoted = new Regex (".*(;CHARSET=.+;ENCODING=QUOTED-PRINTABLE)");
            quoted2 = new Regex ("^=[0-9A-F]{2}");
        } catch (RegexError e) {
            assert_not_reached ();
        }
        bool pass = quoted.match (line);

        if (pass) {
            var needle = line[line.last_index_of_char (':'):line.length];
            var line_init = line[0:line.last_index_of_char (':')+1];
            return line_init + parse_string (needle);
        }
        if (pass || quoted2.match (line))
            return parse_string (line);
        return line;
    }

    private string parse_string (string str, StringBuilder builder = new StringBuilder ()) {
        if (str == "") {
            return builder.str;
        } else if (str[0] != '=') {
            builder.append (str[0].to_string ());
            return parse_string (str.slice (1, str.length), builder);
        }

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
    }
}
