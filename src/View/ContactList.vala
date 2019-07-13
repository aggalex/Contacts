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

namespace  View {
    public class ContactList : Gtk.Paned {

        private Gtk.Stack contact_stack = new Gtk.Stack ();
        private Sidebar sidebar;

        private ContactListHandler handler = new ContactListHandler ();

        construct {
            // foreach (var contact_handler in handler)
            //     add_contact_with_data (contact_handler);

            handler.new_contact.connect (add_contact_with_data);

            contact_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);

            sidebar = new Sidebar (contact_stack);

            handler.initialize ();

            add1 (sidebar);
            add2 (contact_stack);
        }

        public void add_contact (string name) {
            var contact = new Contact (name);
            initialize_contact (contact);
        }

        public void add_contact_with_data (ContactHandler handler) {
            var contact = new Contact.from_handler (handler);
            initialize_contact (contact);
        }

        private void initialize_contact (Contact contact) {
            contact.name_changed.connect (() => {
                sidebar.on_sidebar_changed ();
            });

            handler.add_contact (contact.name);

            var index = handler.search (contact.name).first ().data;

            contact_stack.add (contact);
            contact_stack.child_set_property (contact, "position", index);
            contact_stack.set_visible_child (contact);
            contact_stack.show_all ();
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
