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

        private Gtk.Label explaining_label = new Gtk.Label ("");
        private Gtk.Revealer calendar_revealer = new Gtk.Revealer ();

        private Date date_backup = Date ();

        public int day {
            get {return calendar.day;}
        }

        public int month {
            get {return calendar.month;}
        }

        public int year {
            get {return calendar.year;}
        }

        public DataHelper.Type data_type {get; private set;}
        public string text {
            owned get {
                return extract_label_text ();
            }
        }

        delegate void VoidFunc ();

        public EditableLabelDate (uint? day, uint? month, uint? year, DataHelper.Type label_text) {
            data_type = label_text;

            var now = new GLib.DateTime.now_local ();
            int year_now;
            int month_now;
            now.get_ymd (out year_now, out month_now, null);
            calendar.select_month (month_now, year_now-30);

            if (day != null && month != null && year != null) {
                calendar.day = (int) day;
                calendar.month = (int) month-1;
                calendar.year = (int) year;
                label.set_text (extract_label_text ());
            } else {
                label.set_text ("");
            }
            explaining_label.label = @"$(data_type.to_string_translated ()):";
        }

        private string extract_label_text () {
            var month = calendar.month + 1;
            var day = calendar.day;
            var year = calendar.year;

            var date_time = new GLib.DateTime.local (year, month, day, 0, 0, 0);

            return date_time.format (Granite.DateTime.get_default_date_format (false, true, true));
        }

        construct {
            date_backup.set_dmy ((DateDay) calendar.day, calendar.month, (DateYear) calendar.year);

            var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", Gtk.IconSize.BUTTON);
            delete_button.set_tooltip_text (_("Delete this entry"));
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

            calendar.set_halign (Gtk.Align.FILL);
            calendar.margin = 6;

            calendar_revealer.can_focus = true;
            calendar_revealer.set_transition_type (RevealerTransitionType.SLIDE_DOWN);
            calendar_revealer.add (calendar);
            calendar_revealer.set_reveal_child (false);

            this.add_named (label_box, "label");
            this.add_named (calendar_revealer, "calendar");

            label.label = extract_label_text ();

            delete_button.clicked.connect (() => deleted ());

            var loop = new MainLoop ();
            VoidFunc close_calendar = () => {
                revealer_pause.begin ((obj, res) => {
                    loop.quit ();
                });
                loop.run ();
                this.set_visible_child_name ("label");
                date_backup.set_dmy ((DateDay)calendar.day, calendar.month, (DateYear)calendar.year);
                label.set_text (extract_label_text ());
                changed ();
            };

            edit_button.clicked.connect (() => {
                this.set_visible_child_name ("calendar");
                calendar_revealer.set_reveal_child (true);
            });

            calendar.key_release_event.connect ((key) => {
                if (key.keyval == 65293)
                    close_calendar ();
                return false;
            });

            calendar.focus_out_event.connect (() => {close_calendar ();});

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
            calendar_revealer.set_reveal_child (false);
            yield nap ((int) calendar_revealer.get_transition_duration () - 150);
        }
    }
}
