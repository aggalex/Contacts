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

    public class Contact : Gtk.ScrolledWindow {

        public unowned ContactHandler _handler;
        public unowned ContactHandler handler {
            get {
                return _handler;
            }
            private set {
                _handler = value;
            }
        }

        public signal void removed ();
        public signal void name_changed ();
        public signal void changed ();
        public signal void show_error (string error);
        private signal void has_icon (bool has);
        private signal void make_bottom_section_unavailable (bool not_available);

        private Granite.Widgets.Avatar icon = new Granite.Widgets.Avatar.from_file (Constants.DATADIR + "/avatars/64/contacts-avatar-default.svg", 64);
        private bool icon_is_set = false;

        private EditableTitle name_label = new EditableTitle ("");

        private InfoSection phone_info = new InfoSection (_("Phones"));
        private InfoSection email_info = new InfoSection (_("Emails"));
        private InfoSectionSegmented address_info = new InfoSectionSegmented (_("Addresses"), {
            _("Street"),
            _("City"),
            _("State/Province"),
            _("Zip/Postal Code"),
            _("Country")
        },
        {
            _("$0, "),
            _("$1, "),
            _("$2, "),
            _("$3, "),
            _("$4")
        });
        private InfoSectionMisc misc_info = new InfoSectionMisc (_("Miscellaneous"));

        private string title { get; set; }

        public new string name {
            get {
                return title;
            }
            set {
                title = value;
                name_label.text = value;
                changed ();
            }
        }

        public Contact.from_handler (ContactHandler handler) {
            this.handler = handler;
            set_connections ();
            initialize ();
        }

        private void initialize () {
            name = handler.name;

            if (handler.phones != null) foreach (var phone in handler.phones)
                phone_info.new_entry (phone.data, phone.type);

            if (handler.emails != null) foreach (var email in handler.emails)
                email_info.new_entry (email.data, email.type);

            if (handler.addresses != null) foreach (var address in handler.addresses)
                address_info.new_entry (address.data.to_string_array (), address.type);

            if (handler.notes != null) foreach (var note in handler.notes)
                misc_info.new_entry_note (note);

            if (handler.websites != null) foreach (var website in handler.websites)
                misc_info.new_entry_website (website);

            if (handler.notes != null) foreach (var nickname in handler.nicknames)
                misc_info.new_entry_nickname (nickname);

            if (handler.birthday != null)
                misc_info.new_entry_birthday (handler.birthday.get_day (), handler.birthday.get_month (), handler.birthday.get_year ());

            if (handler.anniversary != null)
                misc_info.new_entry_anniversary (handler.anniversary.get_day (), handler.anniversary.get_month (), handler.anniversary.get_year ());

            if (handler.icon != null) {
                icon.pixbuf = handler.icon;
                has_icon (true);
            }

            phone_info.can_write = true;
            email_info.can_write = true;
            address_info.can_write = true;
            misc_info.can_write = true;
        }

        construct {
            hscrollbar_policy = Gtk.PolicyType.NEVER;

            var icon_button = new Gtk.Button ();
            icon_button.set_tooltip_text (_("Change the icon"));
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

            var delete_button = new Gtk.Button.with_label (_("Delete Contact"));
            delete_button.set_tooltip_text (_("Delete this contact permanently"));
            delete_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            delete_button.clicked.connect (() => delete_contact());

            var export_button = new Gtk.Button.with_label (_("Export"));
            export_button.set_tooltip_text (_("Export this contact to a file"));
            export_button.clicked.connect (export);

            var save_button = new Gtk.Button.with_label ("Save");   // TODO: Make this redundant
            save_button.clicked.connect (() => {
                try {
                    handler.save();
                } catch (Error e) {
                    show_error (e.message);
                }
            });

            make_bottom_section_unavailable.connect ((not_available) => {
                delete_button.set_sensitive (!not_available);
                export_button.set_sensitive (!not_available);
                save_button.set_sensitive (!not_available);
            });

            var bottom_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            bottom_box.pack_end (delete_button, false, false, 0);
            bottom_box.pack_end (save_button, false, false, 0);
            bottom_box.pack_end (export_button, false, false, 0);

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            var contents = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
            contents.margin = 12;
            contents.pack_start (title_box, false, false, 0);
            contents.pack_start (flow_box, false, false, 0);
            contents.pack_end (bottom_box, false, false, 0);
            contents.pack_end (separator, false, false, 0);

            this.add (contents);
        }

        public void export () {
            var chooser = new Gtk.FileChooserNative (
                _("Where to save exported file"),          // name: string
                (Gtk.Window) this.get_toplevel (),      // transient parent: Gtk.Window
                FileChooserAction.SAVE,                 // File chooser action: FileChooserAction
                null,                                   // Accept label: string
                null                                    // Cancel label: string
            );

            var filter = new Gtk.FileFilter ();
            filter.set_name ("VCard contact file");
            filter.add_mime_type ("text/x-vcard");

            chooser.add_filter (filter);

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                var filename = chooser.get_filename ();
                filename = filename.has_suffix (".vcf")? filename : filename + ".vcf";
                try {
                    FileHelper.save_outside (filename, (handler.export ()));
                } catch (Error e) {
                    show_error (e.message);
                }
            }

            chooser.destroy ();
        }

        private void delete_contact () {
            handler.remove ();
            this.removed ();
        }

        private void get_icon_from_file () throws FileChooserError {
            var chooser = new Gtk.FileChooserNative (
                _("Choose an image"),                      // name: string
                (Gtk.Window) this.get_toplevel (),      // transient parent: Gtk.Window
                FileChooserAction.OPEN,                 // File chooser action: FileChooserAction
                null,                                   // Accept label: string
                null                                    // Cancel label: string
            );

            var filter = new Gtk.FileFilter ();
            filter.set_name ("Image");
            filter.add_mime_type ("image/*");

            chooser.add_filter (filter);

            string filename;
            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                filename = chooser.get_filename ();
            } else {
                throw new FileChooserError.USER_CANCELED ("User canceled file choosing");
            }

            chooser.destroy ();
            set_image_path (filename);
            changed ();
        }

        public void require_name () {
            make_bottom_section_unavailable (true);
            name_label.clicked ();
            name_label.focus_on_entry ();
            name_changed.connect (() => {
                if (name_label.text == "") {
                    name_label.clicked ();
                    return;
                }

                make_bottom_section_unavailable (false);
            });
        }

        public void set_image_path (string path) {
            try {
                handler.icon =  new Gdk.Pixbuf.from_file_at_scale (path, 64, 64, true);
                icon.pixbuf = handler.icon;
                has_icon (true);
            } catch (Error e) {
                error (e.message);
            }
        }

        private void set_connections () {
            name_label.changed.connect (() => {
                title = name_label.text;
                handler.name = name_label.text;
                name_changed ();
                changed ();
            });

            phone_info.handler.add = handler.add_phone;
            phone_info.handler.remove = handler.remove_phone;
            phone_info.handler.change = handler.set_phone;

            email_info.handler.add = handler.add_email;
            email_info.handler.remove = handler.remove_email;
            email_info.handler.change = handler.set_email;

            address_info.handler.add = handler.add_address;
            address_info.handler.remove = handler.remove_address;
            address_info.handler.change = handler.set_address;

            misc_info.handler.add_note = handler.add_note;
            misc_info.handler.remove_note = handler.remove_note;
            misc_info.handler.change_note = handler.set_note;

            misc_info.handler.add_website = handler.add_website;
            misc_info.handler.remove_website = handler.remove_website;
            misc_info.handler.change_website = handler.set_website;

            misc_info.handler.add_nickname = handler.add_nickname;
            misc_info.handler.remove_nickname = handler.remove_nickname;
            misc_info.handler.change_nickname = handler.set_nickname;

            misc_info.handler.set_birthday = (day, month, year) => handler.birthday.set_dmy (day, month, year);
            misc_info.handler.new_birthday = () => handler.birthday = Date ();
            misc_info.handler.clear_birthday = () => handler.birthday = null;


            misc_info.handler.set_anniversary = (day, month, year) => handler.anniversary.set_dmy (day, month, year);
            misc_info.handler.new_anniversary = () => handler.anniversary = Date ();
            misc_info.handler.clear_anniversary = () => handler.anniversary = null;
        }

    }
}
