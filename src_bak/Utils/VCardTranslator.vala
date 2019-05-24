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
    public class VCardTranslator {

        public static void translate (File input, File? output = null) {
            var dis = new DataInputStream (input.read ());
            string line;
            parse_vcard (dis, (output == null)? null : output.replace (null, false, FileCreateFlags.PRIVATE));
        }

        private static void parse_vcard (DataInputStream dis, FileOutputStream? dos = null) {
            var line = dis.read_line_utf8 (null);
            if (line == null)
                return;

            assert (dos != null);

            var section = line.split (":", 2);
            /*if (section.length > 2)
                foreach (var extra_section in section[2:line.length]) {
                    section[1] = section[1] + extra_section;
                    print ("iteration\n");}*/

            section[1] = Decoder.parse_string (section [1]);
            line = @"$(section[0]):$(section[1])";
            assert (line != null);

            line = Replacer.replace (line);
            assert (line != null);

            line = line + "\n";

            print (line);

            if (dos != null)
                dos.write (line.data);
            else
                print (line);

            parse_vcard (dis, dos);
        }

        public static void main (string[] args)
            requires (args.length > 1 && args.length < 4)
            requires (args[1] != null)
        {

            var file_path = args[1].to_string ();

            print (@"$file_path\n");

            var f = File.new_for_commandline_arg (file_path);
            VCardTranslator.translate (f, (args[2] == null)? null : File.new_for_commandline_arg (args[2].to_string ()));
        }
    }
}
