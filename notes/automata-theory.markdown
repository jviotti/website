---
title: Automata Theory
description: Automata theory is a branch of Computer Science that deals with mathematical models of computation
---

Finite Automaton
----------------

An abstract machine that can be in exactly one of a finite number of states at
any given time. States are connected by transitions, which may be cyclic.

If $A$ is the set of all inputs that machine $M$ accepts, we say that
$A$ is the *language* of machine $M$ and conversely that $M$
*recognises* $A$. This is represented as $L(M) = A$.

Notice that a machine recognises one language and one language only. Even if
the machine accepts no input, then its language is $\emptyset$. Two
machines are *equivalent* if the recognise the same language.

For any set of states $S$, $E(S)$ is the set of all states that can
be reached by going only through $\varepsilon$ transitions, including
$S$. Consider the following finite automaton:

```ascii
                     +-------+
             b       |       |    a, b
         +---------->|   B   |----------+
@@       |           |       |          |
@@       |           +-------+          |
 |       |                              v
 |   #########                      +-------+
 |   #       #   empty-transition   |       |
 +-->#   A   # -------------------->|   C   |
     #       #                      |       |
     #########                      +-------+
         ^                              |
         |               a              |
         +------------------------------+
```

In this case, $E(\{ A, B \}) = E(\{ A \}) \cup E(\{ B \}) = \{ A, B, C \}$.
Notice that $E(\{ A \}) = \{ A, C \}$ because $A$ is in the argument set, and
from $A$ we can go to $C$ using a $\varepsilon$ transition. Similarly, $E(\{ B
\}) = \{ B \}$ because there is no $\varepsilon$ transition from $B$.

Deterministic Finite Automaton (DFA)
------------------------------------

A finite automaton where each state has unique transitions for any symbol of
the alphabet. A DFA does not allow $\varepsilon$ transitions.

It is formally defined as a 5-tuple $(S, \Sigma, \delta, s_{0}, S_{A})$
where $S$ is a finite set of states along with an error state $s_{e}$,
$\Sigma$ is the set denoting the alphabet, $\delta$ is the transition
function $S \times \Sigma \mapsto S$, $s_{0}$ is the start state such
that $s_{0} \in S$ and $S_{A}$ is the set of *accept states* such that
$S_{A} \subseteq S$.

The transition function maps a state and an alphabet symbol to one next state
(thus its deterministic). This function is total, and maps unspecified
transitions to the $s_{e}$ error state.

We say that a DFA *accepts* a sequence of symbols $w_{1}, w_{2}, ... w_{n}$
if there exists a sequence of states $Q = (q_{0}, q_{1}, ..., q_{n})$
such that $q_{0} = s_{0}$ (the first state is the start state), $q_{n}
\in S_{A}$ (the final state is an accept state), and $\forall r_{i} \in Q
\mid i < n \bullet \delta(r_{i}, w_{i + 1}) = r_{i + 1}$ (each transition is
valid). A machine accepts the $\varepsilon$ word if its initial state is an
accept state: $s_{0} \in S_{A}$.

Consider the following DFA that accepts binary numbers that are multiples of 3:

```ascii
                    1                0
@@           +------------+    +-----------+
@@------+    |            |    |           |
        v    |            v    |           v
       ########          +------+         +------+
 +-----#      #          |      |         |      | -----+
0|     #  S1  #          |  S2  |         |  S3  |      |1
 +---->#      #          |      |         |      | <----+
       ########          +------+         +------+
             ^            |    ^           |
             |            |    |           |
             +------------+    +-----------+
                    1                0
```

This DFA would be formally denoted as $(\{ s_{1}, s_{2}, s_{3}, s_{e} \},
\{ 0, 1 \}, \delta, s_{1}, \{ s_{1} \})$, where $\delta$ is $\{
(s_{1}, 0) \mapsto s_{1}, (s_{1}, 1) \mapsto s_{2}, (s_{2}, 0) \mapsto
s_{3}, (s_{2}, 1) \mapsto s_{e}, (s_{3}, 0) \mapsto s_{2}, (s_{3}, 1)
\mapsto s_{3} \}$.

### Intersection

Given machines $N_{1}$ and $N_{2}$, the intersection of both machines
is the machine $N$ that accepts an input if both $N_{1}$ or $N_{2}$
do.

This is accomplished with the same process we use to convert a DFA into an NFA
with the difference that the final accept states will be the cartesian product
of $N_{1}$ and $N_{2}$ accept states instead of the members of the
resulting states that contain an accept state from either $N_{1}$ or
$N_{2}$.

Non-deterministic Finite Automaton (NFA)
----------------------------------------

A finite automaton that allows more than one transition on the same input
symbol, and that also allows $\varepsilon$ transitions, which can be
fulfilled by any symbol without consuming the input.

Basically, given a state and an input symbol, there can be more than one valid
outbound edge for such symbol, constructing a tree. An NFA *accepts* a sequence
of symbols if at least one of the possible paths accepts such string.

Nondeterminism is a generalization of determinism, so every DFA is
automatically an NFA. Conversely, every NFA can be converted into a DFA.

An NFA is formally defined as a 5-tuple $(S, \Sigma, \delta, s_{0},
S_{A})$ where $S$ is a finite set of states, $\Sigma$ is the set
denoting the alphabet, $\delta$ is the transition function $S \times
\Sigma_{\varepsilon} \mapsto \wp (S)$, $s_{0}$ is the start state such
that $s_{0} \in S$ and $S_{A}$ is the set of *accept states* such that
$S_{A} \subseteq S$.

Notice that this 5-tuple is similar to the one from a DFA, with the following
exceptions:

- The set of states no longer requires a $s_{e}$ error state. Invalid
  transitions can return $\emptyset$
- The transition function may accept $\varepsilon$ as a valid symbol in the
  alphabet, denoted as $\Sigma_{\varepsilon}$
- The transition function returns a set of possible next states instead of just
  one state

Any NFA can be converted to an NFA with just one accept state by creating a new
state that is the *only* accept state, and creating $\varepsilon$
transitions from all previous accept states to the new accept state.

### Union

Given machines $N_{1}$ and $N_{2}$, the union of both machines is the
machine $N$ that accepts an input if either $N_{1}$ or $N_{2}$ do.
This is accomplished by creating a new start state that has $\varepsilon$
transitions to the old start states.

```ascii
@@
@@     +------+       ########
 |     |      |       #      #
 +---->|  p1  |------>#  p2  #
       |      |       #      #
       +------+       ########

@@
@@     +------+       ########
 |     |      |       #      #
 +---->|  q1  |------>#  q2  #
       |      |       #      #
       +------+       ########

                                       +------+     ########
                     empty-transition  |      |     #      #
@@                +------------------->|  p1  |---->#  p2  #
@@     +------+   |                    |      |     #      #
 |     |      |   |                    +------+     ########
 +---->|  n0  |---+
       |      |   |                    +------+     ########
       +------+   |  empty-transition  |      |     #      #
                  +------------------->|  q1  |---->#  q2  #
                                       |      |     #      #
                                       +------+     ########
```

### Concatenation

Given machines $N_{1}$ and $N_{2}$, the concatenation of both machines
is the machine $N$ that accepts an input if $N_{1}$ accepts a prefix of
it, and $N_{2}$ accepts the rest. This is accomplished by creating
$\varepsilon$ transittions between $N_{1}$'s accept states and
$N_{2}$ start state, making $N_{1}$'s start state the only start state,
and making $N_{2}$'s accept states the only accept states.

```ascii
                      ########                          ########
                      #      #                          #      #
@@                +-->#  p2  #    @@                +-->#  q2  #
@@     +------+   |   #      #    @@     +------+   |   #      #
 |     |      |   |   ########     |     |      |   |   ########
 +---->|  p1  |---+                +---->|  q1  |---+
       |      |   |   ########           |      |   |   ########
       +------+   |   #      #           +------+   |   #      #
                  +-->#  p3  #                      +-->#  q3  #
                      #      #                          #      #
                      ########                          ########



                      ########                                         ########
                      #      #  empty-transition                       #      #
@@                +-->#  p2  #--------------------+                +-->#  q2  #
@@     +------+   |   #      #                    |     +------+   |   #      #
 |     |      |   |   ########                    |     |      |   |   ########
 +---->|  p1  |---+                               +---->|  q1  |---+
       |      |   |   ########                    |     |      |   |   ########
       +------+   |   #      #  empty-transition  |     +------+   |   #      #
                  +-->#  p3  #--------------------+                +-->#  q3  #
                      #      #                                         #      #
                      ########                                         ########
```

### Kleene Star

Given machine $N$, $N^{*}$ is the machine that accepts zero or more
iterations of $N$. This is accomplished by creating a new start state that
is an accept state (so that the $\varepsilon$ word is accepted, as it is
always a member of the star set), and has a $\varepsilon$ transition to the
old start state, and creating $\varepsilon$ transitions from previous
accept states back to the old start state.

```ascii
                      ########
                      #      #
@@                +-->#  p2  #
@@     +------+   |   #      #
 |     |      |   |   ########
 +---->|  p1  |---+
       |      |   |   ########
       +------+   |   #      #
                  +-->#  p3  #
                      #      #
                      ########
                                        empty-transition
                                     +--------------------+
                                     |                    |
                                     |          ########  |
                                     |          #      #  |
@@                                   v      +-->#  p2  #--+
@@     ########                  +------+   |   #      #
 |     #      # empty-transition |      |   |   ########
 +---->#  s0  #----------------->|  p1  |---+
       #      #                  |      |   |   ########
       ########                  +------+   |   #      #
                                     ^      +-->#  p3  #--+
                                     |          #      #  |
                                     |          ########  |
                                     |                    |
                                     +--------------------+
                                         empty-transition
```

Generalised Non-deterministic Finite Automaton (GNFA)
-----------------------------------------------------

A GNFA is a NFA where the transitions can be regular expressions instead of
just words from an alphabet, or $\varepsilon$. Therefore, a GNFA reads
blocks of symbols from the input, and not necessarily just one symbol at a time
like other NFAs.

A GNFA is formally defined as a 5-tuple $(S, \Sigma, \delta, s_{0},
S_{A})$ where $S$ is a finite set of states, $\Sigma$ is the set
denoting the alphabet, $\delta$ is the transition function $S \times S
\mapsto \mathcal{R}$, where $\mathcal{R}$ is the set of all regular
expressions over $\Sigma$, $s_{0}$ is the start state such that
$s_{0} \in S$ and $S_{A}$ is the set of *accept states* such that
$S_{A} \subseteq S$.

Notice that given $s_{i} \in S$ and $s_{j} \in S$, $\delta (s_{i},
s_{j}) = R_{k}$ means that the transition between $s_{i}$ and
$s_{j}$ is the regular expression $R_{k}$.

For convenience when converting GNFAs to regular expressions, GNFAs always have
a special form with the following conditions:

- The start state has transition arrows going to every other state but no
  arrows coming in from any state other than itself

- There is only a single accept state, and it has arrows coming in from every
  other state but no arrows going to any other state

- The start state is not the same as the accept state

- Except for the start and accept states, one $\emptyset$ transition goes
  from every state to every other state and also from each state to itself

Notice that we if assume this special form, then the domain of the transition
function is $(S \setminus S_{A}) \times (S \setminus \{ s_{0} \})$.
This is because we don't allow transitions from the accept state to other
states, nor transitions going to the start state.

Every GNFA is equivalent to a GNFA with only two states with a transition that
includes a regular expression that abstracts away any other states and
transitions.

For example, given $\Sigma = \{ a, b \}$:

```ascii
           +---------------------------------------+
           |                  b                    |
           |                                       v
           |                                   ########
           |                  ab U ba          #      #
           |           +---------------------->#  s3  #
           |           |                       #      #
       +------+        |                       ########
@@     |      |        |   empty-set               ^
@@---->|  s0  |--------+------------------+        |
       |      |        |                  |        |
       +------+        |                  v        |b*
           |       +------+           +------+     |
           | ab*   |      |     a*    |      |     |
           +------>|  s1  |---------->|  s2  |-----+
             +---->|      |           |      |<---+
             |     +------+           +------+    |
             | aa  |   ^                  | |   ab|
             +-----+   |      (aa)*       | +-----+
                       +------------------+
```

A GNFA accepts a word $w \in \Sigma^{*}$ if it can be partitioned into a
set of words $w_{1} w_{2} ... w_{i}$ where each partition is a member of
$\Sigma^{*}$ and there exists a sequence of states $s_{0} s_{1} ...
s_{j}$ such that $s_{1}$ is the start state, $s_{j}$ is an accept
state (the only one in the case of a GNFA in the special form), and that
$\delta (s_{i - 1}, s_{i}) = R_{i}$ where $w_{1}$ is a member of the
language such regular expression represents: $w_{i} \in L(R_{i})$.

Basically, there is a sequence of states and regular expression transitions
that consumes the input in chunks, in order, in a way that such computation
ends in an accept state.

Finite State Transducer (FST)
-----------------------------

A type of DFA where the output is a word rather than a boolean accept or reject
result. This DFA has no accept states, and deals with two different alphabets.
A FST *translates* a word from an alphabet to another alphabet.

A FST is formally defined as a 5-tuple $(S, \Sigma, \Gamma, \delta,
s_{0})$ where $S$ is a finite set of states, $\Sigma$ is the input
alphabet, $\Gamma$ is the output alphabet, $\delta$ is the transition
function $S \times \Sigma \mapsto S \times \Gamma$, and $s_{0}$ is the
start state such that $s_{0} \in S$.

Basically, the transition function takes a state and a symbol from the input
alphabet, and returns the next state along with the *translated* symbol from
the output alphabet.

For example, given $\Sigma = \{ a, b \}$ and $\Gamma = \{ 0, 1 \}$:

```ascii
                          b/1
           +-------------------------------+
           |                               |
           +---------------+               |
           |      a/1      |               |
@@         |               v               v
@@     +------+        +------+        +------+
 |     |      |        |      |  a/1   |      |
 +---->|  s1  |        |  s2  |------->|  s3  |
       |      |        |      |        |      |
       +------+        +------+        +------+
           ^             |  ^              |
           |      b/0    |  |     b/1      |
           +-------------+  +--------------+
           |                               |
           +-------------------------------+
                          a/0
```

The transition notation $x / y$ between $s_{i}$ and $s_{j}$ means
that moving between those state takes $x$ from the input alphabet, and will
result in $y$ from the output alphabet. Given the above example, we can
translate `aabb` to `1110`. The transition function is defined as something
like this: $\delta (s_{1}, a) = (s_{2}, 1)$.

Converting an NFA into a DFA
----------------------------

Given an NFA with states $S$, then its corresponding DFA will have $\wp
(S)$ as states (notice it always includes $\emptyset$). Because the DFA
states are the power set of the NFA sets, then given an NFA with $k$
states, then its DFA will have $2^{k}$ states. Notice that we don't need
the error state $s_{e}$ in this case since the $\emptyset$ state will
serve that purpose.

The DFA alphabet is the same as in the NFA, leaving aside the $\varepsilon$
symbol.

In order to calculate the new transition function, we must go through each of
the sets in $\wp (S)$, and for each of those, go through the possible
alphabet symbols (excluding $\varepsilon$), and return the union of all the
valid transitions from each of the states. We can take $\varepsilon$
transitions and return the resulting states as well, but only after consuming
the input symbol.

Given the start state of the NFA is $s_{0}$, the start state of the DFA is
equal to $E(\{ s_{0} \})$.

The DFA accept states are all the members of $\wp (S)$ that contain at
least one of the NFA accept states.

Finally, we can try to simplify the DFA by discarding states that only have
outbound transitions, which means no path can lead into them.

Consider the following NFA:

```ascii
                        a
                      +---+
                      |   |
                      |   v
                     +-----+
             b       |     |    a, b
          +--------->|  B  |---------+
          |          |     |         |
@@        |          +-----+         v
@@     #######                    +-----+
 |     #     #  empty-transition  |     |
 +---->#  A  #------------------->|  C  |
       #     #                    |     |
       #######                    +-----+
          ^                          |
          |           a              |
          +--------------------------+
```

If we build its corresponding DFA, then its states are $\wp (\{ A, B,
C\}) = \{ \emptyset, \{A\}, \{B\}, \{C\}, \{A, B\}, \{A, C\},
\{B, C\}, \{A, B, C\}\}$, the alphabet is $\{ a, b \}$, the start
state is $E(\{ A \}) = \{ A, C \}$, and the accept states are $\{
\{A\}, \{A, B\}, \{A, C\}, \{A, B, C\}\}$.

The transition function looks like this:

| a | b |
|---|---|
| $\delta (\emptyset, a) = \emptyset$ | $\delta (\emptyset, b) = \emptyset$ |
| $\delta (\{ A \}, a) = \emptyset$ | $\delta (\{ A \}, b) = \{ B \}$ |
| $\delta (\{ B \}, a) = \{ B, C \}$ | $\delta (\{ B \}, b) = \{ C \}$ |
| $\delta (\{ C \}, a) = \{ A, C \}$ | $\delta (\{ C \}, b) = \emptyset$ |
| $\delta (\{ A, B \}, a) = \{ B, C\}$ | $\delta (\{ A, B \}, b) = \{ B, C \}$ |
| $\delta (\{ A, C \}, a) = \{ A, C \}$ | $\delta (\{ A, C \}, b) = \{ B \}$ |
| $\delta (\{ B, C \}, a) = \{ A, B, C \}$ | $\delta (\{ B, C \}, b) = \{ C \}$ |
| $\delta (\{ A, B, C \}, a) = \{ A, B, C \}$ | $\delta (\{ A, B, C \}, b) = \{ B, C \}$ |

Notice $\delta (\{ C \}, a) = \{ A, C \}$. From $C$, we can take
the $a$ transition to $A$, and from there we can take $\varepsilon$
back to $C$, so we count $C$ as well.

Also notice that $\delta (\{ A \}, a) = \emptyset$. You might expect
that we can follow $\varepsilon$ to $C$, and from there take $a$
back to $A$, but $\varepsilon$ transitions can only happen after the
input symbol was consumed.

The resulting DFA looks like this:

```ascii
          +--------------------------------------------------------+
          |                           a                            |
          |                                                        |
       #######           #########                                 |
       #     #           #       #               +--------+        |
       # {A} #           # {A,B} #-------+       | a      |        |
       #     #           #       #     a |       |        v        |
       #######           #########       v       |    #########    |
          |                  |       +-------+   |    #       #    |
          +------b-----+     | b     |       |   | +--#{A,B,C}#    |
                       |     +------>| {B,C} |---+ |  #       #    |
                       v             |       |     |  #########    |
                    +-----+          +-------+     |   |     ^     |
                    |     |              | ^       |   |  a  |     |
          +-------->| {B} |---------+    | |       |   +-----+     |
          |  b      |     |     b   |    | +-------+               |
          |         +-----+         |    |     b         +------+  |
      #########                     |    |b              |      |  |
@@    #       #                     v    |      +------->|  {}  |<-+
@@---># {A,C} #<-------+         +-----+ |      |   +----|      |----+
      #       #        | a       |     | |      |   |    +------+    |
      #########        +---------| {C} |<+      |   |      ^  ^      |
       |     ^                   |     |        |   |  a   |  |   b  |
       |  a  |                   +-----+        |   +------+  +------+
       +-----+                      |           |
                                    |        b  |
                                    +-----------+
```

Removing states with only outbound transitions results in:

```ascii
                                                 +--------+
                                                 | a      |
                                                 |        v
                                                 |    #########
                                     +-------+   |    #       #
                             a       |       |   | +--#{A,B,C}#
                       +------------>| {B,C} |---+ |  #       #
                       |             |       |     |  #########
                    +-----+          +-------+     |   |     ^
                    |     |              | ^       |   |  a  |
          +-------->| {B} |---------+    | |       |   +-----+
          |  b      |     |     b   |    | +-------+
          |         +-----+         |    |     b         +------+
      #########                     |    |b              |      |
@@    #       #                     v    |      +------->|  {}  |
@@---># {A,C} #<-------+         +-----+ |      |   +----|      |----+
      #       #        | a       |     | |      |   |    +------+    |
      #########        +---------| {C} |<+      |   |      ^  ^      |
       |     ^                   |     |        |   |  a   |  |   b  |
       |  a  |                   +-----+        |   +------+  +------+
       +-----+                      |           |
                                    |        b  |
                                    +-----------+
```

Converting an DFA into a GNFA
-----------------------------

Add a new start state with an $\varepsilon$ transition to the old start
state, then add one single new accept state and create $\varepsilon$
transitions to it from all old accept states. At this point, if any transitions
have multiple labels or there is more than one transition in the same directory
between two states, replace them with a single transition whose label is the
union of the previous labels. Finally, add $\emptyset$ transitions between
all states (except the start and final state).

Converting a GNFA into a Regular Expression
-------------------------------------------

This conversion algorithm assumes the GNFA is the special form. A GNFA in this
form has $k \geq 2$ states, since it always has a start and acceptt state
that are ensured to be different. The idea is that while $k > 2$, we can
pick any state that is not the start or the accept state, remove it, and "fix"
the broken transitions by abstracting the removed computation as regular
expressions. Once $k = 2$, the regular expression in the transition between
the start and the final state is the result.

Consider the following automata:

```ascii
+------+                +------+
|      |       R1       |      |
|  s1  |--------------->|  s2  |
|      |                |      |
+------+                +------+
    |       +------+        ^
    | R2    |      |     R3 |
    +------>|  s3  |--------+
            |      |
            +------+
             |    ^
             | R4 |
             +----+
```

We will remove $s_{3}$. The computation between $s_{1}$ and $s_{2}$
that went through $s_{3}$ can be summarized as: $R_{2}$, then zero or
more $R_{4}$, and finally $R_{3}$. In regular expression terms, this
would be $R_{2} \circ R_{4}^{*} \circ R_{3}$, so:

```ascii
+------+                +------+
|      |       R1       |      |
|  s1  |--------------->|  s2  |
|      |                |      |
+------+                +------+
    |                       ^
    |       R2 R4* R3       |
    +-----------------------+
```

Now we have two transitions from the same states, which we can collapse using
the union operator: $(R_{2} \circ R_{4}^{*} \circ R_{3}) \cup R_{1}$.

Notice that because of the *pumping lemma*, we can represent any regular
language as $xy^{*}z$, and therefore any sub-tree of a finite automata.
Thus, the removal of any state can be resolved with the concatenation of, the
transition going to the removed state ($x$), is the transition going from
the removed state to itself ($y^{*}$), and the transition going from the
removed state to the next state. Finally, we calculate the union of this
resulting expression and any other transition between the state that goes to
the removed state to the state after the removed state.

Formally, assume $(S, \Sigma, \delta, s_{0}, S_{A})$ and $s_{rip} \in
S$ where $s_{rip} \notin S_{A}$ and $s_{rip} \neq s_{0}$. The
resulting GNFA with $s_{rip}$ is $(S', \Sigma, \delta', s_{0},
S_{A})$, where $S' = S \setminus \{ s_{rip} \}$ and for any $s_{i}
\in S' \setminus S_{A}$ and any $s_{j} \in S' \setminus \{ s_{0}\}$,
$\delta'(s_{i}, s_{j}) = (R_{1} R_{2}^{*} R_{3}) \cup R_{4}$ where
$R_{1} = \delta(s_{i}, s_{rip})$, $R_{2} = \delta(s_{rip},
s_{rip})$, $R_{3} = \delta (s_{rip}, s_{j})$, and $R_{4} =
\delta(s_{i}, s_{j})$.

Converting a Regular Expression into an NFA
-------------------------------------------

Consider the regular expression $R$. We will use the 6-clause definition of
a regular expression, and discuss them in order.

If $R = a$ where $a \in \Sigma$, then the language of the regular
expression is the set containing just the $a$ symbol: $L(R) = \{ a
\}$. The resulting NFA is then $(\{ s_{0}, s_{1} \}, \Sigma, \delta,
s_{0}, \{ s_{1} \})$ where $\delta(s_{0}, a) = s_{1}$ and $\forall
x \in Sigma \mid x \neq a \bullet \delta(s_{0}, x) = \emptyset$:

```ascii
        +------+      ########
@@      |      |  a   #      #
@@----->|  s0  |----->#  s1  #
        |      |      #      #
        +------+      ########
```

If $R = \varepsilon$, then $L(R) = \{ \varepsilon \}$, so the
resulting NFA is $(\{s_{0}\}, \Sigma, \delta, s_{0}, \{s_{0}\})$
where $\forall x \in \Sigma \bullet \delta(s_{0}, x) = \emptyset$:

```ascii
         ########
@@       #      #
@@-----> #  s0  #
         #      #
         ########
```

If $R = \emptyset$, then $L(R) = \emptyset$, so the resulting NFA is
$(\{s_{0}\}, \Sigma, \delta, s_{0}, \emptyset)$ where $\forall x \in
\Sigma \bullet \delta(s_{0}, x) = \emptyset$:

```ascii
         +------+
@@       |      |
@@-----> |  s0  |
         |      |
         +------+
```

For the last 3 cases, where $R$ is the union or concatenation between other
regular expressions, and where $R$ is the Kleene star of a regular
expression, we convert each of the operands to NFAs using the definitions
described before, and then use the standard way to represent union,
concatenation, or stars of NFAs (consult the *Operations* section).

Consider $(ab \cup a)^{*}$ as a complete example. First, lets convert
$a$ and $b$ into NFAs:

```ascii
        +------+      ########
@@      |      |  a   #      #
@@----->|  s0  |----->#  s1  #
        |      |      #      #
        +------+      ########

        +------+      ########
@@      |      |  b   #      #
@@----->|  s2  |----->#  s3  #
        |      |      #      #
        +------+      ########
```

The expression $ab$ is the concatenation of both previous expressions,
which is:

```ascii
        +------+      +------+                  +------+      ########
@@      |      |  a   |      | empty-transition |      |  b   #      #
@@----->|  s0  |----->|  s1  |----------------->|  s2  |----->#  s3  #
        |      |      |      |                  |      |      #      #
        +------+      +------+                  +------+      ########
```

The expression $ab \cup a$ is the union of the previous NFA and $a$'s
NFA:

```ascii
                      +------+      +------+
     empty-transition |      |  a   |      | empty-transition
         +----------->|  s1  |----->|  s2  |------+
         |            |      |      |      |      |      +------+      ########
     +------+         +------+      +------+      |      |      |  b   #      #
@@   |      |                                     +----->|  s3  |----->#  s4  #
@@-->|  s0  |                                            |      |      #      #
     |      |                                            +------+      ########
     +------+         +------+      ########
         |            |      |  a   #      #
         +----------->|  s5  |----->#  s6  #
     empty-transition |      |      #      #
                      +------+      ########
```

Finally, we calculate the Kleene star of the whole previous NFA:

```ascii
                                    +------+       +------+
                   empty-transition |      |   a   |      |  empty-transition
                              +---->|  s2  |------>|  s3  |------+
                              |     |      |       |      |      |      +------+
 @@                           |     +------+       +------+      |      |      |
 @@-+                         |                                  +----->|  s4  |
    v                         |                                         |      |
+------+                  +------+                +------+     ######## +------+
|      | empty-transition |      |empty-transition|      |  a  #      #     |
|  s0  |----------------->|  s1  |--------------->|  s6  |---->#  s7  #     |  b
|      |                  |      |                |      |     #      #     v
+------+                  +------+                +------+     ######## ########
                              ^                                    |    #      #
                              |                                    |    #  s5  #
                              +------------------------------------+    #      #
                              |          empty-transition               ########
                              |                                             |
                              |                                             |
                              +---------------------------------------------+
                                                empty-transition
```

Converting a DFA into a Regular Expression
------------------------------------------

We have to first convert the DFA into a GNFA, and then convert the GNFA into a
regular expression, using the mechanisms described before.

Regular Expressions
-------------------

$R$ is a regular expression if $R$ is the language containing one
symbol $s$ from an alphabet $\Sigma$, $R = \{ \varepsilon \}$,
$R = \emptyset$, the union or concatenation between two regular
expressions, or the Kleene star of a regular expression.

Notice the regular expression $\varepsilon$ denotes the language containing
just the empty string, while $\emptyset$ denotes the language that does not
contain any string.

Any regular expression can be converted into a finite automaton that recognizes
the language it describes, and vice versa. If a language can be described by a
regular expression, then it is a regular language.

Words
-----

A word is a member of language, and consists of symbols that are part of an
alphabet.

### Cardinality

Given a word $s$ from a language $A$, the "length" of $s$ is
denoted as $| s |$. Given $\Sigma = \{ 0, 1 \}$ and $s = 001100$,
$| s | = 6$.

### Reverse

Given a word $w = w_{1}w_{2} ... w_{n}$, the reverse of the word is
$w^{\mathcal{R}}$ equals $w_{n} ... w_{2}, w_{1}$.

Regular Languages
-----------------

A language is called a regular language if and only if there exists a
non-deterministic finite automaton that recognises it.

### Union

Given two regular languages $A$ and $B$, the union of both languages is
represented as $A \cup B = \{ x \mid x \in A \lor x \in B \}$, and it
gives us a language containing all the words for both $A$ and $B$. The
union of two regular languages is a regular language.

For example, given $A = \{ foo, bar\}$ and $B = \{ baz, qux\}$,
then $A \cup B = \{ foo, bar, baz, qux \}$.

For convenience, given words $s_{1}$ and $s_{2}$, $s_{1} \cup
s_{2}$ is a shorthand for $\{s_{1}\} \cup \{s_{2}\}$.

Notice $A \cup \emptyset = A$, but $A \cup \varepsilon$ might not
always equal $A$.

### Concatenation

Given two regular languages $A$ and $B$, the concatenation of both
languages is represented as $A \circ B = \{ xy \mid x \in A \land x \in B
\}$, and it gives us a language containing all possible combinations of
words in $A$ before words in $B$, and viceversa, like a cartesian
product. The concatenation of two regular languages is a regular language.

For example, given $A = \{ foo, bar\}$ and $B = \{ baz, qux\}$,
then $A \circ B = \{ foobaz, fooqux, barbaz, barqux \}$.

For convenience, given words $s_{1}$ and $s_{2}$, both $s_{1} \circ
s_{2}$ and $s_{1} s_{2}$ are shorthands for $\{s_{1}\} \circ
\{s_{2}\}$.

Concatenating any set to the empty set yields the empty set: $x \circ
\emptyset = \emptyset$. Also $A \circ \varepsilon = A$, but $A \circ
\emptyset$ might not always equal $A$.

### Kleene Star

This is a unary operation that given a language $A$, equals an infinite set
of all the possible combinations of words in $A$. It is defined as $A^{*}
= \{x_{1}x_{2} ... x_{k} \mid k \geq 0 \land x_{i} \in A\}$. For any
language, $\varepsilon$ is a member of the star result. The Kleene star of
a regular language is a regular language. Notice that $\emptyset^{*} = \{
\varepsilon \}$.

For example, given $A = \{ foo, bar\}$, $A^{*} = \{ \varepsilon, foo,
bar, foofoo, foobar, barbar, barfoo, foofoofoo, foofoobar, ... \}$.

For convenience, given a word $s$, $s^{*}$ is a shorthand for
$\{s\}^{*}$.

Given alphabet $\Sigma$, $\Sigma^{*}$ is the language consisting of all
strings over such alphabet.

As an extension to the Kleene star operator, we can define $s^{+} = s \circ
s^{*}$. Also, $s^{*} = s^{+} \cup \varepsilon$. Notice that given a
language $A$, $A = A^{+} \iff A \circ A \subseteq A$.

Notice that $\emptyset^{*} = \{ \varepsilon \}$. This means "nothing"
zero or more times. The zero part of it comes down to $\varepsilon$.
*Nothing* two times is $\emptyset \circ \emptyset$, which is
$\emptyset$.

### Reverse

The reverse of a language is the language with all its words reserved. Given
$A$, the reverse version of the language is $A^{\mathcal{R}} = \{
w^{\mathcal{R}} \mid w \in A \}$. If $A$ is regular, so is
$A^{\mathcal{R}}$.

References
----------

- [Introduction to the Theory of Computation, 3rd Edition](https://www.amazon.com/Introduction-Theory-Computation-Michael-Sipser/dp/113318779X)
