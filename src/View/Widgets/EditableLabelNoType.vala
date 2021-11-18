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

using View.Widgets.EditableWidgetTools;

namespace View.Widgets {

    public class EditableLabelNoType : Gtk.Stack, EditableWidget {

        private Gtk.Label label = new Gtk.Label ("");
        private Gtk.Entry entry = new Gtk.Entry ();

        private Gtk.Label explaining_label = new Gtk.Label ("");

        public DataHelper.Type data_type {set; protected get;}
        public string text {
            owned get {
                return label.get_text ();
            }
        }

        public EditableLabelNoType (string text = "", DataHelper.Type label_text) {
            if (text == null) {
                text = "";
            }

            label.set_text (text);
            entry.set_text (text);
            data_type = label_text;
            explaining_label.label = @"$(data_type.to_string_translated ()):";
        }

        construct {
            var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
            delete_button.set_tooltip_text (_("Edit this entry"));
            delete_button.get_style_context ().add_class ("flat");

            var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
            edit_button.set_tooltip_text (_("Edit this entry"));
            edit_button.get_style_context ().add_class ("flat");

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

            delete_button.clicked.connect (() => deleted ());

            edit_button.clicked.connect (() => {
                this.set_visible_child_name ("entry");
                SignalAggregator.INSTANCE.opened (this);
            });

            entry.activate.connect (() => {
                this.set_visible_child_name ("label");
                label.set_text (entry.get_text ());
                changed ();
            });

            // entry.focus_out_event.connect (() => {
            //     this.set_visible_child_name ("label");
            //     entry.text = label.label;
            // });

            entry.key_release_event.connect ((key) => {
                if (Gdk.keyval_name (key.keyval) == "Escape") {
                    close_without_saving ();
                }
                return true;
            });

            SignalAggregator.INSTANCE.opened.connect ((widget) => {
                if (widget != this) {
                    close_without_saving ();
                }
            });

            this.show_all ();
            this.set_visible_child_name ("label");
            this.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
        }

        public void close_without_saving () {
            this.set_visible_child_name ("label");
            entry.text = label.label;
        }
    }
}
