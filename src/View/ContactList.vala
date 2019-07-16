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

            sidebar_revealer.transition_type = RevealerTransitionType.SLIDE_LEFT;
            sidebar_revealer.reveal_child = false;
            sidebar_revealer.add (sidebar);
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
