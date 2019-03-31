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
    public class EditableLabelSegmented : Gtk.Stack, EditableWidget {

        private Gtk.Label label = new Gtk.Label ("");
        private List<Gtk.Entry> entries = new List<Gtk.Entry> ();
        private Gtk.Button delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
        private SimpleMenu type_list = new SimpleMenu (null);
        private string text = "";
        private string type = "";

        public EditableLabelSegmented (string[]? text_array, string[] entry_names, string type) {

            if (text_array == null) {
                foreach (string text in text_array) {
                    text = "";
                }
            }

            for (int i = 0; i<entry_names.length; i++) {
                var entry = new Gtk.Entry ();
                entry.set_text (text_array [i]);
                entry.set_placeholder_text (entry_names[i]);
                entries.append (entry);
            }

            this.type = type;
            text = extract_text ();
            label.set_text (text);
            label.set_line_wrap (true);
            label.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
            label.set_max_width_chars (40);

            delete_button.get_style_context ().add_class ("flat");

            var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
            edit_button.get_style_context ().add_class ("flat");

            var type_button = new Gtk.Button ();
            type_button.set_label (@"$type: ");
            type_button.get_style_context ().add_class ("flat");
            type_button.get_style_context ().add_class ("bold");
            type_button.set_hexpand (false);
            type_list.set_relative_to (type_button);
            foreach (var data_type in DataTypes.ALL) {
                type_list.append (data_type);
            }
            type_button.clicked.connect (() => {
                type_list.popup ();
                type_list.show_all ();
            });
            type_list.poped_down.connect ((text) => {
                this.type = text;
                type_button.set_label (text + ":");
                changed ();
            });

            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            button_box.pack_start (delete_button, false, false, 0);
            button_box.pack_start (edit_button, false, false, 0);

            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            label_box.pack_start (type_button, false, false, 0);
            label_box.pack_start (label, false, false, 0);

            if (get_lines () >= 2) {
                button_box.set_orientation (Gtk.Orientation.VERTICAL);
                label_box.set_orientation (Gtk.Orientation.VERTICAL);
            } else {
                button_box.set_orientation (Gtk.Orientation.HORIZONTAL);
                label_box.set_orientation (Gtk.Orientation.HORIZONTAL);
            }

            var wrapping_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            wrapping_box.pack_start (button_box, false, true, 0);
            wrapping_box.pack_start (label_box, false, true, 0);
            wrapping_box.margin = 6;

            var entry_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            foreach (Gtk.Entry entry in entries) {
                entry_box.pack_start (entry, true, true, 0);
            }
            entry_box.get_style_context ().add_class ("linked");
            entry_box.set_halign (Gtk.Align.FILL);
            entry_box.margin = 6;

            var entry_revealer = new Gtk.Revealer ();
            entry_revealer.set_transition_type (RevealerTransitionType.SLIDE_DOWN);
            entry_revealer.add (entry_box);
            entry_revealer.set_reveal_child (false);

            this.add_named (wrapping_box, "label");
            this.add_named (entry_revealer, "entries");

            edit_button.clicked.connect (() => {
                this.set_visible_child_name ("entries");
                entry_revealer.set_reveal_child (true);
            });

            foreach (Gtk.Entry entry in entries) {
                entry.activate.connect (() => {
                    entry_revealer.set_reveal_child (false);
                    text = extract_text ();
                    this.set_visible_child_name ("label");
                    label.set_text (text);
                    if (get_lines () >= 2) {
                        button_box.set_orientation (Gtk.Orientation.VERTICAL);
                        label_box.set_orientation (Gtk.Orientation.VERTICAL);
                    } else {
                        button_box.set_orientation (Gtk.Orientation.HORIZONTAL);
                        label_box.set_orientation (Gtk.Orientation.HORIZONTAL);
                    }
                    changed ();
                });
            }

            this.show_all();
            this.set_visible_child_name ("label");
            this.set_homogeneous (false);
            this.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
        }

        private int get_lines () {
            int i = 1, j = 0;
            var text = new StringBuilder (label.get_text ());
            while (text.len > 40) {
                i++;
                j = 40;
                do {
                    if (text.str.index_of_char (' ') < 0) break;
                    j = j - text.str.index_of_char (' ') - 1;
                    text.erase (0, text.str.index_of_char (' ')+1);
                } while (text.str.index_of_char (' ')+1 < j);
            }
            return i;
        }

        private string extract_text () {
            var label_text = new StringBuilder ("");
            foreach (Gtk.Entry entry in entries) {
                var text = entry.get_text ();
                if (text != "") {
                    if (label_text.len != 0) {
                        label_text.append (", ");
                    }
                    label_text.append (text);
                }
            }
            label_text.erase (label_text.len-2,label_text.len);
            return label_text.str;
        }

        public string get_text () {
            var label_text = new StringBuilder ("");

            foreach (Gtk.Entry entry in entries) {
                var text = entry.get_text ();
                label_text.append (";");
                label_text.append (text);
            }

            print (label_text.str);
            //label_text.erase (label_text.len-2,label_text.len);
            return label_text.str;
        }

        public SimpleMenu? get_menu () {
            return type_list;
        }

        public string get_type_text () {
            return type;
        }

        public Gtk.Button get_delete_button () {
            return delete_button;
        }
    }
}
