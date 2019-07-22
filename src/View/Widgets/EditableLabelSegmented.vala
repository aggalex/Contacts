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

using DataHelper;

namespace View.Widgets {
    public class EditableLabelSegmented : Gtk.Stack, EditableWidget {

        private Gtk.Label label = new Gtk.Label ("");
        private List<Gtk.Entry> entries = new List<Gtk.Entry> ();
        private Gtk.Box entry_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        private Gtk.Button delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
        private SimpleMenu type_list = new SimpleMenu (null);
        private Gtk.Revealer entry_revealer = new Gtk.Revealer ();

        private Gtk.Box button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        private Gtk.Box label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        private string[]? format_strings = null;

        internal List<string> text_array = new List<string> ();

        public DataHelper.Type data_type {get; protected set;}
        public string text {
            owned get {
                if (format_strings == null) {
                    var output = new StringBuilder ();
                    foreach (Gtk.Widget entry in entry_box.get_children ()) {
                        var text = ((Entry) entry).get_text ();
                        if (text != "") {
                            if (output.len != 0)
                                output.append (", ");
                            output.append (text);
                        }
                    }
                    return output.str;
                } else {
                    var output = new StringBuilder ();
                    foreach (var format_string in format_strings) {
                        Regex regex;
                        try {
                            regex = new Regex ("^\\d+");
                        } catch (RegexError e) {
                            assert_not_reached ();
                        }
                        var occurences = format_string.split ("$");
                        string section = "";
                        if (regex.match (occurences[1])) {
                            var data = entries.nth_data (int.parse (occurences[1])).get_text ();
                            if (data != "")
                                try {
                                    section = format_string.replace ("$" + occurences[1], regex.replace (occurences[1], occurences[1].length, 0, data));
                                } catch (RegexError e) {
                                    assert_not_reached ();
                                }
                        }
                        output.append (section);
                    }
                    return output.str;
                }
            }
        }

        public EditableLabelSegmented (string[]? text_array, string[] entry_names, DataHelper.Type type) {
            for (int i = 0; i<entry_names.length; i++) {
                var entry = new Gtk.Entry ();
                entry.text = text_array [i];
                entry.set_placeholder_text (entry_names[i]);
                entries.append (entry);
                this.text_array.append ("");
            }

            this.data_type = type;
            construct_this ();
        }

        public EditableLabelSegmented.empty (string[] entry_names, DataHelper.Type type) {
            foreach (var name in entry_names) {
                var entry = new Gtk.Entry ();
                entry.text = "";
                entry.set_placeholder_text (name);
                entries.append (entry);
                text_array.append ("");
                this.text_array.append ("");
            }

            this.data_type = type;
            construct_this ();
        }

        private void construct_this () {
            label.set_line_wrap (true);
            label.set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
            label.set_max_width_chars (40);

            delete_button.get_style_context ().add_class ("flat");
            delete_button.set_tooltip_text (_("Delete this entry"));
            delete_button.clicked.connect (() => deleted ());

            var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
            edit_button.set_tooltip_text (_("Edit this entry"));
            edit_button.get_style_context ().add_class ("flat");

            var type_button = new Gtk.Button ();
            type_button.set_label (@"$(data_type.to_string_translated ()): ");
            type_button.get_style_context ().add_class ("flat");
            type_button.get_style_context ().add_class ("bold");
            type_button.set_hexpand (false);
            type_list.set_relative_to (type_button);

            foreach (var data_type in DataHelper.Type.ALL) {
                type_list.append (data_type.to_string_translated ());
            }
            type_button.clicked.connect (() => {
                type_list.popup ();
                type_list.show_all ();
            });
            type_list.poped_down.connect ((text, index) => {
                this.data_type = DataHelper.Type.parse_int (index);
                type_button.set_label (this.data_type.to_string_translated () + ":");
                changed ();
            });


            button_box.pack_start (delete_button, false, false, 0);
            button_box.pack_start (edit_button, false, false, 0);

            label_box.pack_start (type_button, false, false, 0);
            label_box.pack_start (label, false, false, 0);

            var wrapping_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            wrapping_box.pack_start (button_box, false, true, 0);
            wrapping_box.pack_start (label_box, false, true, 0);
            wrapping_box.margin = 6;

            foreach (Gtk.Entry entry in entries) {
                entry_box.pack_start (entry, true, true, 0);
            }
            entry_box.get_style_context ().add_class ("linked");
            entry_box.set_halign (Gtk.Align.FILL);
            entry_box.margin = 6;

            entry_revealer.set_transition_type (RevealerTransitionType.SLIDE_DOWN);
            entry_revealer.add (entry_box);
            entry_revealer.set_reveal_child (false);

            this.add_named (wrapping_box, "label");
            this.add_named (entry_revealer, "entries");

            edit_button.clicked.connect (() => {
                this.set_visible_child_name ("entries");
                entry_revealer.set_reveal_child (true);
            });

            var loop = new MainLoop ();
            foreach (Gtk.Entry entry in entries) {
                entry.activate.connect (() => {
                    revealer_pause.begin ((obj, res) => {
                        loop.quit ();
                    });
                    loop.run ();
                    this.set_visible_child_name ("label");

                    var i = 0;
                    foreach (var s_entry in entries)
                        text_array.nth (i++).data = s_entry.text;

                    set_label_text ();

                    changed ();
                });
            }

            entry_box.focus_out_event.connect (() => {
                this.set_visible_child_name ("label");
                var i = 0;
                foreach (Gtk.Entry entry in entries) {
                    entry.text = text_array.nth_data (i++);
                }
                return true;
            });

            set_label_text ();
            this.show_all();
            this.set_visible_child_name ("label");
            this.set_homogeneous (false);
            this.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
        }

        public async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
          GLib.Timeout.add (interval, () => {
              nap.callback ();
              return false;
            }, priority);
          yield;
        }

        public async void revealer_pause () {
            entry_revealer.set_reveal_child (false);
            yield nap ((int) entry_revealer.get_transition_duration () - 150);
        }

        public void format (string[] format_strings) {
            this.format_strings = format_strings;
            set_label_text ();
        }

        private void set_label_text () {
            label.set_text (text);

            if (get_lines () >= 2) {
                button_box.set_orientation (Gtk.Orientation.VERTICAL);
                label_box.set_orientation (Gtk.Orientation.VERTICAL);
            } else {
                button_box.set_orientation (Gtk.Orientation.HORIZONTAL);
                label_box.set_orientation (Gtk.Orientation.HORIZONTAL);
            }
        }

        private int get_lines () {
            int i = 1, j = 0;
            var text = new StringBuilder (label.get_text ());
            while (text.len > 40) {
                i++;
                j = 40;
                bool changed = false;
                do {
                    if (text.str.index_of_char (' ') < 0) break;
                    changed = true;
                    j = j - text.str.index_of_char (' ') - 1;
                    text.erase (0, text.str.index_of_char (' ')+1);
                } while (text.str.index_of_char (' ')+1 < j);
                if (!changed) break;
            }
            return i;
        }
    }
}
