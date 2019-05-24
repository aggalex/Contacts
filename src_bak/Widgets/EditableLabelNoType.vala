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

    public class EditableLabelNoType : Gtk.Stack, EditableWidget {

        private Gtk.Label label = new Gtk.Label ("");
        private Gtk.Entry entry = new Gtk.Entry ();
        private Gtk.Button delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
        private string type;

        public EditableLabelNoType (string? text, string label_text) {
            type = label_text;

            if (text == null) {
                text = "";
            }

            label.set_text (text);

            delete_button.get_style_context ().add_class ("flat");

            var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
            edit_button.get_style_context ().add_class ("flat");

            var explaining_label = new Gtk.Label (label_text + ":");
            explaining_label.get_style_context ().add_class ("bold");

            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            label_box.pack_start (delete_button, false, false, 0);
            label_box.pack_start (edit_button, false, false, 0);
            label_box.pack_start (explaining_label, false, false, 12);
            label_box.pack_start (label, false, true, 0);
            label_box.margin = 6;

            entry.set_text (text);
            entry.set_halign (Gtk.Align.FILL);
            entry.margin = 6;

            this.add_named (label_box, "label");
            this.add_named (entry, "entry");

            edit_button.clicked.connect (() => {
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

        public SimpleMenu? get_menu () {
            print ("ILLEGAL ATTEMPT TO ACCESS MENU\n");
            assert (false);
            return null;
        }

        public string get_type_text () {
            return type;
        }

        public string get_text () {
            return entry.get_text ();
        }

        public Gtk.Button get_delete_button () {
            return delete_button;
        }
    }
}
