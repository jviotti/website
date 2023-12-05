---
title: Prolog
description: Prolog is a computer programming language that is used for solving problems that involve objects, and the relationships between objects
---

Programming in Prolog consists of:

- Specifying some _facts_ about objects and their _relationships_
- Defining some _rules_ about objects and their relationships
- Asking _questions_ about objects and their relationships

How it Works
------------

Prolog performs a task in response to a _question_ from the programmer. A
_question_ provides a _conjunction_ of goals to be _satisfied_. Prolog uses the
known _clauses_ to satisfy the _goals_. A fact can cause a goal to be satisfied
immediately, whereas a rule can only reduce the task to that of satisfying a
conjunction of _subgoals_. However, a clause can only be used if it _unifies_
the goal under consideration. If a goal can't be satisfied, _backtracking_ will
be initiated. Backtracking consists of reviewing what has been done, attempting
to _re-satisfy_ the goals by finding an alternative way to satisfy them.

Syntax
------

- Variables must begin with an upper-case letter
- Comments are written as `% ...` or as `/** ... */`

### Constants

#### Atoms

Two different types:

- Atoms made of letters and digits (e.g: `likes`, `john`, `foo123`)
  - They must begin with a lower-case letter in its name (e.g: `--foo_bar--`)
- Atoms made of symbols (e.g: `?-`, `:-`)

If an atom is enclosed in single quotes, then it may contain any characters

#### Numbers

- Exponential notation is allowed

```prolog
6.02e-23
```

### Variables

- The must begin with an upper-case letter or an underscore

#### Anonoymous variable

Use an underscore as an anonymous variable (like Haskell):

```prolog
?- likes(_, john).
```

It saves from having to invent names for variables that are going to be unused
anyway.

### Structures (compound terms)

A structure is a single object consisting of a collection of other objects,
called _components_.

Example:

```prolog
owns(john, book(ulysses, author(james, joyce)))
```

Here the structures are:

- `book([title], [author])`
- `author([name], [surname])`

Lists
-----

```prolog
[ foo, X, [ bar, baz ] ]
```

### Head & Tail

```prolog
[X|Y]
```

The `X` is the head, and `Y` is the tail.

For example:

```prolog
p([1, 2, 3]).

?- p([X|Y]).
X = 1
Y = [2, 3]
```

***

```prolog
p([ mary, likes, wine ]).

?- p([X,Y|Z]).
X = mary
Y = likes
Z = [wine]
```

### Membership

To check if an element is inside the list, we must check if its the head of the
list, and if not, check if its the head of the tail, and so on.

```prolog
member(X, [X|_]).
member(X, [_|Y]) :- member(X, Y).
```

The first fact says that `X` is a member of the array if the array has `X` as
its head. The second fact says that `X` is a member of the tail of the array
(`Y`), if the tail's head is `X`.

Example:

```prolog
?- member(2, [1, 2, 3]).
yes
```

### Mapping

Mapping is performed by declaring facts that transform certain elements into
other elements, and then having a fact that transforms all elements of the list
by applying itself recursively to the tail of the list.

```prolog
change(yes, no).
change(no, yes).
change(X, X).
```

The last line does nothing to atoms other than `yes` and `no`.

```prolog
alter([], []).
alter([H|T], [X|Y]) :-
  change(H, X),
  alter(T, Y).
```

Then:

```prolog
?- alter([ yes, yes, no, foo ], X)
X = [ no, no, yes, foo ]
```

### Concatenation

```prolog
/** Concatenating [] and `list` results in `list` */
append([], L, L).

append([X|List1], List2, [X|List3]) :-
  append(List1, List2, List3).
```

In this implementation, we take each element from `List1` in turn, and make it
the head of the third argument. At some point, the third list, will contain all
the elements of `List1` at its head and `List1` will be empty, so the base
class applies, saying that the remaining of the third list (what is not the
contents of `List1`) equals `List2`, effectively performing the concatenation.

Example:

```prolog
?- append([1, 2, 3], [4, 5, 6], Result).
Result = [1, 2, 3, 4, 5, 6]

/** First pass */
X = 1
List1 = [ 2, 3 ]
List2 = [ 4, 5, 6 ]
List3 = [ 2, 3 ]
Result = [ 1, <unknown> ]

/** Second pass */
X = 2
List1 = [ 3 ]
List2 = [ 4, 5, 6 ]
List3 = [ 3 ]
Result = [ 1, 2, <unknown> ]

/** Third pass */
X = 3
List1 = []
List2 = [ 4, 5, 6 ]
List3 = []
Result = [ 1, 2, 3, <unknown> ]

/** Fourth pass */
L = [ 4, 5, 6 ]
Result = [ 1, 2, 3, 4, 5, 6 ]
```

***

```prolog
?- append(X, [4, 5, 6], [1, 2, 3, 4, 5, 6]).
X = [1, 2, 3]
```

### Length

```prolog
listlength([], 0).
listlength([X|S], Length) :-
  listlength(S, L),
  Length is L + 1.
```

### Reducers

Define extra utility predicates that handle an accumulator.

For example:

- Reducer-based definition of `listlength`:

```prolog
listlength(List, Length) :- listlength_acc(List, 0, Length).
listlength_acc([], Accumulator, Accumulator).
listlength_acc([Head|Tail], Accumulator, Length) :-
  Total is Accumulator + 1,
  listlength_acc(Tail, Total, Length).
```

Facts
-----

> `[relationship]([objects...]).`

Example:

```prolog
likes(john, mary).
```

Variables
---------

- Can be instantiated or non-instantiated:

```prolog
likes(john, mary).

?- likes(john, X)
```

Here the `X` variable is _non-instantiated_. Prolog finds that `john` likes
`mary`, so `X = mary`. At this point the variable is _instantiated_.

Goals
-----

### Conjunction (comma)

```prolog
?- [goal1], [goal2], [goal3].
```

- Prolog attemps to satify each goal in turn (first `goal1`, then `goal2`, etc)

### Disjunction (colon)

```prolog
?- [goal1]; [goal2]; [goal3].
```

- Try to avoid colons by defining extra clauses

Rules
-----

Rules are general statements about objects and their relationships. They consist of a "head" and a "body", separated by `:-` (pronounced "if")

- Rules are used when you want to say that a fact _depends_ on a group of other
  facts

### Examples

- `john` likes `X` if `X` likes `wine`:

```prolog
likes(john, X) :-
  likes(X, wine).
```

- `john` likes any female that likes `wine`

```prolog
likes(john, X) :-
  female(X),
  likes(X, wine).
```

Functors
--------

### `.` (period)

> Construct lists

- A list containing the atom `a`:

```prolog
.(a,[])
```

- A list containing the atoms `a`, `b`, and `c`:

```prolog
.(a,.(b,.(c,[])))
```

Predicates
----------

### `= (equal)`

- If two objects are equal, we say that they `co-defer`
- If one of the two sides of an equal predicate contains a variable, then
  Prolog attempts to unify both objects:

```prolog
?- rides(student, bycicle) = rides(student, X).
X = bycicle
```

### `== (strict equal)`

The `=` predicate considers an uninstantiated variable to equal to anything,
while `==` only considers uninstantiated variable to equal other uninstantiated
variables already sharing with it.

### `=:=`

Check if two numbers are equal.

```prolog
5 =:= 5.
```

### `=/=`

Check if two numbers are different.

```prolog
5 =/= 8.
```

### `is`

Evaluate an arithmetic expression.

- Its right-hand argument is a term which is interpreted as an arithmetic
  expression
- The answer is unified with the left-hand argument to determine whether the
  goal succeeds
- All the values of the variables on the right side must be known

Example:

```prolog
population(usa, 203).
area(usa, 3).

density(Country, Density) :-
  population(Country, Population),
  area(Country, Area),
  Density = Population / Area.

?- density(usa, X).
X = 67.666666667
```

- We can use `is` to save a temporary variable:

```prolog
sum(A, B, Result) :-
  Total is A + B,
  Result is Total.
```

### `call`

Treats its argument as a goal and attempt to satisfy it.

### `\+`

The goal `\+X` succeeds only when the goal `X` fails.

This could be implemented like this:

```prolog
\+P :- call(P), !, fail.
\+P.
```

### `var`

The goal `var(X)` succeeds if `X` is an uninstantiated variable:

```prolog
?- var(X).
yes

?- var(25).
no
```

### `nonvar`

The goal `nonvar(X)` succeeds if `X` is an instantiated variable.

- This is the opposite of `var`. It could be defined as:

```prolog
nonvar(X) :- var(X), !, fail.
nonvar(_).
```

### `atom`

The goal `atom(X)` succeeds if `X` is an atom.

### `number`

The goal `number(X)` succeeds if `X` is an atom.

### `atomic`

The goal `atomic(X)` succeeds if `X` is ether an atom or a number.

### `true`

A goal without arguments that always succeeds.

### `fail`

A goal without arguments that always fails. It's usually used to force
backtracing to take place.

- Typicall used along with `!`

Example:

```prolog
average_tax_payer(Person) :-
  foreigner(Person), !, fail.
```

If `Person` is a foreigner, then `foreigner(Person)` succeeds, causing Prolog
to proceed on the same fact and "cross the cut fence". `fail` always fails, and
since we had a "cut" right before, Prolog can't backtrace anywhere, and will
cause the entire `average_tax_payer` fact to fail.

If `Person` is not a foreigner, `foreigner(Person)` will fail, so Prolog will
continue with the next definition of `average_tax_payer` instead of "crossing
the cut fence".

### `write`

Write a string to the screen.

```prolog
write("Foo bar baz").
```

- Any uninstantiated variable is written as an underscore followed by its
  unique id number (e.g: `_267`)

### `read`

Read the next term you type in from the computer keyboard.

```prolog
read(X).

/** X is instantiated to the user's input */
```

### `nl`

Force all succeeding output to appear on the next line.

### `get_char`

Read a character from the user.

- If the argument passed to it is not instantiated, the goal succeeds and the
  variable gets assigned

- If the argument passed to it is instantiated, `get_char` compares the
  character for equality

### `put_char`

Write a character to the screen.

### `open`

Open a file.

```prolog
open("path/to/file", read, X).
open("path/to/file", write, X).
```

`X` is instantiated to a term naming a stream.

### `close`

Close a stream.

Example:

```prolog
main :-
  open("path/to/file", read, X),
  do_something_with_file(X),
  close(X).
```

### `set_input`

Set a stream as the current input stream.

- All read-related functions will operate on the default input stream

```prolog
open("path/to/file", read, X), set_input(X).
```

### `set_output`

Set a stream as the current output stream.

- All write-related functions will operate on the default output stream

```prolog
open("path/to/file", write, X), set_output(X).
```

### `current_input`

Get a reference to the current input stream.

- This is useful to revert the current input stream after modifying it:

```prolog
main :-
  open("path/to/file", read, X),
  current_input(Stream),
  set_input(X),
  do_something_with_file(X),
  close(X),
  set_input(Stream).
```

### `current_output`

Get a reference to the current output stream.

- This is useful to revert the current output stream after modifying it:

```prolog
main :-
  open("path/to/file", write, X),
  current_output(Stream),
  set_output(X),
  do_something_with_file(X),
  close(X),
  set_output(Stream).
```

### `consult`

Import the clauses of another file into the current session.

```prolog
consult("path/to/file.pl").
```

You can use the following syntax sugar if you need to consult multiple files:

```prolog
["path/to/file1.pl","path/to/file2.pl","path/to/file3.pl"].
```

### `listing`

Print a declared clause definition to the screen:

```prolog
likes(foo, bar).
listing(likes).
```

### `functor`

Get information about a structure.

```prolog
person("Juan Cruz", "Viotti", 21).

?- functor(person, Functor, Arity)
Functor = person
Arity = 3
```

### `arg`

Access the nth element of a structure:

```prolog
?- arg(2, person("Juan Cruz", "Viotti", 21), Value)
Value = "Viotti"
```

### `=.. (univ)`

Get a list of the functor plus all the arguments to it.

```prolog
foo(a, b, c) =.. X.
X = [foo, a, b, c]
```

### `atom_chars`

Get a list of an atom's characters.

```prolog
atom_chars(hello, X).
X = [h, e, l, l, o]
```

### `number_chars`

Get a list of an number's characters.

```prolog
number_chars(16.1, X).
X = ['1', '6', '.', '1']
```

### `op`

Declare an operator.

The goal `op(X, Y, Z)` declares an operator having precedence class `X`,
associativity `Y`, and name `Z`.

- The goal will only succeed if the operation declaration is legal

Valid associativity values:

- `fx`
- `fy`
- `xf`
- `yf`
- `xfx`
- `xfy`
- `yfx`
- `yfy`

Cut
---

The "cut" is a goal that allows you to tell Prolog which previous choices it
need not consider again when it backtracks through the chain of satisfied
goals.

Formally:

> When a cut is encountered as a goal, the system thereupon becomes committed
> to all choices made since the parent goal was invoked. All other alternatives
> are discarded. Hence an attempt to re-satisfy any goal between the parent
> goal and the cut goal fill fail.

The "cut" is represented with an exclamation sign (`!`).

- This makes programs faster and more memory efficient, since Prolog will not
  waste time attempting to satisfy goals that you can tell beforehand will
  never contribute to a solution

Example:

```prolog
/** This program checks if a person has access to certain
    library facilities */

facility(Person, Facility) :-
  book_overdue(Person, Book),
  !,
  basic_facility(Facility).

facility(Person, Facility) :-
  general_facility(Facility).

basic_facility(reference).
basic_facility(enquiries).

additional_facility(borrowing).
additional_facility(inter_library_loan).

general_facility(Facility) :- basic_facility(Facility).
general_facility(Facility) :- additional_facility(Facility).

/** Program data */

client("A. Jones").
client("W. Metesk").

book_overdue("A. Jones", book29907).
```

We can then ask what facilities are open to a specific client by querying:

```prolog
?- facility("A. Jones", X)
```

Without the "cut", the first `facility` clause will fail because "A. Jones" has
an overdue book, so Prolog will try the next fact, which only checks if
`general_facility(Facility)`, which will be fulfilled, and thus the program
will report that "A. Jones" has access to _any_ facility.

By putting the "cut" after `book_overdue(Person, Book)`, we tell Prolog that
we're only interested on if `Person` has any book overdue, not all of them, so
if the goal fails, Prolog will not try to find every overdue book in vain. It
also tells Prolog that it should stop considering any other fact after it,
causing `facility` to correctly report "no" if the person has any overdue book.

In summary:

> If a client is found to have an overdue book, then only allow the client to
> access the basic facilities of the library. Don't bother going through all
> the client's overdue books, and don't consider any other rule about
> facilities.

Comparing terms
---------------

This is done by preppending ordering predicates with `@`.

- Uninstantiated variables < floating-point numbers < integers < atoms <
  structures
- For two uninstantiated variables, this is implementation dependent

### Atoms

- Atoms are compared alphabetically

### Structures

- One structure is less than another if its functor has a lower arity
- If they both have the same arity, then the ordering is based on the functor
  name
- If they both have the same arity and functor, they are ordered based on their
  arguments (for the first correspondent arguments that differ)

Example:

```prolog
g(X) @< f(X, Y).
g(Z, b) @< f(a, A).
123.5 @< 2
```

Debugging
---------

### Tracing

Enable tracing with `trace.` and disable with `notrace.`.

### Spy

Spying is like tracing, but it applies to certain predicates you pick:

```prolog
spy(append).
```

You can remove to spy with `nospy([predicate]).`.

Rules of Thumbs
---------------

- Declare facts _before_ rules to avoid potential infinite left recursion
- It is a good practice to replace cuts with `\+`, unless doing so imposes a
  too big performance hit

Resources
---------

- [Programming in Prolog: Using the ISO Standard](https://www.amazon.com/Programming-Prolog-Using-ISO-Standard/dp/3540006788)
