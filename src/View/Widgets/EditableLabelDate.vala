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

    public class EditableLabelDate : Gtk.Stack, EditableWidget {

        private Gtk.Label label = new Gtk.Label ("");
        private Gtk.Calendar calendar = new Gtk.Calendar ();

        private Date date_backup = Date ();

        public string data_type {get; private set;}
        public string text {
            owned get {
                var month = (calendar.month + 1).to_string ();
                if (month.length == 1) month = "0" + month;
    
                var day = calendar.day.to_string ();
                if (day.length == 1) day = "0" + day;
    
                return (calendar.year.to_string () + month + day).to_string ();
            }
        }

        public EditableLabelDate (uint? day, uint? month, uint? year, string label_text) {
            data_type = label_text;

            if (day != null && month != null && year != null) {
                calendar.day = (int) day;
                calendar.month = (int) month-1;
                calendar.year = (int) year;
                label.set_text (extract_label_text ());
            } else {
                label.set_text ("");
            }
        }

        private string extract_label_text () {
            string[] month_names = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
            return calendar.day.to_string () + " of " + month_names[calendar.month] + ", " + calendar.year.to_string ();
        }

        construct {
            date_backup.set_dmy ((DateDay) calendar.day, calendar.month, (DateYear) calendar.year);

            var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
            delete_button.get_style_context ().add_class ("flat");

            var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.BUTTON);
            edit_button.get_style_context ().add_class ("flat");

            var explaining_label = new Gtk.Label (data_type + ":");
            explaining_label.get_style_context ().add_class ("bold");

            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            label_box.pack_start (delete_button, false, false, 0);
            label_box.pack_start (edit_button, false, false, 0);
            label_box.pack_start (explaining_label, false, false, 12);
            label_box.pack_start (label, false, true, 0);
            label_box.margin = 6;

            calendar.set_halign (Gtk.Align.FILL);
            calendar.margin = 6;

            var calendar_revealer = new Gtk.Revealer ();
            calendar_revealer.set_transition_type (RevealerTransitionType.SLIDE_DOWN);
            calendar_revealer.add (calendar);
            calendar_revealer.set_reveal_child (false);

            this.add_named (label_box, "label");
            this.add_named (calendar_revealer, "calendar");

            label.label = extract_label_text ();

            delete_button.clicked.connect (() => deleted ());

            edit_button.clicked.connect (() => {
                this.set_visible_child_name ("calendar");
                calendar_revealer.set_reveal_child (true);
            });

            calendar.day_selected_double_click.connect (() => {
                calendar_revealer.set_reveal_child (false);
                this.set_visible_child_name ("label");
                date_backup.set_dmy ((DateDay)calendar.day, calendar.month, (DateYear)calendar.year);
                label.set_text (extract_label_text ());
                changed ();
            });

            calendar.focus_out_event.connect (() => {
                this.set_visible_child_name ("label");
                calendar.day = date_backup.get_day ();
                calendar.month = date_backup.get_month ();
                calendar.year = date_backup.get_year ();
            });

            this.show_all();
            this.set_visible_child_name ("label");
            this.set_homogeneous (false);
            this.set_transition_type (Gtk.StackTransitionType.SLIDE_UP_DOWN);
        }
    }
}
