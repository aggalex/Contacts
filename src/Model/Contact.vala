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

using DataHelper;
using Json;
using JsonHelper;
using FileHelper;

namespace Model {

    public class Contact {

        // Default properties
        public string name;
        public Date? birthday;
        public Date? anniversary;

        public Gdk.Pixbuf? icon;

        public List<DataWithType<string>>? phones;
        public List<DataWithType<string>>? emails;
        public List<DataWithType<Address?>>? addresses;

        public List<string>? notes;
        public List<string>? nicknames;
        public List<string>? websites;

        private string file_name;

        public signal void remove ();

        public Contact (string str) {
            icon = null;
            name = str;
            birthday = null;
            phones = null;
            emails = null;
            addresses = null;
            notes = null;
            nicknames = null;
            websites = null;

            file_name = name;
        }

        public void save () throws IOError, Error {
            var builder = new Json.Builder ();
            builder.begin_object ();

            builder.set_member_name ("name");
            builder.add_string_value (name);

            builder.set_member_name ("icon");
            if (icon != null) {
                try {
                    uint8[] buffer;
                    icon.save_to_buffer (out buffer, "jpeg");
                    builder.add_string_value (Base64.encode (buffer));
                } catch (Error e) {
                    error (e.message);
                }
            } else
                builder.add_string_value ("");

            builder.set_member_name ("birthday");
            builder.add_value (get_date (birthday));

            builder.set_member_name ("anniversary");
            builder.add_value (get_date (anniversary));

            builder.set_member_name ("phones");
            builder.add_value (get_string_list_with_type (phones));

            builder.set_member_name ("emails");
            builder.add_value (get_string_list_with_type (emails));

            builder.set_member_name ("addresses");
            builder.add_value (get_address_list_with_type (addresses));

            builder.set_member_name ("notes");
            builder.add_value (get_string_list (notes));

            builder.set_member_name ("nicknames");
            builder.add_value (get_string_list (nicknames));

            builder.set_member_name ("websites");
            builder.add_value (get_string_list (websites));

            builder.end_object ();

            var generator = new Json.Generator ();
            var root = builder.get_root ();
            generator.set_root (root);

            var output = generator.to_data (null);
            print (output);
            print ("\n");

            if (name != file_name)
                FileHelper.rename (get_filename (file_name), get_filename (name));

            FileHelper.save (get_filename (name), output);
        }

        private string get_filename (string name) {
            return name.replace (" ", "_") + ".json";
        }

    }
}
