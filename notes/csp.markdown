---
title: Communicating Sequential Processes
description: A formal language for describing concurrent systems
---

Processes
---------

A process represents the behaviour pattern of an object. It consists of an
alphabet, which is the set of the possible atomic events an object can engage
on. There is no distinction between events originated by the user of the
object or by the object itself.

The alphabet of process $P$ is denoted as $\alpha P$ and the set of
traces of $P$ is denoted as $traces(P)$. Two processes are considered
*independent* if their alphabets are disjoint.

A process can be defined in terms of itself, like $CLOCK = (tick \rightarrow
CLOCK)$.

A process can be defined as a function $f : \Sigma \rightarrow (\Sigma, T)$
that takes an event and results in a process, and where its domain must be a
subset of the alphabet. The function may return $STOP_{\Sigma}$ to
represent termination.

Two processes are equal if their event choices are the same and each resulting
process is the same. The processes $(x : A \rightarrow f(x))$ and $(y : B
\rightarrow g(y))$ are the same if $A = B \land \forall  z \in A
\bullet f(z) = g(z)$.

If two objects define the same process, then they are considered equal,
therefore there exists only one object that defines a process. A more formal
definition for a process such as $CLOCK = (tick \rightarrow CLOCK)$ is
$CLOCK = \mu X : \{ tick \} \bullet (tick \rightarrow X)$. Given a function
$f$ that maps an event to a process, the unique-type definition can be
generalized as $\mu X : \Sigma \bullet (y : \Sigma \rightarrow f(y, X))$,
where the second argument to $f$ is the process itself, in order to support
recursion.

### Operators

The *prefix* operator ($\rightarrow$) takes an event and a process and
describes the process that engages in a given event and then behaves like the
subsequent process, for example $(x \rightarrow P)$. Notice that $(x
\rightarrow y \rightarrow z \rightarrow P)$ is equivalent to $(x
\rightarrow (y \rightarrow (z \rightarrow P)))$.

The *choice* operator ($\mid$) takes two prefix applications (its not an
operation on processes) and describes a process that has a choice over what
event to engage on, for example $(x \rightarrow P \mid y \rightarrow Q)$.
Notice that $(x \rightarrow P \mid y \rightarrow Q) = (y \rightarrow Q \mid x
\rightarrow P)$. The events on the involved prefixes must be different, as
$(x \rightarrow P \mid x \rightarrow Q)$ is considered invalid.

The alphabet of the resulting process consists of the prefix events and the
alphabets of the involved processes: $\alpha(x \rightarrow P \mid y
\rightarrow Q) = \{ x, y \} \cup \alpha P \cup \alpha Q$.

There exists a shorthand to define choices over a set. Given $A = \{ foo,
bar \}$, the shorthand $(e: A \rightarrow P)$ evaluates to $(foo
\rightarrow P \mid bar \rightarrow P)$. If the set of choices is the empty
set, the resulting process is the broken process. Given $(x : B \rightarrow
P(x))$, if $B \subseteq A$ where $A = \alpha P(x)$ for all $x$,
then $\alpha (x : B \rightarrow P(x)) = A$.

A process $P$ is a subset of process $Q$ if they share the same
alphabets and the traces of $P$ can all be consumed by $Q$. This is
denoted as: $P \sqsubseteq Q = (\alpha P = \alpha Q) \land (traces(P)
\subseteq traces(Q))$. Of course, $P \sqsubseteq P$. If two processes are
subsets of each other, then they must be equal: $P \sqsubseteq Q \land Q
\sqsubseteq P \implies P = Q$. The subset operation is transitive: $P
\sqsubseteq Q \land Q \sqsubseteq R \implies P \sqsubseteq R$. Finally, a
process is always the superset of its broken process: $STOP_{\alpha P}
\sqsubseteq P$.

Given a variable $b$ that is either $true$ or $false$, the process
$(P {<|} \; b \mid> Q)$ behaves like
$P$ if $b = true$, and like $Q$ otherwise. This operator obeys the
following laws:

- $(P {<|}\; true
  \; {|>} Q) = P$
- $(P {<|}\; false
  \; {|>} Q) = Q$

- $(P {<|}\; \lnot b
  \; {|>} Q) = (Q {<|}\;
  b \; {|>} P)$

- $(P {<|}\; b \; {|>}
  (Q {<|}\; b \; {|>}
  R)) = (P {<|}\; b
  \; {|>} R)$

- $(P {<|}\; (a
  {<|}\; b \; {|>} c)
  \; {|>} Q) = ((P
  {<|}\; a \; {|>} Q)
  {<|}\; b \; {|>} (P
  {<|}\; c \; {|>}
  R))$

- $(P {<|}\; b \; {|>}
  Q)  ;  R = (P  ;  R)
  {<|}\; b \; {|>} (Q
   ;  R)$

Given a boolean expression $b$ and a process $P$, the process $(b *
P)$ is the machine that restarts $P$ while $b$ is $true$: $(b *
P) = \mu X \bullet ((P  ;  X)
{<|}\; b \; {|>}
SKIP_{\alpha P})$.

### Process Mapping (or Change of Symbol)

Given a function $f$ that maps the alphabet (takes the alphabet of a
process and returns a new set of the same size), a process $P$, and an
event $x \in \alpha P$, then $f(P)$ represents the process that engages
in $f(x)$ (the actual function application) whenever $P$ engages in
$x$. The function must be *injective*, so that $f^{-1}$ makes
functional sense.

It follows that $\alpha f(P) = f(\alpha P)$. The traces of the mapped
process are $traces(f(P)) = \{  f^{*}(t) \mid t \in traces(P)
 \}$. Notice the mapping function always preserves the broken
process, as in that case it would map over an empty list of choices: $\forall
P \bullet f(STOP_{\alpha P}) = STOP_{\alpha f(P)}$.

Notice that process mapping distributes over the composition operator: $f(P
\parallel Q) = f(P) \parallel f(Q)$. When it comes to consuming a trace
$t$, then $f(P)  /  f^{*}(t) = f(P  /
 t)$.

Given the choices shorthand definition of a process non-recursive process:
$f(x : A \rightarrow P(x)) = (y : f(A) \rightarrow f(P(f^{-1}(y))))$.

For example, consider $CLOCK = (tick \rightarrow CLOCK)$ and $f(tick) =
tock$. In that case, $f(CLOCK) = (tock \rightarrow f(CLOCK))$.

Given a sequential process $P$, then $f(\checkmark) = \checkmark$ must
hold.

Given an arbitrary interleaving $(P \sqcap Q)$, $f(P \sqcap Q) = (f(P)
\sqcap f(Q))$.

A process defined by mapping diverges when its original process diverges. Given
$f$ and $P$, $divergences(f(P)) = \{ f^{*}(s) \mid s \in
divergences(P) \}$.

The failures of a mapped process are defined as $failures(f(P)) = \{
(f^{*}(s), f(X)) \mid (s, X) \in failures(P) \}$. The refusals of a mapped
process are defined as $refusals(f(P)) = \{ f(X) \mid X \in refusals(P)
\}$.

Concealing a mapped process is defined as $f(P \setminus C) = (f(P) \setminus
f(C))$.

### Process Labelling

Labelling is a mapping technique to add prefix to all the events of a process.
Its useful when constructing groups of processes, and where we need to make
sure that they are independent (that their alphabets are disjoint). Process
$P$ labelled with $foo$ is denoted as $foo : P$. The prefix is
added before every event, separated by a period.

For any prefix $p$, there exists a function $label_{p}(e) = p.e$. The
labelled process $p : Q$ is equivalent to $label_{p}(Q)$. Notice
labelling changes the alphabet: $\alpha Q \neq \alpha (p : Q)$.

For example, consider $CLOCK = (tick \rightarrow CLOCK)$. In that case,
$foo : CLOCK = (foo.tick \rightarrow CLOCK)$.

### Concealment

Concealment creates a new process that behaves like the new process but with
certain events being hidden. This operation reduces the alphabet of a process
and may introduce non-determinism. Concealing an infinite sequence of
consecutive events leads to divergence.

This operation is defined as $((x \rightarrow P) \setminus C) = (x
\rightarrow (P \setminus C))$ if $x \notin C$, and as $((x \rightarrow
P) \setminus C) = (P \setminus C)$ otherwise. Given the choice shorthand
definition $(x : B \rightarrow P(x))$, concealing such process with $C$
expands to $(x : B \rightarrow (P(x) \setminus C))$ if $B \cap C =
\emptyset$, otherwise it expands to $(Q \sqcap (Q  \square
 (x : (B - C) \rightarrow P(x))))$ where $Q = \sqcap_{x \in B
\cap C} (P(x) \setminus C)$, which introduces non-determinism.

The alphabet of a concealed process is $\alpha (P \setminus C) = \alpha P -
C$. The traces of a concealed process are defined as $traces(P \setminus C)
= \{ t \restriction (\alpha P - C) \mid t \in traces(P) \}$. The following
laws apply: $(P \setminus \emptyset) = P$ and $((P \setminus B) \setminus
C) = (P \setminus (B \cup C))$.

Given a concealed process, its divergences consist its original divergences
plus the new ones potentially created by the concealment operation:

$$\begin{align}
divergences(P \setminus C) &= \{ (s \restriction (\alpha P - C)) \frown t
 \mid \\
&t \in (\alpha P - C)^{*} \land (s \in divergences(P) \\
&\lor (\forall n \bullet \exists u \in C^{*} \bullet \#u > n \land (s \frown u) \in traces(P))) \}
\end{align}$$

The alphabet of a concealed process is defined as $\alpha (P \setminus C) =
\alpha P - C$.

The failures of a concealed process are defined as:

$$\begin{align}
failures(P \setminus C) = \{ &(s \restriction (\alpha P - C), X) \mid (s, X
\cup C) \in failures(P) \} \\
&\cup \{ (s, X) \mid s \in divergences(P \setminus C) \}
\end{align}$$

### Subordination

Given $(P \parallel Q)$, $P$ is a *slave* or *subordinate* process of
$Q$ if $\alpha P \subseteq \alpha Q$, as each action of $P$ can
occur if $Q$ permits it, while $Q$ can freely engage on events of its
own (where $\alpha Q - \alpha P$). If we want to conceal communication
between master and subordinate, then we can use the notation $(P
//  Q) = (P \parallel Q) \setminus \alpha P$. Its alphabet is
$\alpha (P  //  Q) = (\alpha Q - \alpha P)$.

The subordinated process can be given a name in which case the master will
communicate with it using a compound channel name, while the subordinated
process will communicate with its master through a normal channel pair name.
The benefit is that all communication between the master and the subordinate
can't be detected from outside as the new subordinate name acts as a local
variable for the master.

For example, $(m : P  //  Q(v)) = (m : (c!v \rightarrow
P)  //  (m.c?x \rightarrow Q(x)))$. Also consider $(n :
(m : (P  //  Q)  //  R))$. In this
case, there is no way $R$ can communicate with $P$ as it doesn't know
about its existance or about its name, $m$.

- Only the master process can make a choice for the subordinate: $(m : (c?x
  \rightarrow P_{1}(x) \mid d?y \rightarrow P_{2}(y)))  //
  (m.c!v \rightarrow Q) = (m : P_{1}(v)  //  Q)$
- The order in which subordinate processes are declared doesn't matter: $(m :
  P  //  (n : Q  //  R)) = (n : Q
   //  (m : P  //  R))$
- The master may communicate with other processes, and such communication is
  left outside the subordination: $(m : P  //  (b!e
  \rightarrow Q)) = (b!e \rightarrow (m : P  //  Q))$

Communication from the master to the slave looks like this: $(m : (c?x
\rightarrow P(x)))  //  (m.c!v \rightarrow Q) = (m : P(v))
 //  Q$. Conversely, communication from the slave to the
master: $(m : (d!v \rightarrow P))  //  (m.d?x
\rightarrow Q(x)) = (m : P)  //  Q(v)$.

### Communication

Communication between processes is done using events that sets *values* on
*channels*. This is described by the pair $c.v$ where $channel(c.v) =
c$ and $message(c.v) = v$ or the triplet $m.c.v$ which includes the
process as a prefix (a compound channel name). Notice that $m.\checkmark =
\checkmark$ for any $m$. A channel used by $P$ only to send events is
an *output channel* of $P$. A channel used by $P$ only to receive
events is an *input channel* of $P$.

Communication is *unidirectional* and only between two processes.
Communication between two processes can only happen if both processes engage in
the communication: one listens on a channel while the other one sends a message
through that channel.

The set of all values that process $P$ can communicate on a channel $c$
is the alphabet of the channel: $\alpha c(P) = \{ message(c.v) \mid c.v \in
\alpha P \}$. Given a compound channel name, $\alpha  m.c(m : P)
= \alpha  c(P)$. Communication event pairs must be part of the
alphabet of a process. For two processes to communicate over a channel $c$,
they need to share the same alphabet on such channel: $\alpha c(P) = \alpha
c(Q)$. Given $P$ and $Q$ communicate over channel $c$, all the
possible communication events are inside $\alpha P \cap \alpha Q$.

Given proces $P$, the event $c!v$ sends value $v$ over channel
$c$. For this to be valid, $v \in \alpha c(P)$. This event is defined
as $(c!v \rightarrow P) = (c.v \rightarrow P)$. The communication message
can be a more complex expression: $c!(x + y)$. The event to wait for a
value on a channel is $c?x$, where $x$ takes the value of the received
message. This is defined as a choice over all the valid communication events of
that channel: $(c?x \rightarrow P(x)) = (e : \{ c \mid channel(e) = c \})
\rightarrow P(message(e))$. A process can wait in more than one channel
using the choice operator: $(c?x \rightarrow P(x) \mid d?y \rightarrow
Q(y))$.

### Variables

$(x := e)$ is the process that sets $x$ to $e$. Its defined as
$(x := e) = (x := e  ;  SKIP)$. It follows that $(x
:= x) = SKIP$ and that $(x := e  ;  x := f(x)) = (x :=
f(e))$. The assignment operator can be used with multiple variables: $(x,
y, z := e, f, g)$ but keep in mind that $(x := f  ;  y
:= g) \neq (x, y := f, g)$ as in the first case $g$ may depend on the new
value of $x$. With regards to the conditional operator: $(x := e
 ;  (P {<|}\; b(x)
\; {|>} Q)) = ((x := e  ;  P)
{<|}\; b(x) \; {|>} (x
:= e  ;  Q))$.

Given a process $P$, $var(P)$ is the set of all variables that can be
assigned within $P$, and $acc(P)$ is the set of all the variables that
$P$ can access. Of course, all variables that can be set can be accessed:
$var(P) \subseteq acc(P)$. Both sets are subsets of $\alpha P$.

No variable assigned in a process can be accessed by another concurrent
process, so given $P$ and $Q$, then $var(P) \cap acc(Q) = var(Q) \cap
acc(P) = \emptyset$.

### Deterministic Processes

A deterministic process is a tuple $(\Sigma, T)$ consisting of two sets: an
alphabet and a set of traces. These laws must be satisfied for a deterministic
process to be valid:

- $\langle \rangle \in T$: the empty trace is valid on every process
- $\forall s, t \in seq \bullet s \frown t \in T \implies s \in T$: if a
  trace is valid in a process, then any prefix of the trace is also valid in
  the process
- $T \subseteq \Sigma^{*}$: all traces consist of elements of the alphabet

A process $P$ is deterministic if it can't refuse any event in which it can
engage: $\forall s \in traces(P) \bullet X \in refusals(P  /
 s) \iff (X \cap \{ x \mid \langle x \rangle \in traces(P
/  s) \} = \emptyset)$.

Deterministic processes can unambiguously pick between events whenever there is
a choice. These processes obey an extra law: given $P$ then, $P \parallel
P = P$.

The process that results by making a process consume a trace is a process with
the same alphabet, and with all traces whose prefixes were consumed. Given
process $(\Sigma, T)$ and $s \in T$, then $(\Sigma, T)  /
 s = (\Sigma, \{ t \mid (s \frown t) \in T\})$. Of course, $(x
\rightarrow P)  /  \langle x \rangle = P$, and given a
function definition, $(x : A \rightarrow f(x))  /
\langle y \rangle = f(y)$ assuming $y \in A$.

The choice prefix shorthand notation works like this: given an alphabet
$\Sigma$, a set of choices $A \subseteq \Sigma$, and a function $f$
that maps over the set of traces, then $(x : A \rightarrow (\Sigma, f(x))) =
(\Sigma, \{ \langle \rangle \} \cup \{ \langle x \rangle \frown s \mid x \in
A \land s \in f(x) \})$.

The process mapping operation using a function $f$ is defined as
$f((\Sigma, T)) = (ran(f), \{ f^{*}(t) \mid t \in T \})$.

#### Special Processes

Every alphabet has a *broken process* that never engages in any event. Given
alphabet $\Sigma$, the broken process is $STOP_{\Sigma} = (\Sigma, \{
\langle \rangle \})$. Processes with different alphabets are always
considered to be different, so given alphabets $A$ and $B$, if $A
\neq B$, then $STOP_{A} \neq STOP_{B}$. The traces of the broken object
are defined as $traces(STOP_{\Sigma}) = \{ \langle \rangle \}$.

Every alphabet has a *run process* that can always engage, at any given point,
in any event of its alphabet. Given alphabet $\Sigma$, the run process is
$RUN_{\Sigma} = (\Sigma, \Sigma^{*})$, or alternatively $(x : \Sigma
\rightarrow RUN_{\Sigma})$, and it follows that $\alpha RUN_{\Sigma} =
\Sigma$. Notice that the run process behaves like a restart process:
$\forall s \in traces(RUN_{\Sigma}) \bullet \overset{\frown}{RUN_{\Sigma}}
 /  (s \frown \langle \downarrow \rangle) =
\overset{\frown}{RUN_{\Sigma}}$.

Given alphabet $\Sigma$, the $SKIP_{\Sigma}$ process does nothing and
terminates successfully: $\alpha SKIP_{\Sigma} = \Sigma \cup \{ \checkmark
\}$. A process can terminate successfully by behaving like $SKIP$.
Notice $SKIP_{A} \parallel SKIP_{B} = SKIP_{A \cup B}$. Its traces are
$traces(SKIP_{\Sigma}) = \{ \langle \rangle, \langle \checkmark \rangle
\}$.

Concealing the broken process results in the broken process: $\forall X, Y
\bullet STOP_{X} \setminus Y = STOP_{X - Y}$.

#### Properties

A process is *cyclic* if in all circumstances it can go back to its original
state. Given process $P$, then $\forall  s \in traces(P) \bullet
\exists  t \bullet P  /  (s \frown t) = P$. The
*broken process* is a simple example.

A process $P$ is *free from deadlocks* if none of its traces lead to the
broken object: $\forall  t \in traces(P) \bullet (P  /
 t) \neq STOP_{\alpha P}$.

### Non-deterministic Processes

A non-deterministic process is defined as a triplet $\Sigma, F, D$ that
stands for the process alphabet, its failures, as a relation $F \subseteq
(\Sigma^{*} \times \wp(\Sigma))$ where $(\langle \rangle, \emptyset) \in
F$, and a set of divergences where $D \subseteq \Sigma^{*}$ and $D
\subseteq dom(F)$. The following laws must hold:

- $(s \frown t, X) \in F \implies (s, \emptyset) \in F$
- $(s, Y) \in F \land X \subseteq Y \implies (s, X) \in F$
- $(s, X) \in F \land x \in A \implies (s, X \cup \{ x \}) \in F \land (s
  \frown \langle x \rangle, \emptyset) \in F$
- $s \in D \land t \in \Sigma^{*} \implies s \frown t \in D$
- $s \in D \land X \subseteq \Sigma \implies (s, X) \in F$

Given $P = (\Sigma, F_1, D_1)$ and $Q = (\Sigma, F_2, D_2)$, the
$\sqsubseteq$ operator is defined as $(P \sqsubseteq Q) \iff (F_2
\subseteq F_1) \land (D_2 \subseteq D_1)$.

#### Failures

The failures relation over $(\Sigma^{*} \times \wp(\Sigma))$ is defined as
$failures(P) = \{ (s, X) \mid s \in traces(P) \land X \in refusals(P
 /  s) \}$. If $(s, X)$ is a failure of $P$ then
it means that $P$ will refuse $X$ after engaging in $s$.
Alternatively:

$$\begin{align}
failures(x : B &\rightarrow P(x)) = \\
&\{ (\langle \rangle, X) \mid X \subseteq (\alpha P - B)\} \\
&\cup \\
&\{ (\langle x \rangle \frown s, X)
\mid x \in B \land (s, x) \in failures(P(x)) \}
\end{align}$$

Its interesting that the traces of a process $P$ can be defined in terms of
its failures: $traces(P) = dom(failures(P))$.

#### Divergences

A trace of a process after which the process behaves chaotically is called a
*divergence* of the process: $divergences(P) = \{ s \mid s \in traces(P)
\land ((P  /  s) = CHAOS_{\alpha P} ) \}$. Of course,
$divergences(P) \subseteq traces(P)$. Anything concatenated to a divergence
is also a divergence: $s \in divergences(P) \land t \in (\alpha P)^{*}
\implies (s \frown t) \in divergences(P)$. After engaging on a divergence, a
process refuses everything: $s \in divergences(P) \implies refusals(P
 /  s) = \wp(\alpha P)$.

A process defined by choice can't diverge on its first event, so its
divergences are defined by what happens after it: $divergences(x : B
\rightarrow P(x)) = \{ \langle x \rangle \frown s \mid x \in B \land s \in
divergences(P(x)) \}$.

#### Refusals

The refusals of a process $P$ are defined as $refusals(P) = \{ x \mid
(\langle \rangle, X) \in failures(P) \}$. Given a process defined by prefix,
such process refuses all events that it can't engage in: $refusals(x : B
\rightarrow P(x)) = \{ X \mid X \subseteq (\alpha P - B) \}$.

For any process $P$, $X \in refusals(P) \implies X \subseteq \alpha P$
and $\emptyset \in refusals(P)$.  If a process refuses a set, then it can
refuse any of its subsets: $(X \cup Y) \in refusals(P) \implies X \in
refusals(P)$. Also, any event that can't initially occur in a process can be
added to an existing refusal, and the result will remain a refusal: $X \in
refusals(P) \implies \forall x \in \alpha P \bullet (X \cup \{ x \}) \in
refusals(P) \lor \langle x \rangle \in traces(P)$.

#### Choices

Given processes $P$ and $Q$ where $\alpha P = \alpha Q$, $(P
\sqcap Q)$ is the process that behaves either like $P$ or like $Q$
where the selection between them is non-deterministic.

If $P = (\Sigma, F_1, D_1)$ and $Q = (\Sigma, F_2, D_2)$, then $(P
\sqcap Q) = (\Sigma, F_1 \cup F_2, D_1 \cup D_2)$. Then $\alpha (P \sqcap
Q) = \alpha P = \alpha Q$ and $(x \rightarrow (P \sqcap Q)) = ((x
\rightarrow P) \sqcap (x \rightarrow Q))$, or more generally: $(x : B
\rightarrow (P(x) \sqcap Q(x))) = ((x : B \rightarrow P(x)) \sqcap (x : B
\rightarrow Q(x)))$.  The $\sqcap_{x : S}P(x)$ notation stands for
$(P(x_0) \sqcap P(x_1) \sqcap P(x_2) \sqcap ...)$.

Its traces are defined as $traces(P \sqcap Q) = traces(P) \cup traces(Q)$
where given $s \in traces(P \sqcap Q)$:

- If $s$ is only a trace of $P$: $s \in (traces(P) - traces(Q))
  \implies ((P \sqcap Q)  /  s) = (P  /
   s)$
- If $s$ is only a trace of $Q$: $s \in (traces(Q) - traces(P))
  \implies ((P \sqcap Q)  /  s) = (Q  /
   s)$
- If $s$ is a trace of both: $s \in traces(P) \land s \in traces(Q)
  \implies ((P \sqcap Q)  /  s) = ((P  /
   s) \sqcap (Q  /  s))$

Notice that $(P \sqcap P) = P$, $(P \sqcap Q) = (Q \sqcap P)$, and
$(P \sqcap Q) \sqcap R) = (P \sqcap (Q \sqcap R))$. $\sqcap$
distributes over $\parallel$: $(P \parallel (Q \sqcap R)) = ((P \parallel
Q) \sqcap (P \parallel R))$ and $((P \sqcap Q) \parallel R) = ((P \parallel
R) \sqcap (Q \parallel R))$.

Keep in mind that $\sqcap$ doesn't distribute over a recursive process
definition: $\mu X \bullet ((a \rightarrow X) \sqcap (b \rightarrow X)) \neq
((\mu X \bullet (a \rightarrow X)) \sqcap (\mu X \bullet (b \rightarrow X)))$
unless $a = b$. The traces of the second process is a subset of traces of
the first process. The second process can choose to always engage in $a$ or
always engage in $b$, while the first one can arbitrarily interleave them.

The concealment of a non-deterministic choice is defined as $((P \sqcap Q)
\setminus C) = ((P \setminus C) \sqcap (Q \setminus C))$.

Given processes $P$ and $Q$ where $\alpha P = \alpha Q$, $(P
 \square  Q)$ is the process that behaves either like
$P$ or like $Q$ where the selection between them may be determined by
its first action. If the first action is in $P$ and not in $Q$, then
$P$ is selected. Conversely, if the first action is in $Q$ but not in
$P$, then $Q$ is selected. If the first action is in both processes,
the selection remains non-deterministic.

More formally, $\alpha (P  \square  Q) = \alpha P =
\alpha Q$ and given events $a$ and $b$, if $a \neq b$ then $(a
\rightarrow P  \square  b \rightarrow Q) = (c \rightarrow P
\mid b \rightarrow Q)$, otherwise $(a \rightarrow P  \square
 b \rightarrow Q) = (c \rightarrow P \sqcap b \rightarrow Q)$.
Notice that $(P  \square  P) = P$, $(P
\square  Q) = (Q  \square  P)$, and $((P
 \square  Q)  \square  R) = (P
 \square  (Q  \square  R))$.

The traces of $(P  \square  Q)$ are defined as
$traces(P  \square  Q) = traces(P) \cup traces(Q)$.
Given a trace $s \in traces(P  \square  Q)$, then:

- If $s \in traces(P) - traces(Q)$, then $(P  \square
   Q)  /  s = (P  /  s)$
- If $s \in traces(Q) - traces(P)$, then $(P  \square
   Q)  /  s = (Q  /  s)$
- If $s \in traces(P) \cap traces(Q)$, then $(P  \square
   Q)  /  s = (P  /  s)
  \sqcap (Q  /  s)$

Notice that $\square$ and $\sqcap$ both distribute with each other.
Also, $traces(P  \square  Q) = traces(P \sqcap Q)$, but
it is possible for $(P \sqcap Q)$ to deadlock on its first step, as $((P
 \square  Q) \parallel P) = P$ but $((P
\sqcap  Q) \parallel P) = (P \sqcap STOP_{\alpha (P \sqcap Q)})$.

With regards to divergences, any divergence of $P$ or $Q$ is a
divergence of $(P \sqcap Q)$ and a divergence of $(P  \square
 Q)$: $divergences(P \sqcap Q) = divergences(P  \square
 Q) = divergences(P) \cup divergences(Q)$.

If $P$ can refuse $X$, then $(P \sqcap Q)$ will refuse $X$ if
$P$ is selected, and if $Q$ can refuse $X$, $(P \sqcap Q)$ will
refuse it if $Q$ is selected: $refusals(P \sqcap Q) = refusals(P) \cup
refusals(Q)$. In the case of $\square$, $refusals(P  \square
 Q) = refusals(P) \cap refusals(Q)$.

The failures of $(P  \square  Q)$ are defined as:

$$\begin{align}
failures((P  &\square  Q)) = \\
&\{ (s, X) \mid (s, X) \in
(failures(P) \cap failures(Q)) \\
&\lor (s \neq \langle \rangle \land (s, X) \in
failures(P) \cup failures(Q))\} \\
&\cup \{ (s, X) \mid s \in divergences(P
 \square  Q) \}
\end{align}$$

#### Interleaving

Given two processes $P$ and $Q$ with the same alphabet, $(P
 |||  Q)$ joins both processes *without* any
interaction or synchronization. The only case for non-determinism is when both
processes could have engaged in the same event.

Given $P = (x : B \rightarrow P(x))$ and $Q = (y : B \rightarrow
Q(y))$, $(P  |||  Q) = (x : B \rightarrow (P(x)
 |||  Q)  \square  (y : B
\rightarrow (P  |||  Q(y))))$. The traces of $(P
 |||  Q)$ are arbitrary interleaves of a trace of
$P$ and a trace of $Q$, and are defined as $traces(P
|||  Q) = \{ s \mid \exists t \in traces(P) \bullet \exists u \in
traces(Q) \bullet s  interleaves  (t, u) \}$.

Refusals are defined as: $refusals(P  |||  Q) = \{ X
\cup Y \mid X \in refusals(P) \land Y \in refusals(Q) \}$.

Failures are defined as:

$$\begin{align}
failures(P & |||  Q) = \\
&\{ (s, X) \mid \exists t, u \bullet (t, X) \in failures(P) \land (u, X) \in failures(Q) \} \\
&\cup \\
&\{ (s, X) \mid s \in divergences(P  |||  Q) \}
\end{align}$$

Divergences are defined as:

$$\begin{align}
divergences(P & |||  Q) =
\{ u \mid \exists s, t \bullet u  interleaves (s, t) \\
&\land ((s \in divergences(P) \land t \in traces(Q)) \\
&\lor (s \in traces(P) \land t \in divergences(Q))) \}
\end{align}$$

Of course, $\alpha (P  |||  Q) = \alpha P = \alpha
Q$. $(P  |||  Q) = (Q  |||
P)$ and $((P  |||  Q)  |||
R) = (P  |||  (Q  |||  R))$,
but $(P  |||  P) \neq P$. Also $|||$
distributes over $\sqcap$, but not over $\square$.

Trace consumption has a more complex definition. Given $s \in traces(P
 |||  Q)$, assume $X = \{ (t, u) \mid t \in
traces(P) \land u \in traces(Q) \land s  interleaves  (t,
u) \}$. Then $((P  |||  Q)  /
s) = \sqcap_{t, u \in X} (P  /  t)  |||
 (Q  /  u)$.

#### Special Processes

Given an alphabet $\Sigma$, $CHAOS_{\Sigma}$ is the most
non-deterministic process and its represented as $CHAOS_{\Sigma} = (\Sigma,
(\Sigma^{*} \times \wp (\Sigma)), \Sigma^{*})$. There is nothing that it
can't do, and it can't be extended with more non-deterministic choices. Notice
that $(P \sqcap CHAOS_{\alpha P}) = CHAOS_{\alpha P}$,
$traces(CHAOS_{\alpha P}) = divergences(CHAOS_{\alpha P}) = (\alpha
P)^{*}$, and $refusals(CHAOS_{\alpha P}) = \wp (\alpha P)$. For any
process $P$, $CHAOS_{\alpha P} \sqsubseteq P$.

A function is said to be *strict* if the result is the $CHAOS$ process if
$CHAOS$ is involved in any of its arguments. For example: $/$,
$\parallel$, $\setminus$, $\square$, and $\sqcap$. The prefix
operator is a counter-example, as $(a \rightarrow CHAOS) \neq CHAOS$.

The $STOP_{\Sigma}$ process can be modelled as $(\Sigma, \{ \langle
\rangle \} \times \wp(\Sigma), \emptyset)$. It does nothing and refuses
everything: $refusals(STOP_{\Sigma}) = \wp(\Sigma)$, but it doesn't
diverge: $divergences(STOP_{\Sigma}) = \emptyset$. Notice that for any
$P$, $(P  \square  STOP_{\alpha P}) = P$. Notice
that $(P  |||  STOP_{\alpha P}) = P$ given that
$P$ doesn't diverge.

The $RUN_{\Sigma}$ process can also be modelled as a non-deterministic
process. Notice that Notice that $(P  |||  RUN_{\alpha
P}) = RUN_{\alpha P}$ given that $P$ doesn't diverge.

### Composition

Two processes can be composed as $P \parallel Q$ to model concurrency. The
type of the resulting composition depends on the relationship between the
alphabets of the composed processes.

- **Interaction**: if the processes share the same alphabet ($\alpha P =
  \alpha Q$)
- **Interleave**: if parts of the alphabet overlap ($\alpha P \cap \alpha Q
  \neq \alpha P \cup \alpha Q$)
- **Pure interleave**: if the alphabets are disjoint ($\alpha P \cap \alpha Q
  = \emptyset$)

Composition is commutative ($P \parallel Q = Q \parallel P$) and
associative ($P \parallel (Q \parallel R) = (P \parallel Q) \parallel R$).
Also $P \parallel P = P$.

Given an *interaction*, the resulting process is the intersection between the
composed processes. Basically $(\Sigma, T_1) \parallel (\Sigma, T_2) =
(\Sigma, T_1 \cap T_2)$, which means that $traces(P \parallel Q) =
traces(P) \cap traces(Q)$. It follows that $P \parallel STOP_{\alpha P} =
STOP_{\alpha P}$ and that $P \parallel RUN_{\alpha P} = P$.

Given two processes defined with the choice shorthand, $(x : A \rightarrow
P(x)) \parallel (y : B \rightarrow Q(y)) = (z : A \cap B \rightarrow (P(z)
\parallel Q(z)))$. If no choices are shared, the result is the broken object:
$(x \rightarrow P) \parallel (y \rightarrow P) = STOP_{\alpha P}$.  Trace
consumption is defined as $(P \parallel Q)  /  t = (P
 /  t) \parallel (Q  /  t)$.

Given an *interleave* or a *pure interleave*, the resulting process is the
concurrent combination of both processes with potential synchronization points,
and it should consider every possible way in which independent events may
happen. Processes $P$ and $Q$ only need to be synchronized on events
from $\alpha P \cap \alpha Q$.

Consider two processes $P = (x : A \rightarrow f(x))$ and $Q = (y : B
\rightarrow g(y))$. The events from $P \parallel Q$ will be drawn from
$C = (A \cap B) \cup (A - \alpha Q) \cup (B - \alpha P)$. Assuming $z \in
C$, there are three possibilities:

- If $z \in A \land z \in B$, then we can advance with both $P$ and
  $Q$: $P \parallel Q = (z : C \rightarrow f(x) \parallel g(y))$
- If $z \in A \land z \notin B$, then we can only advance on $P$: $P
  \parallel Q = (z : C \rightarrow f(x) \parallel Q)$
- If $z \notin A \land z \in B$, then we can only advance on $Q$: $P
  \parallel Q = (z : C \rightarrow P \parallel g(y))$

Notice $z \notin A \land z \notin B$ is not a possibility given the
definition of $C$.

The resulting alphabet is $\alpha (P \parallel Q) = \alpha P \cup \alpha
Q$. The set of valid traces is defined as $traces(P \parallel Q) = \{ t
\mid (t \restriction \alpha P) \land (t \restriction \alpha Q) \land (t \in
(\alpha P \cup \alpha Q)^{*}) \}$ which means that the parts of a trace
related to $P$ must be valid in $P$, the parts related to $Q$ must
be valid in $Q$, and the events in a trace must have been drawn from the
alphabet of either $P$ or $Q$.

Consuming a trace $t$ is defined as $(P \parallel Q)  /
 t = (P  /  (t \restriction \alpha P)) \parallel
(Q  /  (t \restriction \alpha Q))$. Notice that if
$\alpha P = \alpha Q$ (which means the composition would be an
*interaction*), then the previous expression is equal to our *interaction*
definition: $(P \parallel Q)  /  t = (P  /
 t) \parallel (Q  /  t)$.

Given composition between two processes that engage on communication: $(c!v
\rightarrow P) \parallel (c?x \rightarrow Q(x)) = c!v \rightarrow (P \parallel
Q(v))$. Notice the act of sending the message remains on the process
definition (think of it as a log that can be conncealed if desired).

Given sequential processes $P$ and $Q$, then $(P \parallel Q)$ is
only valid if $\alpha P \subseteq \alpha Q \lor \alpha Q \subseteq \alpha P
\lor \checkmark \in ((\alpha P \cap \alpha Q) \cup (\overline{\alpha P} \cap
\overline{\alpha Q}))$.

The failures of a composed process are defined as:

$$\begin{align}
failures(P &\parallel Q) =
\{ (s, (X \cup Y)) \mid s \in (\alpha P \cup \alpha Q)^{*} \\
&\land (s \restriction \alpha P, X) \in failures(P) \land (s \restriction \alpha Q, Y)
\in failures(Q) \} \\
&\cup \{ (s, X) \mid s \in divergences(P \parallel Q) \}
\end{align}$$

Divergences are defined as:

$$\begin{align}
divergences&(P \parallel Q) = \{ s \frown
t \mid t \in (\alpha P \cup \alpha Q)^{*} \\
&\land (((s \restriction \alpha P \in divergences(P)) \land (s \restriction \alpha Q \in traces(Q))) \\
&\lor ((s \restriction \alpha P \in traces(P)) \land (s \restriction \alpha Q \in divergences(Q)))) \}
\end{align}$$

### Restart Processes

Given a process $P$ where $\downarrow \notin \alpha P$,
$\overset{\frown}{P}$ is the process that behaves like $P$ until
$\downarrow$ occurs, and then behaves like $P$ again.

It is defined as $\overset{\frown}{P} = \mu X \bullet (P
\overset{\frown}{\downarrow}  X) = (P
\overset{\frown}{\downarrow}  P
\overset{\frown}{\downarrow}  P
\overset{\frown}{\downarrow}  ...)$ with an alphabet $\alpha
\overset{\frown}{P} = \alpha P \cup \{ \downarrow \}$. Notice that
$\forall s \in traces(P) \bullet \overset{\frown}{P}  /  s
\frown \langle \downarrow \rangle = \overset{\frown}{P}$.

A process can "save" its state by engaging on a checkpoint event
$\bigodot$.

Given $P$ where $\bigodot \in \alpha P$, $Ch(P)$ is the
process that goes back to the state after its more recent checkpoint or starts
all over again if it engages in $\downarrow$. This is defined as
$\forall s \in traces(P) \bullet Ch(P)  /  (s \frown
\langle \downarrow \rangle) = Ch(P)$ and $\forall s \in traces(P)
\bullet Ch(P)  /  (s \frown \langle \bigotimes
\rangle) = Ch(P  /  (s \frown \langle \bigodot
\rangle))$.

$Mch(P)$ is the process that goes back to the state just before the last
$\bigodot$ if it engages on $\downarrow$. Its alphabet
is defined as $\alpha Mch(P) = \alpha P \cup \{ \bigodot,
\downarrow \}$ and its behaviour is defined as $\forall s \in
traces(P) \bullet Mch(P)  /  (s \frown \langle
\downarrow \rangle) = Mch(P)$ and $\forall (s \restriction \alpha P)
\frown t \in traces(P) \bullet Mch(P)  /  (s \frown \langle
\bigodot \rangle \frown t \frown \langle \downarrow \rangle) =
Mch(P)  /  s$.

### Sequential Processes

A sequential process has $\checkmark$ in its alphabet, and engages on it
upon successful termination. $\checkmark$ can only be the last event a
sequential process engages with.

A trace of a sequential process $P$ is a *sentence* if $P$ terminates
successfully after it engages on it.

Given a composition of a *non sequential process* $A$ with a *sequential
process* $B$, the sequential process dominates the result if its alphabet
is a superset of the non sequential one: $\checkmark \notin A \land A
\subseteq B \implies STOP_{A} \parallel SKIP_{B} = SKIP_{B}$.

Notice that a successfully terminating process (like $SKIP_{A}$) doesn't
participate in any other event offered by another concurrent process: $((x :
B \rightarrow P(x)) \parallel SKIP_{A}) = (x : (B - A) \rightarrow (P(x)
\parallel SKIP_{A}))$.

#### Sequential Composition

Given sequential processes $P$ and $Q$ with the same alphabet, $(P
 ;  Q)$ is the process that behaves like $P$ until
successful termination, and then behaves like $Q$. If $P$ doesn't
terminate successfully, then neither does $(P  ;  Q)$.
Notice that $((s  ;  t)  ;  u) = (s
 ;  (t  ;  u))$, that $(\langle
\rangle  ;  t) = \langle \rangle$ and similarly
$(\langle \checkmark \rangle  ;  t) = t$. Of course,
$(s  ;  \langle \checkmark \rangle) = s$.

An infinite loop consisting of sequential composition of a process with itself
is defined as $*P = \mu X \bullet (P  ;  X)$, which
expands to $(P  ;  P  ;  P
;  P  ;  ...)$. Given $*P$ is an infinite
loop and doesn't terminate, then $\checkmark$ is not part of its alphabet:
$\alpha (*P) = \alpha P - \{ \checkmark \}$.

Notice $((x : B \rightarrow P(x))  ;  Q) = (x : B
\rightarrow (P(x)  ;  Q))$. Given one choice: $((x
\rightarrow P(x))  ;  Q) = (x \rightarrow (P  ;
 Q))$. Also, sequential composition is associative: $((P
 ;  Q)  ;  R) = (P  ;
 (Q  ;  R))$.

Given $P$ and considering $SKIP_{\alpha P}$ and $STOP_{\alpha P}$,
then notice that $(SKIP_{\alpha P}  ;  P) = (P
;  SKIP_{\alpha P}) = P$, and $(STOP_{\alpha P}  ;
 P) = STOP_{\alpha P}$.

Given traces $s$ and $t$ where $\checkmark$ is not in $s$, then
$(s  ;  t) = s$ and $(s \frown \langle \checkmark
\rangle)  ;  t = s \frown t$. Also, events after the
successful termination event are discarded: $((s_{0} \frown \langle
\checkmark \rangle \frown s_{1})  ;  t) = (s_{0} \frown
t)$.

The traces operation is defined like this: $traces(P  ;
Q) = \{ s  ;  t \mid s \in traces(P) \land t \in traces(Q)
\}$.

Given a deterministic process $P$, notice that $s \frown \langle
\checkmark \rangle \in traces(P) \implies P  /  s =
SKIP_{\alpha P}$. For non-deterministic processes, this observation is loosen
up to $s \frown \langle \checkmark \rangle \in traces(P) \implies (P
 /  s) \sqsubseteq SKIP_{\alpha P}$.

In the case of non-deterministic processes, $;$ distributes over
$\sqcap$. Its refusals are:

$$\begin{align}
refusals&(P  ;  Q) = \\
&\{ X \mid (X \cup \{ \checkmark \}) \in refusals(P) \} \\
&\cup \\
&\{ X \mid \langle \checkmark \rangle \in traces(P) \land X \in refusals(Q) \}
\end{align}$$

Notice that if
$P$ can refuse $X$, then it can also refuse $X \cup \{ \checkmark
\}$. Failures are defined as:

$$\begin{align}
failures&(P  ;  Q) = \\
&\{ (s, X) \mid (s, X \cup \{ \checkmark \}) \in failures(P) \} \\
&\cup \\
&\{ (s \frown t, X) \mid s \frown \langle \checkmark \rangle \in traces(P) \land (t,
X) \in failures(Q) \} \\
&\cup \\
&\{ (s, X) \mid s \in divergences(P  ;  Q) \}
\end{align}$$

For non-deterministic sequential composition, $(CHAOS  ;
P) = P$, as a divergent process must remain divergent. $(P  ;
 Q)$ diverges when $P$ diverges or when $P$ completes
successfully and then $Q$ diverges:

$$\begin{align}
divergences&(P  ;  Q) = \\
&\{ s \mid s \in divergences(P) \land \lnot (\langle \checkmark
\rangle  in  s)\} \\
&\cup \\
&\{ s \frown t \mid s \frown
\langle \checkmark \rangle \in traces(P) \land \lnot (\langle \checkmark
\rangle  in  s) \land t \in divergences(Q) \}
\end{align}$$

#### Interruption

Given sequential processes $P$ and $Q$, $(P \triangle Q)$ is a type
of sequential composition that behaves like $P$ up to an arbitrary event
where execution is interrupted, and then behaves like $Q$. It must hold
that $\checkmark \notin \alpha P$.

$Q$ starts on an arbitrary event initially offered by $Q$ but not
offered by $P$ at all (this ensures determinism): $(x : B \rightarrow
P(x)) \triangle Q = Q  \square  (x : B \rightarrow (P(x)
\triangle Q))$.

$\triangle$ is associative and distributes over $\sqcap$. Also $(P
\triangle STOP_{\alpha P}) = (STOP_{\alpha P} \triangle P) = P$ and $(P
\triangle CHAOS_{\alpha P}) = (CHAOS_{\alpha P} \triangle P) = CHAOS_{\alpha
P}$.

It is defined as $\alpha (P \triangle Q) = \alpha P \cup \alpha Q$ where
$traces(P \triangle Q) = \{ s \frown t \mid s \in traces(P) \land t \in
traces(Q) \}$.

The catastrophic interrupt event is denoted $\downarrow$. $(P
 \overset{\frown}{\downarrow}  Q) = (P
\triangle  (\downarrow \rightarrow Q))$, given
$\downarrow \notin \alpha P$, which describes a process that behaves
like $P$, until $\downarrow$ arbitrarily occurs, and then behaves
like $Q$. Its defined as $(x : B \rightarrow P(x))
\overset{\frown}{\downarrow}  Q = (x : B \rightarrow (P(x)
 \overset{\frown}{\downarrow}  Q) \mid \downarrow
\rightarrow Q)$. With regards to traces, $\forall s \in traces(P) \bullet ((P
 \overset{\frown}{\downarrow}  Q)  /
 (s \frown \langle \downarrow \rangle) = Q$.

Random alternation between $P$ and $Q$ is denoted $(P
\bigotimes  Q)$. One of the processes will run at any
given time, until its arbitrarily interrupted with the
$\bigotimes$ event, and then will switch to the other process
until the same event occurs again. This is defined as $(x : B \rightarrow
P(x))  \bigotimes  Q = (x : B \rightarrow (P(x)
 \bigotimes  Q) \mid \bigotimes
\rightarrow (Q  \bigotimes  P))$. Notice that
$\bigotimes \in (\alpha (P  \bigotimes
Q) - \alpha P - \alpha Q)$ and that $(P  \bigotimes
 Q)  /  \langle \bigotimes \rangle = (Q
 \bigotimes  P)$.  Also $\forall s \in
traces(P) \bullet (P  \bigotimes  Q)  /
 s = (P  /  s)  \bigotimes
 Q$.

### Pipes

Processes with only two channels: an input channel $left$ and an output
channel $right$ are called *pipes*. Given two pipes that are non-stopping,
their composition is also non-stopping. $>>$ cannot introduce deadlock in
pipes.

A pipe $P$ is *left-guarded* if it can never output an infinite sequence of
messages to the right channel without inputs from the left channel. A pipe
$Q$ is *right-guarded* if it can never input an infinite sequence of
messages from the left channel without outputting to the right channel.

A pipe can be modelled as a relation between two sequences $(left, right)$
which represent a valid state of the pipe. Chaining pipes is then equivalent to
relational composition. Given $(P  >>  Q)$, if $P$
is left-guarded or $Q$ is right-guarded, then: $\exists  s
\bullet (left, s)\_{P} \land (s, right)\_{Q}$.

Given pipes $P$ and $Q$, sending $P$'s output to $Q$'s input is
denoted $P  >>  Q$. The resulting process is a pipe.
The alphabet of such pipe is $\alpha (P  >>  Q) = \alpha
 left(P) \cup \alpha  right(Q)$. Of course, if $P
 >>  Q$ is valid, then $\alpha  right(P) =
\alpha  left(Q)$. Notice that $(P  >>  Q)
 >>  R = P  >>  (Q  >>
 R)$.

Notice both pipes can keep infinitely communicating with each other while not
communicating with the external world at all, which is called *livelock*.
Proving that $P  >>  Q$ requires proving that $P$
is *left-guarded* or that $Q$ is *right-guarded*.

Given $P  >>  Q$ where both pipes are ready to output
data, the right side of the pipe takes precedence:

$$\begin{align}
(right!x \rightarrow P)  &>>  (right!w \rightarrow Q) = \\
&right!w \rightarrow ((right!x \rightarrow P)  >>  Q)
\end{align}$$

Conversely, if both pipes are ready to input data, the left side of the pipe
takes precedence:

$$\begin{align}
(left?x \rightarrow P(x))  &>>  (left?y
\rightarrow Q(y)) = \\
&left?x \rightarrow (P(x)  >>  (left?y \rightarrow Q(y)))
\end{align}$$

If $P$ is ready to input and $Q$ is ready to output, the order is
unspecified:

$$\begin{align}
(left?x \rightarrow P(x))  &>>  (right!w
\rightarrow Q) = \\
&(left?x \rightarrow (P(x)  >>  (right!w
\rightarrow Q))) \\
&\mid \\
& (right!w \rightarrow ((left?x \rightarrow P(x))
 >>  Q))
\end{align}$$

#### Buffers

A buffer is a special type of pipe that outputs the same sequence it received
as input, potentially after some delay. Given the relational representation of
a pipe, a buffer must obey the following laws:

- A buffer must never stop
- A buffer must be free of livelock
- In all valid states, $right \leq left$.
- In all valid states, if $right = left$ then the process can't refuse the
  communicate on $left$. Else, if $right \neq left$ then the process
  can't refuse to communicate on $right$

It follows that all buffers are left-guarded.

If $P$ and $Q$ are buffers, then $(P  >>  Q)$
and $(left?x \rightarrow (P  >>  (right!x \rightarrow
Q)))$ are also buffers. $(P  >>  Q)$ is also a buffer
if its equal to $(left?x \rightarrow (P  >>  (right!x
\rightarrow Q))$).

Traces
------

A trace is a sequence of events that can be applied in order to an object. The
empty trace $\langle \rangle$ is a valid trace in every object (the
shortest possible trace), and its the default trace when an object didn't
engage on any event.

The resulting process that occurs after process $P$ engages in trace
$s$ is denoted as $P  /  s$. This expression only
makes sense if $s \in traces(P)$. Notice that $P  /
\langle \rangle = P$ and that $P  /  (s \frown t) = (P
 /  s)  /  t$

A function $f : seq \rightarrow seq$ that maps a trace to a trace is
*strict* if $f(\langle \rangle) = \langle \rangle$, and *distributive* if
$f(s \frown t) = f(s) \frown f(t)$. Notice that if the function is
distributive, then its also strict.

Given a function $m$ that maps an event to an event, $m^{*}$ stands
for the function that maps a sequence to another sequence using $m$ on
every element. For example, $double^{*}(\langle 1, 2, 3 \rangle) = \langle
2, 4, 6 \rangle$. Notice that $m^{*}$ is always *strict* and
*distributive*. Of course, the mapping operator preserves the sequence length:
given sequence $s$, $\# (m^{*}(s)) = \# s$. Also, $m^{*}(\langle
s_{0} \rangle) = \langle m(s_{0}) \rangle$.

Given a process defined as the function $P$ and a set of choices $A$
from its alphabet, its set of traces is defined as $(x : A \rightarrow P(x))
= \{ \langle \rangle \} \cup \{ \bigcup_{y \in A} traces(P(y))\}$.
Similarly, given a prefix with event $x$ and result $P$, $traces(x
\rightarrow P) = \{ \langle \rangle \} \cup \{ \langle x \rangle \frown t
\mid t \in traces(P) \}$. Finally, given a process composed of choices,
$traces(x \rightarrow P \mid y \rightarrow Q) = traces(x \rightarrow P) \cup
traces(y \rightarrow Q)$.

The traces of the resulting process after consuming a trace is all the traces
that start with the consumed traces: $traces(P  /  s) =
\{ t \mid t \in traces(P) \land s \leq t\}$.

Events
------

- $\downarrow$: The catastrophic interrupt event
- $\bigotimes$: The process alternation interrupt event
- $\bigodot$: The checkpoint event
- $\checkmark$: Pronounced "success". Denotes successful termination, and
  must be part of the alphabet of the process if used. It can only be the last
  event a process engages in. $(x : B \rightarrow P(x))$ is invalid if
  $\checkmark \in B$

Chains
------

A *chain* is a set of processes $\{ P_1, P_2, ..., P_n, P_{n + 1} \}$
with equal alphabets ordered by the subset operator. It must hold that
$\forall n \bullet P_{n} \sqsubseteq P_{n + 1}$.

The *limit* (or *least upper bound*) of a chain is the process that can consume
the traces of all processes in the chain, defined as $\sqcup \{ P_1, P_2,
...\} = (\alpha P_1, \bigcup_i traces(P_i))$. The alphabet of the resulting
process is $\alpha P_1$, which is arbitrary, because all the processes in
the chain share the same alphabet, so the alphabet of any of its elements would
do.

Notice that given a process $P$ and a chain $C$ such that $P \in
C$, then $P \subseteq \sqcup C$ and given another process $Q$, if all
the elements of the chain are subsets of $Q$, then the limit of the chain
is also a subset of it: $(\forall c \in C \bullet c \sqsubseteq Q) \implies
\sqcup C \sqsubseteq Q$.

References
----------

- [Communicating Sequential Processes, by Tony Hoare](http://usingcsp.com)
