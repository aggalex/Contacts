/*
* Copyright (c) {{yearrange}} Alex ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alex Angelou <>
*/
   

namespace Contacts {

    protected struct Substitutor {
        Regex regex;
        string new_string;
    }

    public class Replacer {

        private static List<Substitutor?> replace_filters = new List<Substitutor?> ();

        private static void initialize () {
            replace_filters.append ({
                new Regex ("^VERSION:.*"),
                "VERSION:3.0"
            });
            replace_filters.append ({
                new Regex ("^PHOTO;ENCODING=BASE64;JPEG:"),
                "PHOTO;ENCODING=b;TYPE=JPEG:"
            });
            replace_filters.append ({
                new Regex ("^X-ANDROID-CUSTOM:vnd.android.cursor.item/nickname;([^;]+);.*"),
                "NICKNAME:%1"
            });
            replace_filters.append ({
                new Regex (";PREF([;:])"),
                ";TYPE=PREF%2"
            });
            replace_filters.append ({
                new Regex ("^X-ICQ(;?.*):(.+)"),
                "IMPP%1:icq:%2"
            });
            var temp = new Regex ("^(TEL|EMAIL|ADR|IMPP);([^;:=]+[;:])");
            replace_filters.append ({
                temp,
                //type_lc (temp, line)
                "%1;TYPE=%2"
            });
            replace_filters.append ({
                new Regex ("^EMAIL:([^@]+@jabber.*)"),
                "IMPP;xmpp:%1"
            });
        }

        /*private string type_lc (Regex regex, string line) {
            MatchInfo match_info = new MatchInfo ();
            regex.match (line, out match_info);
            return match_info.fetch (1) + ";TYPE=" + match_info.fetch (2).down ();
        }*/

        public static string replace (string line) {
            if (replace_filters.length () == 0)
                initialize ();
            string output = line;
            foreach (var filter in replace_filters) {
                MatchInfo match_info;
                if (filter.regex.match (line, 0, out match_info)) {
                    output = filter.regex.replace (line, line.length, 0, filter.new_string);
                    var match_replacements = match_info.fetch_all ();
                    for (int i=1; i<match_replacements.length; i++) {
                        print (@"COUNT: %$i\n");
                        print (@"REPLACE: $(match_replacements[i])\n");
                        output = output.replace (@"%$i", match_replacements[i]);
                    }
                    print (@"MATCH COUNT:  $(match_replacements.length)\n");
                    //print (@"Inside replacer: $line ++++++++++++++++++++++++++++++++++++\n");
                }
            }
            output = output.replace (";ENCODING=QUOTED-PRINTABLE", "");
            return output;
        }
    }
}
