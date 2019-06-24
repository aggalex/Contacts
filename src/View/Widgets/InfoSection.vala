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

    public class InfoSection : Gtk.Box {

        public signal void changed (string text);
        public signal void info_changed ();

        protected string title;
        protected Gtk.Label title_label = new Gtk.Label (null);

        private ListBox list_box = new Gtk.ListBox ();
        private int population = 0;

        protected Gtk.Button add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);

        public InfoSection (string title) {
            this.title = title;
            title_label.set_text (title);
        }

        construct {
            add_button.clicked.connect (add_button_action);

            this.set_orientation (Gtk.Orientation.VERTICAL);
            this.set_spacing (0);

            title_label.xalign = 0;
            title_label.margin = 6;
            var title_label_context = title_label.get_style_context ();
            title_label_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
            title_label_context.add_class ("bold");

            add_button.margin = 6;

            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            label_box.pack_start (add_button, false, false, 0);
            label_box.pack_start (title_label, false, false, 0);

            this.pack_start (label_box, false, false, 0);
            this.pack_start (list_box, false, false, 0);
            this.get_style_context ().add_class ("transparent_background");
            this.margin = 12;
            this.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        }

        protected virtual void add_button_action () {
            new_entry ("", DataHelper.Type.DEFAULT.to_string ());
        }

        public void new_entry (string data, string type) {
            var entry = new EditableLabel (data, type);
            _new_entry (entry);
        }

        protected void _new_entry (EditableWidget entry) {
            string data;

            data = entry.text;

            population++;

            if (population == 1) {
                entry.changed.connect (() => {
                    changed (entry.text);
                    info_changed ();
                });
            } else {
                entry.changed.connect (() => {
                    info_changed ();
                });
            }

            var entry_revealer = new Gtk.Revealer ();
            entry_revealer.set_transition_type (RevealerTransitionType.SLIDE_DOWN);
            entry_revealer.add (entry);
            entry_revealer.set_reveal_child (false);

            var row = new Gtk.ListBoxRow ();
            row.set_selectable (false);
            row.set_name (data + "_row");
            row.add (entry_revealer);

            entry.deleted.connect (() => {
                entry_revealer.reveal_child = false;
                remove_entry ((ListBoxRow) entry_revealer.get_parent ());
            });

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            list_box.add (separator);
            list_box.add (row);
            list_box.show_all ();

            entry_revealer.set_reveal_child (true);
        }

        public void remove_entry (Gtk.ListBoxRow sender) {
            list_box.remove (list_box.get_row_at_index (sender.get_index () - 1));
            list_box.remove (sender);
            population--;
            if (population == 0) {
                changed ("");
            }
            info_changed ();
        }
    }
}
