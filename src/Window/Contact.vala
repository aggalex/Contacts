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

public errordomain FileChooserError {
    USER_CANCELED
}

namespace Contacts {

    public class Contact : Granite.SettingsPage {

        public signal void name_changed ();
        private signal void changed ();
        private signal void has_icon (bool has);

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

        private Granite.Widgets.Avatar icon = new Granite.Widgets.Avatar.from_file ("../data/icons/64/contacts-avatar-default.svg", 64);

        private bool _saving = true;
        public bool saving {
            get {
                return _saving;
            }
            set {
                _saving = value;
                if (_saving = true)
                    changed ();
            }
        }
        private bool icon_is_set = false;

        public Contact (string name) {
            var user_name = Environment.get_user_name ();
            Object (
                display_widget: new Granite.Widgets.Avatar.from_file ("../data/icons/32/contacts-avatar-default.svg", 32),
                //header: name[0].to_string (),
                title: name
            );
            this.set_name (name.replace(" ", "_") + "_contact");
        }

        construct {
            var icon_button = new Gtk.Button ();
            icon_button.get_style_context ().add_class ("flat");
            icon_button.add (icon);

            var popup = new IconPopup (icon_button);
            has_icon.connect ((has) => {
                popup.delete_button.set_sensitive (has);
                icon_is_set = has;
            });

            popup.change_button.clicked.connect (() => {
                try {
                    get_icon_from_file ();
                } catch {
                    print ("You canceled the operation\n");
                }
            });

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
            delete_button.clicked.connect (() => delete_contact());

            var bottom_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            bottom_box.pack_end (delete_button, false, false, 0);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var content_area = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
            content_area.margin = 12;
            content_area.pack_start (title_box, false, false, 0);
            content_area.pack_start (flow_box, false, false, 0);
            content_area.pack_end (bottom_box, false, false, 0);
            content_area.pack_end (separator, false, false, 0);

            export_to_vcard ();
            add (content_area);
            this.changed.connect (() => {
                if (saving)
                    export_to_vcard ();
            });
        }

        private void delete_contact () {
            var home = Environment.get_home_dir ();
            var titleU = title.replace (" ", "_");
            var path = @"$home/.local/share/contacts/$titleU.vcf";
            File file = File.new_for_path (path);
            file.delete ();
            this.destroy ();
        }

        private void get_icon_from_file () throws FileChooserError {
            var chooser = new Gtk.FileChooserNative (
                "Choose an image",          // name: string
                (Gtk.Window) this.get_toplevel (),       // transient parent: Gtk.Window
                FileChooserAction.OPEN,     // File chooser action: FileChooserAction
                null,                       // Accept label: string
                null                        // Cancel label: string
            );

            var exe_filter = new Gtk.FileFilter ();
            exe_filter.set_name ("Image");
            exe_filter.add_mime_type ("image/*");

            chooser.add_filter (exe_filter);

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                name = chooser.get_filename ();
            } else {
                throw new FileChooserError.USER_CANCELED ("User canceled file choosing");
            }

            chooser.destroy ();
            set_image (name);
            changed ();
        }

        public void set_image (string path) {
            try {
                var image = new Gdk.Pixbuf.from_file_at_scale (path, 64, 64, true);

                if (image.width < image.height) {
                    int y = image.height/2 - image.width/2;
                    image = new Gdk.Pixbuf.subpixbuf (image, 0, y, image.width, image.width);
                } else if (image.width > image.height) {
                    int x = image.width/2 - image.height/2;
                    image = new Gdk.Pixbuf.subpixbuf (image, x, 0, image.height, image.height);
                }

                if (image.width != 64)
                    image = image.scale_simple (64, 64, Gdk.InterpType.HYPER);

                var list_icon = image.scale_simple (32, 32, Gdk.InterpType.HYPER);

                icon.pixbuf = image;
                ((Granite.Widgets.Avatar) display_widget).pixbuf = list_icon;
                has_icon (true);
            } catch (Error e) {
                stderr.printf (e.message);
            }
        }

        public void set_title (string text) {
            try {
                var home = Environment.get_home_dir ();
                var titleU = title.replace (" ", "_");
                var path = @"$home/.local/share/contacts/$titleU.vcf";
                File file = File.new_for_path (path);
                file.delete ();

                title = text;
                name_label.set_text (text);
                changed ();
            } catch (Error e) {
                stderr.printf (e.message + "\n");
            }
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

        public void new_birthday (int day, int month, int year) {
            misc_info.new_entry_calendar (day, month, year, DataTypes.MISC.BIRTHDAY);
        }

        public void new_note (string note) {
            misc_info.new_entry_without_type (note, DataTypes.MISC.NOTES);
        }

        public void new_website (string www) {
            misc_info.new_entry_without_type (www, DataTypes.MISC.WEBSITE);
        }

        public void new_nickname (string name) {
            misc_info.new_entry_without_type (name, DataTypes.MISC.NICKNAME);
        }

        public string get_info_name () {
            return title;
        }

        private string get_vcard_info () {
            var builder = new StringBuilder ("BEGIN:VCARD\nVERSION:3.0\n");

            builder.append ("N;CHARSET=UTF-8:");
            builder.append (title);
            builder.append (";;;;\n");

            builder.append ("FN;CHARSET=UTF-8:");
            builder.append (title);
            builder.append ("\n");

            foreach (DataHolder data in email_info.get_info ()) {
                builder.append ("EMAIL;CHARSET=UTF-8;type=");
                builder.append (data.type.up ());
                builder.append (",INTERNET:");
                builder.append (data.data);
                builder.append ("\n");
            }

            foreach (DataHolder data in phone_info.get_info ()) {
                builder.append ("TEL;TYPE=");
                builder.append (data.type.up ());
                builder.append (":");
                builder.append (data.data);
                builder.append ("\n");
            }

            foreach (DataHolder data in address_info.get_info ()) {
                builder.append ("ADR;CHARSET=UTF-8;TYPE=");
                builder.append (data.type.up ());
                builder.append (":;;");
                builder.append (data.data);
                builder.append ("\n");
            }

            foreach (DataHolder data in misc_info.get_info ()) {
                builder.append (data.data);
                builder.append ("\n");
            }

            if (icon_is_set) {
                uint8[] buffer;
                icon.pixbuf.save_to_buffer (out buffer, "png");
                string buffer_b64 = Base64.encode (buffer);

                builder.append ("PHOTO;ENCODING=b;TYPE=PNG:");
                builder.append (buffer_b64);
                builder.append ("\n");
            }

            builder.append ("END:VCARD");
            return builder.str;
        }

        private bool export_to_vcard () throws IOError {

            var home = Environment.get_home_dir ();
            var titleU = title.replace (" ", "_");
            var path = @"$home/.local/share/contacts/$titleU.vcf";
            var dir_path = @"$home/.local/share/contacts/";

            try {
                File dir = File.new_for_path (dir_path);
                if (!dir.query_exists ())
                    dir.make_directory_with_parents ();
            } catch (Error e) {
                print ("Error: %s\n", e.message);
            }

            try {
                File file = File.new_for_path (path);
                FileOutputStream ostream = file.replace (null, true, FileCreateFlags.PRIVATE);
                var info = this.get_vcard_info () + "\n";
                ostream.write (info.data);
            } catch (Error e) {
                print ("Error: %s\n", e.message);
                return false;
            }

            return true;
        }
    }
}
