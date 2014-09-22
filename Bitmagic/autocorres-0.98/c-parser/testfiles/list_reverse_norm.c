/*
 * Copyright (C) 2014 NICTA
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions, and the following disclaimer,
 *    without modification.
 *
 * 2. Redistributions in binary form must reproduce at minimum a disclaimer
 *    substantially similar to the "NO WARRANTY" disclaimer below
 *    ("Disclaimer") and any redistribution must be conditioned upon
 *    including a substantially similar Disclaimer requirement for further
 *    binary redistribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGES.
 */

typedef unsigned int word_t;

/** FNSPEC reverse_spec:
  "\<Gamma> \<turnstile>
    \<lbrace> list (lift_t_c \<zeta>) zs \<acute>i \<rbrace>
      \<acute>ret__unsigned :== PROC reverse(\<acute>i)
    \<lbrace> list (lift_t_c \<zeta>) (rev zs) (Ptr \<acute>ret__unsigned) \<rbrace>"

*/

word_t reverse(word_t *i)
{
  word_t j = 0;

  while (i)
    /** INV:
        "\<lbrace> \<exists>xs ys. list (lift_t_c \<zeta>) xs \<acute>i \<and>
                  list (lift_t_c \<zeta>) ys (Ptr \<acute>j) \<and>
                  rev zs = rev xs @ ys \<and>
                  distinct (rev zs) \<rbrace>" */
  {
    word_t *k = (word_t*)*i;

    *i = j;
    j = (word_t)i;
    i = k;
  }

  return j;
}