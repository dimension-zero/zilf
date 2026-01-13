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

using Zilf.Interpreter.Values;

namespace Zilf.Interpreter
{
    /// <summary>
    /// Interface for objects that can perform macro expansion during compilation.
    /// This enables built-in FSubrs like VERB?, PRSO?, PRSI? to be expanded during
    /// the macro expansion phase, just like user-defined macros (ZilEvalMacro).
    /// </summary>
    interface IMacroExpander
    {
        /// <summary>
        /// Expands the macro with the given arguments.
        /// </summary>
        /// <param name="ctx">The current context.</param>
        /// <param name="args">The unevaluated arguments.</param>
        /// <returns>The expanded form, which will be recursively expanded if it's a ZilForm.</returns>
        ZilResult ExpandMacro(Context ctx, ZilObject[] args);
    }
}
