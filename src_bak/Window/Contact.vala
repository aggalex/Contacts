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

    public class Contact : Granite.SettingsPage {

        public signal void name_changed ();
        public signal void changed ();

        private EditableTitle name_label = new EditableTitle ("");

        private InfoSection phone_info = new InfoSection ("Phones");
        private InfoSection email_info = new InfoSection ("Emails");
        private InfoSection address_info = new InfoSection.with_segmented_entries ("Addresses", {
            "Street",
            "City",
            "State/Province",
            "Zip/Postal Code",
            "Country"
        });
        private InfoSection misc_info = new InfoSection.for_misc ("Miscellaneous");

        public Contact (string name) {
            var user_name = Environment.get_user_name ();
            Object (
                display_widget: new Granite.Widgets.Avatar.from_file ("/var/lib/AccountsService/icons/%s".printf (user_name), 32),
                //header: name[0].to_string (),
                title: name
            );
            this.set_name (name.replace(" ", "_") + "_contact");
        }

        construct {
            var icon_button = new Gtk.Button ();
            icon_button.get_style_context ().add_class ("flat");
            var icon = new Granite.Widgets.Avatar.from_file ("/var/lib/AccountsService/icons/%s".printf ("alex"), 64);
            icon_button.add (icon);

            name_label.set_text (title);
            name_label.changed.connect (() => {
                title = name_label.get_text ();
                name_changed ();
                changed ();
            });

            phone_info.changed.connect ((text) => {
                status = text;
                changed ();
            });

            email_info.info_changed.connect ((text) => {
                changed ();
            });

            address_info.info_changed.connect ((text) => {
                changed ();
            });

            misc_info.info_changed.connect ((text) => {
                changed ();
            });

            var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            title_box.pack_start (icon_button, false, false, 0);
            title_box.pack_start (name_label, false, false, 0);

            var flow_box = new Gtk.FlowBox ();
            flow_box.set_homogeneous (false);
            flow_box.set_orientation (Gtk.Orientation.HORIZONTAL);
            flow_box.add (phone_info);
            flow_box.add (email_info);
            flow_box.add (address_info);
            flow_box.add (misc_info);
            flow_box.set_selection_mode (Gtk.SelectionMode.NONE);
            flow_box.set_activate_on_single_click (false);

            var delete_button = new Gtk.Button ();
            delete_button.set_label ("Delete Contact");
            delete_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            delete_button.clicked.connect (() => this.destroy());

            var bottom_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            bottom_box.pack_end (delete_button, false, false, 0);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var content_area = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
            content_area.margin = 12;
            content_area.pack_start (title_box, false, false, 0);
            content_area.pack_start (flow_box, false, false, 0);
            content_area.pack_end (bottom_box, false, false, 0);
            content_area.pack_end (separator, false, false, 0);

            add (content_area);
        }

        public void set_title (string text) {
            title = text;
            name_label.set_text (text);
        }

        public void new_phone (string phone, string? type) {
            if (type == null) type = DataTypes.DEFAULT;
            phone_info.new_entry (phone, type);
        }

        public void new_email (string email, string? type) {
            if (type == null) type = DataTypes.DEFAULT;
            email_info.new_entry (email, type);
        }

        public void new_address (string[] address, string? type) {
            if (type == null) type = DataTypes.DEFAULT;
            address_info.new_entry_segmented (address, type);
        }

        public void new_birthday (string bday) {
            misc_info.new_entry (bday, DataTypes.MISC.BIRTHDAY);
        }

        public void new_note (string note) {
            misc_info.new_entry (note, DataTypes.MISC.NOTES);
        }

        public void new_website (string www) {
            misc_info.new_entry (www, DataTypes.MISC.WEBSITE);
        }

        public void new_nickname (string name) {
            misc_info.new_entry (name, DataTypes.MISC.NICKNAME);
        }

        public string get_info_name () {
            return title;
        }

        public string get_vcard_info () {
            var builder = new StringBuilder ("BEGIN:VCARD\nVERSION:3.0\n");

            builder.append ("N;CHARSET=UTF-8:");
            builder.append (title);
            builder.append (";;;;\n");

            builder.append ("FN;CHARSET=UTF-8:");
            builder.append (title);
            builder.append ("\n");

            foreach (string data in email_info.get_info ()) {
                var data_array = data.split (" ", 2);
                builder.append ("EMAIL;CHARSET=UTF-8;type=");
                builder.append (data_array[0].up ());
                builder.append (",INTERNET:");
                builder.append (data_array[1]);
                builder.append ("\n");
            }

            foreach (string data in phone_info.get_info ()) {
                var data_array = data.split (" ", 2);
                builder.append ("TEL;TYPE=");
                builder.append (data_array[0].up ());
                builder.append (":");
                builder.append (data_array[1]);
                builder.append ("\n");
            }

            foreach (string data in address_info.get_info_vcard ()) {
                var data_array = data.split (" ", 2);
                builder.append ("ADR;CHARSET=UTF-8;TYPE=");
                builder.append (data_array[0].up ());
                builder.append (":;;");
                builder.append (data_array[1]);
                builder.append ("\n");
            }

            foreach (string data in misc_info.get_info ()) {
                builder.append (data);
                builder.append ("\n");
            }

            builder.append ("END:VCARD");
            return builder.str;
        }
    }
}
