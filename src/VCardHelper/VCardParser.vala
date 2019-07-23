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

using Model;
using DataHelper;
using QuotedPrintableHelper;

namespace VCardHelper {

    public List<Contact> parse (string path) throws Error, IOError {
        File file = File.new_for_path (path);
        var dis = new DataInputStream (file.read ());
        var list = new List<Contact> ();
        var line = dis.read_line_utf8 ();
        var next_line = dis.read_line_utf8 ();
        while (line != null && next_line != null) {
            if (line != "BEGIN:VCARD" && !next_line.has_prefix ("VERSION:")) {
                line = next_line;
                next_line = dis.read_line_utf8 ();
                continue;
            }

            var contact = new Contact ("");

            while ((line = dis.read_line_utf8(null)) != null){
                line = parse_quoted_printable_line (line);
                line = line.strip ();
                if (line == "END:VCARD") break;
                set_contact_info(line, contact); // TODO: Make things break less. (BDAY 00000000 broke things (segfault))
            }

            if (contact.name == "") continue;

            list.append (contact);
        }
        return list;
    }

    private DataHelper.Type parse_type (string line) {
        var type_start = line.up ().index_of ("TYPE=");
        var type_needle = line.slice (type_start+5, type_start+9).compress ();
        DataHelper.Type type = DataHelper.Type.DEFAULT;

        switch (type_needle) {
            case "HOME":
                type = DataHelper.Type.HOME;
                break;
            case "WORK":
                type = DataHelper.Type.WORK;
                break;
            default:
                type = DataHelper.Type.OTHER;
                break;
        }

        return type;
    }

    private void set_contact_info(string line, Contact contact) {
        if (line.has_prefix ("FN")){

            var needle = parse_needle (line);
            assert (needle != null);

            contact.name = needle;
            return;
       }
       if (line.has_prefix ("EMAIL")) {

            var type = parse_type (line);
            var needle = parse_needle (line);

            if (contact.emails == null) contact.emails = new List<DataWithType<string>> ();

            contact.emails.append (new DataWithType<string> (needle, type));
            return;

        }
        if (line.has_prefix ("TEL")) {

            var type = parse_type (line);
            var needle = parse_needle (line);

            if (contact.phones == null) contact.phones = new List<DataWithType<string>> ();

            contact.phones.append (new DataWithType<string> (needle, type));
            return;

        }
        if (line.has_prefix ("ADR")) {

            var type = parse_type (line);
            var starting_needle = parse_needle (line);

            string[] needle = starting_needle.split (";", 0);

            if (contact.addresses == null) contact.addresses = new List<DataWithType<Address?>> ();

            var address = Address.parse (needle [2:needle.length]);

            contact.addresses.append (new DataWithType<Address?> (address, type));

            return;
        }
        if (line.has_prefix ("NOTE")) {

            var needle = parse_needle (line);

            if (contact.notes == null) contact.notes = new List<string> ();
            contact.notes.append (needle);

            return;
        }
        if (line.has_prefix ("URL")) {

            var needle = parse_needle (line);

            if (contact.websites == null) contact.websites = new List<string> ();
            contact.websites.append (needle);

            return;
        }
        if (line.has_prefix ("NICKNAME")) {

            var needle = parse_needle (line);

            if (contact.nicknames == null) contact.nicknames = new List<string> ();
            contact.nicknames.append (needle);

            return;
        }
        if (line.has_prefix ("X-ANDROID-CUSTOM:vnd.android.cursor.item/nickname;")) {
            var andro_needle = parse_needle (line).split (";");

            if (contact.nicknames == null) contact.nicknames = new List<string> ();
            contact.nicknames.append (andro_needle[1]);

            return;
        }
        if (line.has_prefix ("BDAY")) {

            var needle = parse_needle (line);

            var year = int.parse (needle.substring (0, 4));
            var month = int.parse (needle.substring (4, 2));
            var day = int.parse (needle.substring (6, 2));

            var bday = Date ();
            bday.set_dmy ((DateDay) day, month, (DateYear) year);

            contact.birthday = bday;

            return;
        }
        if (line.has_prefix ("X-ANDROID-CUSTOM:vnd.android.cursor.item/contact_event;")) {
            var andro_needle = parse_needle (line).split (";");

            var needle = andro_needle[1].split ("/");

            var year = int.parse (needle[0]);
            var month = int.parse (needle[1]);
            var day = int.parse (needle[2]);

            var bday = Date ();
            bday.set_dmy ((DateDay) day, month, (DateYear) year);

            contact.birthday = bday;
            return;
        }
        if (line.has_prefix ("ANNIVERSARY")) {

            var needle = parse_needle (line);

            var year = int.parse (needle.substring (0, 4));
            var month = int.parse (needle.substring (4, 2));
            var day = int.parse (needle.substring (6, 2));

            var anniv = Date ();
            anniv.set_dmy ((DateDay) day, month, (DateYear) year);

            contact.anniversary = anniv;

            return;
        }
        if (line.has_prefix ("PHOTO")) {

            // var needle = parse_needle (line);
            // File image_file = File.new_for_path (home + "/.local/share/contacts/image.png");
            // var os = image_file.replace (null, false, FileCreateFlags.PRIVATE);
            // os.write (Base64.decode (needle));

            // contact.set_image (home + "/.local/share/contacts/image.png");

            return;
        }
        return;
    }

    private string parse_needle (string line) {
        int start = 0;
        do {
            start = line.last_index_of_char (':', start);
        } while (line[start-1] == '\\');
        string needle = line.slice (start+1, line.length).compress ();

        return needle;
    }

}
