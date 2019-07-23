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

    public class SimpleMenu : Gtk.Popover {

        public signal void poped_down (int index);

        public int length {get; set; default = 0;}

        private ListBox list_box = new Gtk.ListBox ();
        private List<Gtk.Button> list = new List<Gtk.Button> ();

        public SimpleMenu (Gtk.Button? Relative) {
            if (Relative != null) this.set_relative_to (Relative);
            Relative.clicked.connect (() => {
                popup ();
                show_all ();
            });
            this.add (list_box);
            list_box.margin_top = 3;
            list_box.margin_bottom = 3;
        }

        public Gtk.Button append (string text) {
            var index = length++;

            var button = new Gtk.Button ();
            button.set_label (text);
            button.get_style_context ().add_class ("flat");
            button.clicked.connect (() => {
                poped_down (index);
                this.popdown ();
            });
            button.margin = 6;
            button.margin_top = 0;
            button.margin_bottom = 0;
            list_box.add (button);
            list.append (button);

            return button;
        }

        public Gtk.Button? find_by_label (string label) {
            foreach (var button in list) {
                if (button.label == label)
                    return button;
            }
            return null;
        }

        public void clear () {
            list_box.get_children ().foreach ((child) => {
                child.destroy ();
            });
            list = new List<Gtk.Button> ();
        }
    }
}
