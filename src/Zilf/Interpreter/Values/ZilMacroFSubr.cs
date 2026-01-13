/* Copyright 2010-2023 Tara McGrew
 *
 * This file is part of ZILF.
 *
 * ZILF is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * ZILF is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with ZILF.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Zilf.Interpreter.Values
{
    /// <summary>
    /// An FSubr that also performs macro expansion during compilation.
    /// Used for built-in macros like VERB?, PRSO?, PRSI? that need to be
    /// expanded during the macro expansion phase, not during evaluation.
    /// </summary>
    sealed class ZilMacroFSubr : ZilFSubr, IMacroExpander
    {
        public ZilMacroFSubr(string name, SubrDelegate handler)
            : base(name, handler)
        {
        }

        /// <summary>
        /// Expands the macro by calling the FSubr's handler with unevaluated arguments.
        /// The result is expected to be a ZilForm that will be further processed.
        /// </summary>
        public ZilResult ExpandMacro(Context ctx, ZilObject[] args)
        {
            // Call the handler with unevaluated arguments - same as ApplyNoEval
            return ApplyNoEval(ctx, args);
        }

        public override string ToString() => $"#FSUBR \"{name}\" (macro)";
    }
}
