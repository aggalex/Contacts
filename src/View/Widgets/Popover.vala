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

namespace View.Widgets {
    public class Popover : Gtk.Popover {

        public signal void activated ();

        private string _text;
        public string text {
            get {
                return _text;
            }
        }

        public Popover (Gtk.Widget relative_widget) {
            var name_entry = new Gtk.Entry ();

            name_entry.margin = 12;

            this.add (name_entry);

            name_entry.activate.connect (() => {
                _text = name_entry.get_text ();
                activated ();
                this.popdown ();
            });

            this.set_relative_to (relative_widget);
        }

    }
}
