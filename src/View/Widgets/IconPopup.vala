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

    public class IconPopup : Gtk.Popover {

        public signal void poped_down (string text);
        public signal void change_image ();
        public signal void remove_image ();
        public Gtk.Button delete_button = new Gtk.Button ();

        public bool can_delete {
            get {
                return delete_button.sensitive;
            }
            set {
                delete_button.sensitive = value;
            }
        }

        public IconPopup (Gtk.Button? relative_button) {
            if (relative_button != null) this.set_relative_to (relative_button);
            relative_button.clicked.connect (() => {
                popup ();
                show_all ();
            });

            var change_button = new Gtk.Button ();
            change_button.set_label (_("Set from File…"));
            change_button.get_style_context ().add_class ("suggested-action");
            change_button.clicked.connect (() => {
                this.popdown ();
                change_image ();
            });

            delete_button.set_label (_("Delete"));
            delete_button.get_style_context ().add_class ("destructive-action");
            delete_button.set_sensitive (false);
            delete_button.clicked.connect (() => {
                this.popdown ();
                remove_image ();
            });

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
            box.margin = 6;
            box.pack_start (delete_button, true, true, 0);
            box.pack_start (change_button, true, true, 0);

            this.add (box);
        }
    }
}
