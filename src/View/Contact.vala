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

using View.Widgets;
using ViewModel;
using DataHelper;

public errordomain FileChooserError {
    USER_CANCELED
}

namespace View {

    public class Contact : Granite.SettingsPage {

        public ContactHandler handler = new ContactHandler ();

        public signal void delete ();
        public signal void name_changed ();
        public signal void changed ();
        private signal void has_icon (bool has);

        private Granite.Widgets.Avatar icon = new Granite.Widgets.Avatar.from_file ("../data/icons/64/contacts-avatar-default.svg", 64);
        private bool icon_is_set = false;

        private EditableTitle name_label = new EditableTitle ("");

        private InfoSection phone_info = new InfoSection ("Phones");
        private InfoSection email_info = new InfoSection ("Emails");
        private InfoSectionSegmented address_info = new InfoSectionSegmented ("Addresses", {
            "Street",
            "City",
            "State/Province",
            "Zip/Postal Code",
            "Country"
        });
        private InfoSectionMisc misc_info = new InfoSectionMisc ("Miscellaneous");

        public string contact_name {
            get {
                return title;
            }
            set {
                title = value;
                name_label.text = value;
                changed ();
            }
        }

        public Contact (string name = "") {

            Object (
                display_widget: new Granite.Widgets.Avatar.from_file ("../data/icons/32/contacts-avatar-default.svg", 32),
                //header: name[0].to_string (),
                title: name
            );
            this.name = name.replace(" ", "_") + "_contact";
            contact_name = name;
        }

        construct {
            var icon_button = new Gtk.Button ();
            icon_button.get_style_context ().add_class ("flat");
            icon_button.add (icon);

            var popup = new IconPopup (icon_button);
            has_icon.connect ((has) => {
                popup.can_delete = has;
                icon_is_set = has;
            });

            popup.change_image.connect (() => {
                try {
                    get_icon_from_file ();
                } catch {
                    print ("You canceled the operation\n");
                }
            });

            name_label.changed.connect (() => {
                title = name_label.text;
                name_changed ();
                changed ();
            });

            phone_info.changed.connect ((text) => {
                status = text;
                changed ();
            });

            email_info.info_changed.connect ((text) => changed ());

            address_info.info_changed.connect ((text) => changed ());

            misc_info.info_changed.connect ((text) => changed ());

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
            this.add (content_area);

            handler.name = name;
        }

        private void delete_contact () {
            this.delete ();
            this.destroy ();
        }

        private void get_icon_from_file () throws FileChooserError {
            var chooser = new Gtk.FileChooserNative (
                "Choose an image",                      // name: string
                (Gtk.Window) this.get_toplevel (),      // transient parent: Gtk.Window
                FileChooserAction.OPEN,                 // File chooser action: FileChooserAction
                null,                                   // Accept label: string
                null                                    // Cancel label: string
            );

            var filter = new Gtk.FileFilter ();
            filter.set_name ("Image");
            filter.add_mime_type ("image/*");

            chooser.add_filter (filter);

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                name = chooser.get_filename ();
            } else {
                throw new FileChooserError.USER_CANCELED ("User canceled file choosing");
            }

            chooser.destroy ();
            set_image_path (name);
            changed ();
        }

        public void set_image_path (string path) {
            try {
                handler.icon =  new Gdk.Pixbuf.from_file_at_scale (path, 64, 64, true);
                icon.pixbuf = handler.icon;
                ((Granite.Widgets.Avatar) display_widget).pixbuf = handler.icon.scale_simple (32, 32, Gdk.InterpType.HYPER);;
                has_icon (true);
            } catch (Error e) {
                stderr.printf (e.message);
            }
        }

        public void new_phone (string phone, DataHelper.Type type = DataHelper.Type.DEFAULT) {
            handler.add_phone (phone);
            phone_info.new_entry (phone, type.to_string ());
        }

        public void new_email (string email, DataHelper.Type type = DataHelper.Type.DEFAULT) {
            handler.add_email (email);
            email_info.new_entry (email, type.to_string ());
        }

        public void new_address (Address address, DataHelper.Type type = DataHelper.Type.DEFAULT) {
            handler.add_address (address);
            address_info.new_entry (address.to_string_array (), type.to_string ());
        }

        public void new_birthday (uint day, uint month, uint year) {
            handler.birthday.set_day ((DateDay)(uchar) day);
            handler.birthday.set_month ((DateMonth)(uchar) month);
            handler.birthday.set_year ((DateYear)(uchar) year);
            misc_info.new_entry_calendar (day, month, year, DataHelper.Type.BIRTHDAY.to_string ());
        }

        public void new_note (string note) {
            handler.add_note (note);
            misc_info.new_entry_without_type (note, DataHelper.Type.NOTES.to_string ());
        }

        public void new_website (string www) {
            handler.add_website (www);
            misc_info.new_entry_without_type (www, DataHelper.Type.WEBSITE.to_string ());
        }

        public void new_nickname (string name) {
            handler.add_nickname (name);
            misc_info.new_entry_without_type (name, DataHelper.Type.NICKNAME.to_string ());
        }
    }
}
