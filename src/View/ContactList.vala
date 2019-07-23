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

namespace View {
    public class ContactList : Gtk.Paned {

        private ContactListHandler handler = new ContactListHandler ();

        private LightStack contact_stack;
        private Sidebar sidebar;
        private Revealer sidebar_revealer = new Gtk.Revealer ();

        private ErrorBar error_bar = new ErrorBar ();

        public bool show_sidebar {
            get {
                return sidebar_revealer.child_revealed;
            }
            set {
                sidebar_revealer.set_reveal_child (value);
            }
        }

        construct {
            sidebar = new Sidebar (handler);

            var welcome = new Granite.Widgets.Welcome (_("No Contacts"), _("Your contact list is empty."));
            welcome.append ("address-book-new", _("New Contact"), _("Create a new contact"));
            welcome.append ("document-import", _("Import Contacts"), _("Import contacts from external file"));
            welcome.get_style_context ().add_class ("normal-background");

            var welcome_button = welcome.get_button_from_index (0);

            welcome.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        add_empty_contact ();
                        break;
                    case 1:
                        import_vcard ();
                        break;
                }
            });

            //right

            error_bar.show_all ();

            contact_stack = sidebar.stack;
            contact_stack.transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN;
            contact_stack.default_widget = welcome;
            contact_stack.changed.connect (() => {
                var contact = contact_stack.child as Contact;
                if (contact != null)
                    contact.show_error.connect (show_error);
            });

            var contact_stack_box = new Box (Orientation.VERTICAL, 0);
            contact_stack_box.pack_start (error_bar, false, false, 0);
            contact_stack_box.pack_end (contact_stack, true, true, 0);

            //left

            var separator = new Separator (Orientation.HORIZONTAL);
            separator.margin_start = 6;
            separator.margin_end = 6;

            var export_button = new Gtk.Button.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
            export_button.set_tooltip_text (_("Export all contacts to a file"));
            export_button.get_style_context ().add_class (STYLE_CLASS_FLAT);
            export_button.clicked.connect (export);

            var import_button = new Gtk.Button.from_icon_name ("document-import", Gtk.IconSize.LARGE_TOOLBAR);
            import_button.set_tooltip_text (_("Import contacts from a file"));
            import_button.get_style_context ().add_class (STYLE_CLASS_FLAT);

            var import_menu = new SimpleMenu (import_button);
            var vcard_button = import_menu.append ("From vcard file");
            vcard_button.clicked.connect (import_vcard);
            var system_button = import_menu.append ("From system & online accounts");
            system_button.clicked.connect (import_system);

            var action_box = new Gtk.Box (Orientation.HORIZONTAL, 6);
            action_box.margin = 6;
            action_box.margin_top = 8;
            action_box.margin_bottom = 8;
            action_box.pack_start (import_button, true, true, 0);
            action_box.pack_start (export_button, true, true, 0);

            var sidebar_box = new Gtk.Box (Orientation.VERTICAL, 0);
            sidebar_box.get_style_context ().add_class ("white-background");
            sidebar_box.pack_start (sidebar, true, true, 0);
            sidebar_box.pack_end (action_box, false, false, 0);
            sidebar_box.pack_end (separator, false, false, 0);

            sidebar_revealer.transition_type = RevealerTransitionType.SLIDE_LEFT;
            sidebar_revealer.reveal_child = false;
            sidebar_revealer.add (sidebar_box);
            sidebar_revealer.show_all ();

            add1 (sidebar_revealer);
            add2 (contact_stack_box);
        }

        public void initialize () {
            handler.changed.connect (() => {
                if (handler.length != 0) {
                    sidebar_revealer.set_reveal_child (true);
                    if (!(contact_stack.child is Contact)) sidebar.select_row (0);
                } else {
                    sidebar_revealer.set_reveal_child (false);
                }
            });

            try {
                handler.initialize ();
            } catch (Error e) {
                show_error (e.message);
            }

            if (handler.length != 0) sidebar_revealer.reveal_child = true;
            sidebar.select_row (0);
        }

        public void add_contact (string name) {
            handler.add_contact (name);
            sidebar_revealer.set_reveal_child (true);
        }

        public void add_empty_contact () {
            sidebar.add_empty_contact ();
        }

        public void import_vcard () {
            var chooser = new Gtk.FileChooserNative (
                _("Select the contact file to import"), // name: string
                (Gtk.Window) this.get_toplevel (),      // transient parent: Gtk.Window
                FileChooserAction.OPEN,                 // File chooser action: FileChooserAction
                null,                                   // Accept label: string
                null                                    // Cancel label: string
            );

            var filter = new Gtk.FileFilter ();
            filter.set_name (_("VCard contact file"));
            filter.add_mime_type ("text/x-vcard");

            chooser.add_filter (filter);

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                var filename = chooser.get_filename ();
                try {
                    handler.import (filename);
                } catch (Error e) {
                    show_error (e.message);
                }
            }

            chooser.destroy ();
        }

        public void import_system () {
            try {
                handler.import_from_folks ();
            } catch (Error e) {
                show_error (e.message);
            }
        }

        public void export () {
            var chooser = new Gtk.FileChooserNative (
                _("Where to save exported file"),       // name: string
                (Gtk.Window) this.get_toplevel (),      // transient parent: Gtk.Window
                FileChooserAction.SAVE,                 // File chooser action: FileChooserAction
                null,                                   // Accept label: string
                null                                    // Cancel label: string
            );

            var filter = new Gtk.FileFilter ();
            filter.set_name (_("VCard contact file"));
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

        public void show_error (string error_message) {
            error_bar.show_message (error_message);
        }

        public void search (string needle) {
            if (needle == "") {
                sidebar.show_all_rows ();
                return;
            }

            var indexes = handler.search (needle); 

            if (indexes.length () == 0) {
                sidebar.hide_all_rows ();
                return;
            } else {
                sidebar.show_all_rows ();
            }

            sidebar.hide_all_rows ();

            foreach (var index in indexes)
                sidebar.show_row (index);
        }
 
    }
}
