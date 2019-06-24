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

        private ContactListHandler contact_list_handler = new ContactListHandler ();

        construct {
            contact_stack.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);

            sidebar = new Sidebar (contact_stack);

            add1 (sidebar);
            add2 (contact_stack);
        }

        public void new_contact (string name) {
            var contact = new Contact (name);
            contact.name_changed.connect (() => {
                sidebar.on_sidebar_changed ();
            });

            contact_list_handler.add_contact (name);

            contact_stack.add_named (contact, name.replace(" ", "_") + "_contact");
            contact_stack.set_visible_child (contact);
            contact_stack.show_all ();
        }
    }
}
