/*
 * Copyright (C) 2014, National ICT Australia Limited. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 *  * The name of National ICT Australia Limited nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Type strengthen test cases.
 */

struct ure {
  int x;
  struct ure *n;
};


/*********************
 * Pure functions.
 *********************/
void pure_f(void) {
}

void pure_f2(void) {
  pure_f();
}

struct ure *pure_g(struct ure *p) {
  return p;
}

int pure_h(struct ure *p) {
  return !!p;
}

int pure_i(int x) {
  return x;
}

int pure_j(struct ure s) {
  return s.x;
}

int pure_k(struct ure s) {
  return pure_i(s.x) && pure_j(s);
}

/* NB: L2Opt removes the division guard, so this lifts successfully. */
unsigned pure_div_roundup(unsigned x, unsigned n) {
  /* Quiz: is this function correct? */
  if(n == 0) return 0;
  return (x + (n - 1)) / n;
}



/*********************
 * Read-only state monad.
 *********************/
unsigned gets_x;
unsigned gets_y[4];

/*
   Force the globals to be translated as variables.
   Otherwise, c-parser turns them into constants because nothing
   writes to them.

   We could turn on globals_all_addressed in c-parser,
   but that causes the globals to become generic pointers,
   and autocorres loses the knowledge that those pointers
   always point to valid objects.

   Basically, the read-only monad is kind of flimsy and of
   dubious usefulness. But see type_strengthen_tricks.thy.
 */
void hax(void) {
  gets_x = 42;
  gets_y[0] = 42;
}

unsigned gets_f(void) {
  return gets_x;
}

unsigned gets_g(void) {
  unsigned y[4] = {0};
  y[0] = gets_y[0];
  y[1] = gets_y[1];
  y[2] = gets_y[2];
  y[3] = gets_y[3];
  if(y[0] && y[1] && y[2] && y[3]) {
    if(y[0]) y[0] += y[1];
    if(y[1]) y[1] += y[2];
    if(y[2]) y[2] += y[3];
    if(y[3]) y[3] += y[0];
  } else {
    y[0] = 1;
    y[1] += y[0];
    y[2] += y[1];
    y[3] += y[2];
  }
  return y[0] * y[1] * y[2] * y[3];
}



/*********************
 * Option monad (Read with failure).
 *********************/
unsigned opt_f(unsigned *p) {
  return *p;
}

int opt_g(int n) {
  return n + 1;
}

unsigned opt_h(struct ure *s) {
  if(!s) return 0;
  return 1 + opt_h(s->n);
}

int opt_none(void);
int opt_i(void) {
  return opt_none();
}

int opt_j(struct ure *p, struct ure *l) {
  return p->x <= l->x;
}

/* This doesn't read state at all, but AutoCorres assumes loops may fail (to terminate). */
unsigned opt_l(unsigned n) {
  unsigned p = 0;
  while(n > 1) {
    p++;
    n /= 10;
  }
  return p;
}

/* Ditto for recursion. */
unsigned opt_a(unsigned m, unsigned n) {
  if(m == 0) return n + 1;
  if(n == 0) return opt_a(m - 1, 1);
  return opt_a(m - 1, opt_a(m, n - 1));
}



/*********************
 * State monad (with failure).
 * TODO: state monad is no longer used, rename these examples.
 *********************/
void st_f(struct ure *p, struct ure *s) {
  p->n = s;
}

unsigned st_g(unsigned *p) {
  *p = 42;
  return *p;
}

unsigned st_h(unsigned p) {
  return st_g((unsigned*)p);
}

struct ure *st_i(struct ure *p, struct ure *l) {
  if(opt_j(p, l) || !l) {
    if(l) {
      p->n = l->n;
    }
    return p;
  } else {
    l->n = st_i(p, l->n);
    return l;
  }
}

/*********************
 * Exception monad, the most general monad.
 *********************/
int exc_f(char *s, int *n) {
  int x = 0;
  int sg = 1;
  if(*s == '-') {
    sg = -1;
    s++;
  } else if(*s == '+') {
    s++;
  }
  for(; *s; s++) {
    if(*s >= '0' && *s <= '9') {
      x = 10 * x + sg * (*s - '0');
    } else {
      return -1;
    }
  }
  if(*s) {
    return -1;
  } else {
    *n = x;
    return 0;
  }
}
