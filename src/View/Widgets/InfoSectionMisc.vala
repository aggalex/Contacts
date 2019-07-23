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

    public class HandlerInterfaceMisc {
        public delegate void HandlerAddFunc (string data);
        public delegate void HandlerRemoveFunc (int index);
        public delegate bool HandlerSetFunc (string data, int index);

        public delegate void VoidFunc ();
        public delegate void VoidFuncWBool (bool boolean);

        public delegate void DateSetFunc (DateDay day, int month, DateYear year);

        public HandlerAddFunc add_note;
        public HandlerRemoveFunc remove_note;
        public HandlerSetFunc change_note;

        public HandlerAddFunc add_website;
        public HandlerRemoveFunc remove_website;
        public HandlerSetFunc change_website;

        public HandlerAddFunc add_nickname;
        public HandlerRemoveFunc remove_nickname;
        public HandlerSetFunc change_nickname;

        private VoidFunc _new_birthday;
        public VoidFunc new_birthday {
            get {
                return _new_birthday;
            }
            set {
                _new_birthday = () => {
                    value ();
                    on_set_birthday (true);
                };
            }
        }

        private VoidFunc _clear_birthday;
        public VoidFunc clear_birthday {
             get {
                 return _clear_birthday;
             }
             set {
                 _clear_birthday = () => {
                     value ();
                     on_set_birthday (false);
                 };
             }
         }

        public DateSetFunc set_birthday;

        internal VoidFuncWBool on_set_birthday;

        private VoidFunc _new_anniversary;
        public VoidFunc new_anniversary {
            get {
                return _new_anniversary;
            }
            set {
                _new_anniversary = () => {
                    value ();
                    on_set_anniversary (true);
                };
            }
        }

        private VoidFunc _clear_anniversary;
        public VoidFunc clear_anniversary {
             get {
                 return _clear_anniversary;
             }
             set {
                 _clear_anniversary = () => {
                     value ();
                     on_set_anniversary (false);
                 };
             }
         }

        public DateSetFunc set_anniversary;

        internal VoidFuncWBool on_set_anniversary;
    }

    public class InfoSectionMisc : InfoSection {

        public signal void changed_calendar (Date date);

        private SimpleMenu menu;

        internal new HandlerInterfaceMisc handler = new HandlerInterfaceMisc ();

        private int note_count = 0;
        private int website_count = 0;
        private int nickname_count = 0;

        private Gtk.Button birthday_button;
        private Gtk.Button anniversary_button;

        private void on_set_birthday (bool has_birthday) {
            if (birthday_button != null) 
                birthday_button.sensitive = !has_birthday;
        }

        private void on_set_anniversary (bool has_anniversary) {
            if (anniversary_button != null) 
                anniversary_button.sensitive = !has_anniversary;
        }

        public InfoSectionMisc (string title) {
            base (title);
        }

        construct {
            menu = new SimpleMenu (add_button);
            foreach (var data in DataHelper.Type.MISC) {
                var button = menu.append (data.to_string_translated ());
                switch (data) {
                    case BIRTHDAY:
                        birthday_button = button;
                        break;
                    case ANNIVERSARY:
                        anniversary_button = button;
                        break;
                }
            }
            menu.poped_down.connect ((index) => {
                print (@"POPED DOWN: $index\n");
                var parsed_data = DataHelper.Type.parse_int (index + 3);
                switch (parsed_data) {
                    case NOTES:
                        new_entry_note ("");
                        break;
                    case WEBSITE:
                        new_entry_website ("");
                        break;
                    case NICKNAME:
                        new_entry_nickname ("");
                        break;
                    case BIRTHDAY:
                        new_entry_birthday (null, null, null);
                        break;
                    case ANNIVERSARY:
                        new_entry_anniversary (null, null, null);
                        break;
                }
            });
            handler.on_set_birthday = on_set_birthday;
            handler.on_set_anniversary = on_set_anniversary;
        }

        protected override void add_button_action () {
            menu.popup ();
            menu.show_all ();
        }

        public void new_entry_note (string data) {
            var type = DataHelper.Type.NOTES;
            var entry = new EditableLabelNoType (data, type);

            _new_entry (entry, note_count++);

            if (can_write) handler.add_note (data);
        }

        public void new_entry_website (string data) {
            var type = DataHelper.Type.WEBSITE;
            var entry = new EditableLabelNoType (data, type);

            _new_entry (entry, website_count++);

            if (can_write) handler.add_website (data);
        }

        public void new_entry_nickname (string data) {
            var type = DataHelper.Type.NICKNAME;
            var entry = new EditableLabelNoType (data, type);
            _new_entry (entry, nickname_count++);

            if (can_write) handler.add_nickname (data);
        }

        public void new_entry_birthday (uint? day, uint? month, uint? year) {
            var entry = new EditableLabelDate (day, month, year, DataHelper.Type.BIRTHDAY);
            _new_entry (entry);

            if (can_write) handler.new_birthday ();

            on_set_birthday (true);

            if (day != null && month != null && year != null) {

                var date_day = (day <= 1 || day >= 31)? (DateDay) day : DateDay.BAD_DAY;
                var date_month = (month < 0 || month > 12)? (int) month + 1: 0;
                var date_year = (year >= 1)? (DateYear) year: DateYear.BAD_YEAR;

                if (date_day != DateDay.BAD_DAY && date_month != 0 && date_year != DateYear.BAD_YEAR) {
                    if (can_write) handler.set_birthday (date_day, date_month, date_year);
                }
            }
        }

        public void new_entry_anniversary (uint? day, uint? month, uint? year) {
            var entry = new EditableLabelDate (day, month, year, DataHelper.Type.ANNIVERSARY);
            _new_entry (entry);

            if (can_write) handler.new_anniversary ();

            on_set_anniversary (true);

            if (day != null && month != null && year != null) {

                var date_day = (day <= 1 || day >= 31)? (DateDay) day : DateDay.BAD_DAY;
                var date_month = (month < 0 || month > 12)? (int) month + 1: 0;
                var date_year = (year >= 1)? (DateYear) year: DateYear.BAD_YEAR;

                if (date_day != DateDay.BAD_DAY && date_month != 0 && date_year != DateYear.BAD_YEAR) {
                    if (can_write) handler.set_anniversary (date_day, date_month, date_year);
                }
            }
        }

        protected override void handler_new_entry (EditableWidget widget) {}

        protected override void handler_change_entry (EditableWidget widget, int index) {
            switch (widget.data_type) {
                case BIRTHDAY:
                    var label = (EditableLabelDate) widget;
                    handler.set_birthday ((DateDay) label.day, label.month+1, (DateYear) label.year);
                    return;
                case ANNIVERSARY:
                    var label = (EditableLabelDate) widget;
                    handler.set_anniversary ((DateDay) label.day, label.month+1, (DateYear) label.year);
                    return;
                case NOTES:
                    handler.change_note (widget.text, index);
                    return;
                case WEBSITE:
                    handler.change_website (widget.text, index);
                    return;
                case NICKNAME:
                    handler.change_nickname (widget.text, index);
                    return;
            }
        }

        protected override void handler_remove_entry (int index, DataHelper.Type? type) {
            switch (type != null? type: DataHelper.Type.MISC_DEFAULT) {
                case BIRTHDAY:
                    handler.clear_birthday ();
                    return;
                case ANNIVERSARY:
                    handler.clear_anniversary ();
                    return;
                case NOTES:
                    handler.remove_note (index);
                    note_count--;
                    return;
                case WEBSITE:
                    handler.remove_website (index);
                    website_count--;
                    return;
                case NICKNAME:
                    handler.remove_nickname (index);
                    nickname_count--;
                    return;
            }
        }

    }
}
