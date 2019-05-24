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
    public class EditableTitle : Gtk.Stack {

        public signal void changed ();

        private Gtk.Label label = new Gtk.Label ("");
        private Gtk.Entry entry = new Gtk.Entry ();

        public EditableTitle (string? text) {

            if (text == null) {
                text = "";
            }

            label.set_text (text);
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

            var label_button = new Gtk.Button ();
            label_button.get_style_context ().add_class ("flat");
            label_button.add (label);

            var label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            label_box.pack_start (label_button, true, false, 0);

            entry.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

            entry.set_text(text);

            var entry_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            entry_box.pack_start (entry, true, false, 0);

            this.add_named (label_box, "label");
            this.add_named (entry_box, "entry");

            label_button.clicked.connect (() => {
                this.set_visible_child_name ("entry");
            });

            entry.activate.connect (() => {
                this.set_visible_child_name ("label");
                label.set_text (entry.get_text ());
                changed ();
            });

            this.show_all();
            this.set_visible_child_name ("label");
            this.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
        }

        public void set_text (string text) {
            label.set_text (text);
            entry.set_text (text);
            changed ();
        }

        public string get_text () {
            return entry.get_text ();
        }
    }
}
