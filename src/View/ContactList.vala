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

            var welcome = new Granite.Widgets.Welcome ("No contacts", "Your contact list is empty.");
            welcome.append ("address-book-new", "New contact", "Create a new contact");
            welcome.get_style_context ().add_class ("normal-background");

            var welcome_button = welcome.get_button_from_index (0);

            var popover = new Widgets.Popover (welcome_button);
            popover.set_position (PositionType.BOTTOM);
            popover.activated.connect (() => {
                add_contact (popover.text);
            });

            welcome.activated.connect ((index) => {
                popover.popup ();
                popover.show_all ();
            });

            contact_stack = sidebar.stack;
            contact_stack.transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN;
            contact_stack.default_widget = welcome;

            // TODO: Add export button to the bottom of the contact page.

            var separator = new Separator (Orientation.HORIZONTAL);
            separator.margin_start = 6;
            separator.margin_end = 6;

            var export_button = new Gtk.Button.from_icon_name ("document-export", Gtk.IconSize.LARGE_TOOLBAR);
            export_button.get_style_context ().add_class (STYLE_CLASS_FLAT);
            export_button.clicked.connect (export);

            var import_button = new Gtk.Button.from_icon_name ("document-import", Gtk.IconSize.LARGE_TOOLBAR);
            import_button.get_style_context ().add_class (STYLE_CLASS_FLAT);
            import_button.clicked.connect (import);

            var action_box = new Gtk.Box (Orientation.HORIZONTAL, 6);
            action_box.margin = 6;
            action_box.margin_top = 8;
            action_box.margin_bottom = 8;
            action_box.pack_start (export_button, true, true, 0);
            action_box.pack_start (import_button, true, true, 0);

            var sidebar_box = new Gtk.Box (Orientation.VERTICAL, 0);
            sidebar_box.get_style_context ().add_class ("white-background");
            sidebar_box.pack_start (sidebar, true, true, 0);
            sidebar_box.pack_end (action_box, false, false, 0);
            sidebar_box.pack_end (separator, false, false, 0);

            sidebar_revealer.transition_type = RevealerTransitionType.SLIDE_LEFT;
            sidebar_revealer.reveal_child = false;
            sidebar_revealer.add (sidebar_box);
            sidebar_revealer.show_all ();

            handler.changed.connect (() => {
                if (handler.length == 0) {
                    show_sidebar = false;
                } else {
                    show_sidebar = true;
                }
            });

            add1 (sidebar_revealer);
            add2 (contact_stack);
        }

        public void initialize () {
            handler.initialize ();
            if (handler.length != 0) sidebar_revealer.reveal_child = true;
        }

        public void add_contact (string name) {
            handler.add_contact (name);
            sidebar_revealer.set_reveal_child (true);
        }

        public void import () {
            var chooser = new Gtk.FileChooserNative (
                "Select the contact file to import",    // name: string
                (Gtk.Window) this.get_toplevel (),      // transient parent: Gtk.Window
                FileChooserAction.OPEN,                 // File chooser action: FileChooserAction
                null,                                   // Accept label: string
                null                                    // Cancel label: string
            );

            var filter = new Gtk.FileFilter ();
            filter.set_name ("VCard contact file");
            filter.add_mime_type ("text/x-vcard");

            chooser.add_filter (filter);

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                var filename = chooser.get_filename ();
                handler.import (filename);
            }

            chooser.destroy ();
        }

        public void export () {
            var chooser = new Gtk.FileChooserNative (
                "Where to save exported file",          // name: string
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
                FileHelper.save_outside (filename, (handler.export ()));
            }

            chooser.destroy ();
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
