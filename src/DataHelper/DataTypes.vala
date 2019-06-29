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

namespace DataHelper {

    public enum Type {

        HOME, WORK, OTHER, WEBSITE, NICKNAME, BIRTHDAY, NOTES;

        public const Type[] MISC = { Type.WEBSITE,  Type.NICKNAME,  Type.BIRTHDAY,  Type.NOTES};

        public const Type[] ALL = { Type.HOME,  Type.WORK,  Type.OTHER};

        public const Type DEFAULT = HOME;

        public const Type MISC_DEFAULT = NOTES;

        public string to_string () {
            switch (this) {
                case HOME: return "Home";
                case WORK: return "Work";
                case OTHER: return "Other";
                case WEBSITE: return "Website";
                case NICKNAME: return "Nickname";
                case BIRTHDAY: return "Birthday";
                case NOTES: return "Notes";
                default: return DEFAULT.to_string ();
            }
        }

        public static Type parse (string str) {
            switch (str) {
                case "Home": return HOME;
                case "Work": return WORK;
                case "Other": return OTHER;
                case "Website": return WEBSITE;
                case "Nickname": return NICKNAME;
                case "Birthday": return BIRTHDAY;
                case "Notes": return NOTES;
                default: return DEFAULT;
            }
        }
    }

    public class DataWithType<G> : Object{
        public G data;
        public Type type;

        public DataWithType (G data, Type type) {
            this.data = data;
            this.type = type;
        }
    }
}
