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
    public class EditableTitle : Gtk.Stack {

        public signal void changed ();

        private Gtk.Label label = new Gtk.Label ("");
        private Gtk.Entry entry = new Gtk.Entry ();

        private Gtk.Button label_button = new Gtk.Button ();

        private bool requires_name = false;

        public string text {
            get {
                return entry.get_text ();
            }

            set {
                label.set_text (value);
                entry.set_text (value);
                changed ();
            }
        }

        public EditableTitle (string? text) {

            if (text == null) {
                text = "";
            }

            label.set_text (text);
            entry.set_text (text);
        }

        public void clicked () {
            label_button.clicked ();
        }

        public void focus_on_entry () {
            entry.grab_focus ();
        }

        public void require_name () {
            clicked ();
            focus_on_entry ();
            requires_name = true;
        }

        construct {
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

            label_button.set_tooltip_text (_("Edit the name"));
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

            entry.focus_out_event.connect (() => {
                if (requires_name) {
                    print (@"ENTRY TEXT: $(entry.text.strip ())\n");
                    if (entry.text.strip () == "") return true;

                    entry.activate ();
                    return true;
                }

                this.set_visible_child_name ("label");
                entry.text = label.label;
            });

            entry.activate.connect (() => {
                if (entry.text.strip () == "") return;

                requires_name = false;

                text = entry.text;
                this.set_visible_child_name ("label");
            });

            entry.key_release_event.connect ((key) => {
                if (Gdk.keyval_name (key.keyval) == "Escape") {
                    this.set_visible_child_name ("label");
                    entry.text = label.label;
                }
                return true;
            });

            this.show_all();
            this.set_visible_child_name ("label");
            this.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
        }
    }
}
