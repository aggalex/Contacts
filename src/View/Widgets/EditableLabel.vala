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
using View.Widgets.EditableWidgetTools;

namespace View.Widgets {

    public class EditableLabel : Gtk.Stack, EditableWidget {

        private Gtk.Label label = new Gtk.Label ("");
        private Gtk.Entry entry = new Gtk.Entry ();
        private SimpleMenu type_list = new SimpleMenu (null);
        private Gtk.Button type_button = new Gtk.Button ();

        public DataHelper.Type data_type {get; protected set;}
        public string text {
            owned get {
                return label.label;
            }
        }

        public EditableLabel (string text = "", DataHelper.Type type) {
            label.set_text (text);
            entry.set_text (text);
            data_type = type;
            type_button.set_label (@"$(data_type.to_string_translated ()):");
        }

        //Making the UI
        construct {
            var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
            delete_button.set_tooltip_text (_("Delete this entry"));
            delete_button.get_style_context ().add_class ("flat");
            delete_button.clicked.connect (() => deleted ());

            var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
            edit_button.set_tooltip_text (_("Edit this entry"));
            edit_button.get_style_context ().add_class ("flat");

            type_button.get_style_context ().add_class ("flat");
            type_button.get_style_context ().add_class ("bold");
            type_list.set_relative_to (type_button);
            foreach (var data_type in DataHelper.Type.ALL)
                type_list.append (data_type.to_string_translated ());

            type_button.clicked.connect (() => {
                type_list.popup ();
                type_list.show_all ();
                SignalAggregator.INSTANCE.opened (this);
            });

            type_list.poped_down.connect ((index) => {
                this.data_type = DataHelper.Type.parse_int (index);
                type_button.set_label (this.data_type.to_string_translated () + ":");
                changed ();
            });

            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            label_box.pack_start (delete_button, false, false, 0);
            label_box.pack_start (edit_button, false, false, 0);
            label_box.pack_start (type_button, false, false, 0);
            label_box.pack_start (label, false, true, 0);
            label_box.margin = 6;

            entry.set_text (text);
            entry.set_halign (Gtk.Align.FILL);
            entry.margin = 6;

            this.add_named (label_box, "label");
            this.add_named (entry, "entry");

            edit_button.clicked.connect (() => {
                this.set_visible_child_name ("entry");
                SignalAggregator.INSTANCE.opened (this);
            });

            entry.activate.connect (() => {
                label.set_text (entry.get_text ());
                this.set_visible_child_name ("label");
                changed ();
            });

            // entry.focus_out_event.connect (() => {
            //     close_without_saving ();
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
