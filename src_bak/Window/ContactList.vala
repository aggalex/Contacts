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

using Granite;
using Granite.Widgets;
using Gtk;

namespace Contacts {
    public class ContactList : Gtk.Paned {

        private Gtk.Stack contact_stack = new Gtk.Stack ();
        private Sidebar sidebar;

        private bool reading = false;

        construct {
            assert (Thread.supported ());

            contact_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);

            sidebar = new Sidebar (contact_stack);

            add (sidebar);
            add (contact_stack);
        }

        public void parse_local_vcard_threaded () {
            try {
                ThreadFunc<bool> append_local_contacts = () => {
                    var list = parse_local_vcard ();
                    list.foreach ((contact) =>
                        contact_stack.add_named (contact, "contact"));
                        contact_stack.show_all ();
                    return true;
                };
                Thread thread = new Thread<bool> ("local_vcard", append_local_contacts);
            } catch (ThreadError e) {
                assert (false);
            }
        }

        private List<Contact>? parse_local_vcard () {
            var home = Environment.get_home_dir ();

            try {
                File file = File.new_for_path (home + "/.local/share/contacts/local.vcf");
                var dis = new DataInputStream (file.read ());
                reading = true;
                var list = new List<Contact> ();

                var line = dis.read_line_utf8 (null);
                while (line != null) {
                    var next_line = dis.read_line_utf8 (null);
                    if (line == "BEGIN:VCARD" && next_line == "VERSION:3.0") {
                        var contact = new Contact ("Alex Angelou");

                        while ((line = dis.read_line_utf8 (null)) != "END:VCARD") {

                            if (line.has_prefix ("FN")) {
                                var needle = parse_needle (line);
                                assert (needle != null);

                                contact.set_title (needle);

                            } else if (line.has_prefix ("EMAIL")) {

                                var type = parse_type (line);
                                var needle = parse_needle (line);

                                contact.new_email (needle, type);

                            } else if (line.has_prefix ("TEL")) {

                                var type = parse_type (line);
                                var needle = parse_needle (line);

                                contact.new_phone (needle, type);

                            } else if (line.has_prefix ("ADR")) {

                                var type = parse_type (line);
                                var starting_needle = parse_needle (line);

                                string[] needle = starting_needle.split (";", 0);

                                if (needle.length >= 8)
                                    contact.new_address ({needle[3], needle[4], needle[5], needle[6], needle[7]}, type);
                            } else if (line.has_prefix ("NOTE")) {

                                var needle = parse_needle (line);
                                contact.new_note (needle);

                            } else if (line.has_prefix ("URL")) {

                                var needle = parse_needle (line);
                                contact.new_website (needle);

                            }
                        }
                        contact.name_changed.connect (() => {
                            sidebar.on_sidebar_changed ();
                        });

                        contact.changed.connect (() => {
                            export_to_vcard ();
                        });

                        list.append (contact);

                    }
                    line = dis.read_line_utf8 ();
                }
                reading = false;
                return list;
            } catch (Error e) {
                return null;
            }
        }

        private string parse_type (string line) {
            var type_start = line.up ().index_of ("TYPE=");
            var type_needle = line.slice (type_start+5, type_start+9).compress ();
            string type = "";

            switch (type_needle) {
                case "HOME":
                    type = DataTypes.HOME;
                    break;
                case "WORK":
                    type = DataTypes.WORK;
                    break;
                default:
                    type = DataTypes.OTHER;
                    break;
            }

            return type;
        }

        private string parse_needle (string line) {
            int start = 0;
            do {
                start = line.last_index_of_char (':', start);
            } while (line[start-1] == '\\');
            string needle = line.slice (start+1, line.length).compress ();

            return needle;
        }

        public bool export_to_vcard () {
            var home = Environment.get_home_dir ();

            File file = File.new_for_path (home + "/.local/share/contacts/local.vcf");
            File dir = File.new_for_path (home + "/.local/share/contacts");

            if (reading) {
                return false;
            }

            try {
                if (!dir.query_exists ())
                    dir.make_directory_with_parents ();
            } catch (Error e) {
                print ("Error: %s\n", e.message);
            }

            try {
                FileOutputStream ostream = file.replace (null, true,FileCreateFlags.PRIVATE);

                foreach (Gtk.Widget cont in contact_stack.get_children ()) {
                    var info = ((Contact) cont).get_vcard_info () + "\n";
                    ostream.write (info.data);
                }

            } catch (Error e) {
                print ("Error: %s\n", e.message);
                return false;
            }
            return true;
        }

        public void add_contact (string name) {
            var contact = new Contact (name);
            contact.name_changed.connect (() => {
                sidebar.on_sidebar_changed ();
            });

            contact.changed.connect (() => {
                export_to_vcard ();
            });

            contact_stack.add_named (contact, name.replace(" ", "_") + "_contact");
            export_to_vcard ();
            contact_stack.show_all ();
        }

    }
}
