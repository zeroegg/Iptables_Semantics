(*
 * STANDARD ML OF NEW JERSEY COPYRIGHT NOTICE, LICENSE AND DISCLAIMER.
 * Copyright (c) 1989-1998 by Lucent Technologies
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright notice appear in all copies and that
 * both the copyright notice and this permission notice and warranty
 * disclaimer appear in supporting documentation, and that the name of
 * Lucent Technologies, Bell Labs or any Lucent entity not be used in
 * advertising or publicity pertaining to distribution of the software
 * without specific, written prior permission.
 *
 * Lucent disclaims all warranties with regard to this software, including
 * all implied warranties of merchantability and fitness. In no event shall
 * Lucent be liable for any special, indirect or consequential damages or
 * any damages whatsoever resulting from loss of use, data or profits,
 * whether in an action of contract, negligence or other tortious action,
 * arising out of or in connection with the use or performance of this
 * software.
 *)

fun main() = let
  val name = CommandLine.name()
in
  case CommandLine.arguments() of
    [] => (TextIO.output(TextIO.stdErr, name ^ ": no arguments\n");
           OS.Process.exit OS.Process.failure)
  | args => List.app LexGen.lexGen args
end;

main();


