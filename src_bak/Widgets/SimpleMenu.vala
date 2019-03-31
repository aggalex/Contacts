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

    public class SimpleMenu : Gtk.Popover {

        public signal void poped_down (string text);
        private ListBox list_box = new Gtk.ListBox ();

        public SimpleMenu (Gtk.Button? Relative) {
            if (Relative != null) this.set_relative_to (Relative);
            Relative.clicked.connect (() => {
                popup ();
                show_all ();
            });
            this.add (list_box);
        }

        public void append (string text) {
            var button = new Gtk.Button ();
            button.set_label (text);
            button.get_style_context ().add_class ("flat");
            button.clicked.connect (() => {
                poped_down (button.get_label ());
                this.popdown ();
            });
            list_box.add (button);
        }

        public void clear () {
            list_box.get_children ().foreach ((child) => {
                child.destroy ();
            });
        }
    }
}
