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

        private LightStack contact_stack;
        private Sidebar sidebar;

        private ContactListHandler handler = new ContactListHandler ();

        construct {
            sidebar = new Sidebar (handler);
            contact_stack = sidebar.stack;

            contact_stack.transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN;

            add1 (sidebar);
            add2 (contact_stack);
        }

        public void initialize () {
            handler.initialize ();
        }

        public void add_contact (string name) {
            handler.add_contact (name);
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
