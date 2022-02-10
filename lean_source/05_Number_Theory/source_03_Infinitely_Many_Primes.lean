import data.nat.prime
import algebra.big_operators
import tactic

open_locale big_operators

/- TEXT:
.. _section_infinitely_many_primes:

Infinitely Many Primes
----------------------

Let us continue our exploration of induction and recursion with another
mathematical standard: a proof that there are infinitely many primes.
We will formulate this as the statement that for every natural number
:math:`n`, there is a prime number greater than :math:`n`.
To prove it, consider :math:`n! + 1`.
Let :math:`p` be any prime factor.
If :math:`p` is less than :math:`n`, it divides :math:`n!`.
Since it also divides :math:`n! + 1`, it divides 1, a contradiction.
Hence :math:`p` is greater than :math:`n`.

To formalize that proof, we need to show that any number greater than or equal
to 2 has a prime factor.
Along the way, we will need to show that any natural number that is
not equal to 0 or 1 is greater-than or equal to 2.
And this brings us to a quirky feature of formalization:
it is often trivial statements like this that are among the most
annoying to formalize.
Here we consider a few ways to do it.

To start with, we can use the ``cases`` tactic and the fact that the
successor function respects the ordering on the natural numbers.
EXAMPLES: -/
-- QUOTE:
theorem two_le {m : ℕ} (h0 : m ≠ 0) (h1 : m ≠ 1) : 2 ≤ m :=
begin
  cases m, contradiction,
  cases m, contradiction,
  repeat { apply nat.succ_le_succ },
  apply zero_le
end
-- QUOTE.

/- TEXT:
Another strategy uses a tactic ``interval_cases``,
which automatically splits the goal into cases when
the variable in question is contained in an interval
of natural numbers or integers.
Remember that you can hover over it to see its documentation.
EXAMPLES: -/
-- QUOTE:
example {m : ℕ} (h0 : m ≠ 0) (h1 : m ≠ 1) : 2 ≤ m :=
begin
  by_contradiction h,
  push_neg at h,
  interval_cases m; contradiction
end
-- QUOTE.

/- TEXT:
Yet another option is to use the tactic, ``dec_trivial``, which tries
to find a decision procedure to solve the problem.
Lean knows that you can decide the truth value of a statement that
begins with a bounded quantifier ``∀ x, x < n → ...`` or ``∃ x, x < n ∧ ...``
by deciding each of the finitely many instances.
EXAMPLES: -/
-- QUOTE:
example {m : ℕ} (h0 : m ≠ 0) (h1 : m ≠ 1) : 2 ≤ m :=
begin
  by_contradiction h,
  push_neg at h,
  revert m h h0 h1,
  dec_trivial
end
-- QUOTE.

/- TEXT:
In fact, the variant ``dec_trivial!`` will revert all the hypotheses
that contain a variable that is found in the target.
EXAMPLES: -/
-- QUOTE:
example {m : ℕ} (h : m < 2) : m = 0 ∨ m = 1 :=
by dec_trivial!
-- QUOTE.

/- TEXT:
Finally, in this case we can use the ``omega`` tactic, which is designed
to reason about linear expressions in the natural numbers.
EXAMPLES: -/
-- QUOTE:
example {m : ℕ} (h0 : m ≠ 0) (h1 : m ≠ 1) : 2 ≤ m :=
by omega
-- QUOTE.

/- TEXT:
With those options in hand, let's start by showing that every
natural number greater than two has a prime divisor.
Mathlib contains a function ``nat.min_fac`` that
returns the smallest such prime divisor.
But for the sake of learning new parts of the library,
we'll avoid using it and prove the theorem directly.

Here, ordinary induction isn't enough.
We want to use *strong induction*, which allows us to prove
that every natural number :math:`n` has a property :math:`P`
by showing that for every number :math:`n`, if :math:`P` holds
of all values less than :math:`n`, it holds at :math:`n` as well.
In Lean, this principle is called ``nat.strong_induction_on``,
and we can use the ``with`` keyword to tell the induction tactic
to use it.
Notice that when we do that, there is no base case; it is subsumed
by the general induction step.

The argument is simply as follows. Assuming :math:`n ≥ 2`,
if :math:`n` is prime, we're done. If it isn't,
then by one of the characterizations of what it means to be a prime number,
it has a nontrivial factor, :math:`m`,
and we can apply the inductive hypothesis to that.
Step through the next proof to see how that plays out.
EXAMPLE: -/
-- QUOTE:
theorem exists_prime_factor {n : nat} (h : 2 ≤ n) :
  ∃ p : nat, p.prime ∧ p ∣ n :=
begin
  by_cases np : n.prime,
  { use [n, np, dvd_rfl] },
  induction n using nat.strong_induction_on with n ih,
  dsimp at ih,
  rw nat.prime_def_lt at np,
  push_neg at np,
  rcases np h with ⟨m, mltn, mdvdn, mne1⟩,
  have : m ≠ 0,
  { intro mz, rw [mz, zero_dvd_iff] at mdvdn, linarith },
  have mgt2 : 2 ≤ m := two_le this mne1,
  by_cases mp : m.prime,
  { use [m, mp, mdvdn] },
  rcases ih m mltn mgt2 mp with ⟨p, pp, pdvd⟩,
  use [p, pp, pdvd.trans mdvdn]
end
-- QUOTE.

/- TEXT:
With that in hand, we can prove the following formulation of our theorem. See if you can fill out the following sketch.
You can use ``nat.factorial_pos``, ``nat.dvd_factorial``,
and ``nat.dvd_sub``.
EXAMPLE: -/
-- QUOTE:
theorem primes_infinite : ∀ n, ∃ p > n, nat.prime p :=
begin
  intro n,
  have : 2 ≤ nat.factorial (n + 1) + 1,
/- EXAMPLES:
    sorry,
SOLUTIONS: -/
  { apply nat.succ_le_succ,
    exact nat.succ_le_of_lt (nat.factorial_pos _) },
-- BOTH:
  rcases exists_prime_factor this with ⟨p, pp, pdvd⟩,
  refine ⟨p, _, pp⟩,
  show p > n,
  by_contradiction ple, push_neg at ple,
  have : p ∣ nat.factorial (n + 1),
/- EXAMPLES:
    sorry,
SOLUTIONS: -/
  { apply nat.dvd_factorial,
    apply pp.pos,
    linarith },
-- BOTH:
  have : p ∣ 1,
/- EXAMPLES:
    sorry,
SOLUTIONS: -/
  { convert nat.dvd_sub' pdvd this, simp },
-- BOTH:
  show false,
/- EXAMPLES:
    sorry,
SOLUTIONS: -/
  have := nat.le_of_dvd zero_lt_one this,
  linarith [pp.two_le]
-- BOTH:
end

/- TEXT:
Let's consider a variation of the proof above, where instead
of using the factorial function,
we suppose that we are given by a finite set
:math:`\{ p_1, \ldots, p_n \}` and consider a prime factor of
:math:`\Prod_{i = 1}^n p_i + 1`.
Once again, that prime factor has to be distinct from each
:math:`p_i`, showing that there is no finite set that contains
all the prime numbers.

Formalizing this argument requires us to reason about finite
sets. In Lean, for any type ``α``, the type ``finset α``
represents the set of finite elements of type ``α``.
Reasoning about finite sets computationally requires having
a procedure to test equality on ``α``, which is why the snippet
below includes the assumption ``[decidable_eq α]``.
For concrete data types like ``ℕ``, ``ℤ``, and ``ℚ``,
the assumption is satisfied automatically. When reasoning about
the real numbers, it can be satisfied using classical logic
and abandoning the computational interpretation.

We use the command ``open finset`` to avail ourselves of shorter names
for the relevant theorems. Unlike the case with sets,
most equivalences involving finsets do not hold definitionally,
so they need to be expanded manually using equivalances like
``finset.subset_iff``, ``finset.mem_union``, ``finset.mem_inter``,
and ``finset.mem_sdiff``. The ``ext`` tactic can still be used
to reduce show that two finite sets are equal by showing
that every element of one is an element of the other.
EXAMPLE: -/
-- QUOTE:
open finset

section
variables {α : Type*} [decidable_eq α] (r s t : finset α)

example : r ∩ (s ∪ t) ⊆ (r ∩ s) ∪ (r ∩ t) :=
begin
  rw subset_iff,
  intro x,
  rw [mem_inter, mem_union, mem_union, mem_inter, mem_inter],
  tauto
end

example : r ∩ (s ∪ t) ⊆ (r ∩ s) ∪ (r ∩ t) :=
by { simp [subset_iff], intro x, tauto }

example : (r ∩ s) ∪ (r ∩ t) ⊆ r ∩ (s ∪ t) :=
by { simp [subset_iff], intro x, tauto }

example : (r ∩ s) ∪ (r ∩ t) = r ∩ (s ∪ t) :=
by { ext x, simp, tauto }

end
-- QUOTE.

/- TEXT:
We have used a new trick: the ``tauto`` tactic (and a strengthened
version, ``tauto!``, that uses classical logic) can be used to
dispense with propositional tautologies. See if you can use
similar methods to prove the two examples below.
BOTH: -/
section
variables {α : Type*} [decidable_eq α] (r s t : finset α)

-- QUOTE:
example : (r ∪ s) ∩ (r ∪ t) = r ∪ (s ∩ t) :=
/- EXAMPLES:
sorry
SOLUTIONS: -/
begin
  ext x,
  rw [mem_inter, mem_union, mem_union, mem_union, mem_inter],
  tauto
end

example : (r ∪ s) ∩ (r ∪ t) = r ∪ (s ∩ t) :=
by { ext x, simp, tauto }
-- BOTH:

example : (r \ s \ t) = r \ (s ∪ t) :=
/- EXAMPLES:
sorry
SOLUTIONS: -/
begin
  ext x,
  rw [mem_sdiff, mem_sdiff, mem_sdiff, mem_union],
  tauto
end

example : (r \ s \ t) = r \ (s ∪ t) :=
by { ext x, simp, tauto }
-- QUOTE.
-- BOTH:

end
/- TEXT:
The theorem ``finset.dvd_prod_of_mem`` tells us that if an
``n`` is an element of a finite set ``s``, then ``n`` divides
``∏ i in s, i``.
EXAMPLE: -/
-- QUOTE:
example (s : finset ℕ) (n : ℕ) (h : n ∈ s) : n ∣ (∏ i in s, i) :=
finset.dvd_prod_of_mem _ h
-- QUOTE.

/- TEXT:
We also need to know that the converse holds in the case where
``n`` is prime and ``s`` is a set of primes.
To show that, we need the following lemma, which you should
be able to prove using the theorem ``nat.prime.eq_one_or_self_of_dvd``.
EXAMPLE: -/
-- QUOTE:
theorem nat.prime.eq_of_dvd_of_prime {p q : ℕ}
    (prime_p : nat.prime p) (prime_q : nat.prime q) (h : p ∣ q) :
  p = q :=
begin
  cases prime_q.eq_one_or_self_of_dvd _ h,
  { linarith [prime_p.two_le] },
  assumption
end
-- QUOTE.

example (x y z : ℕ)
    (h1 : y ≤ x) (h2 : z ≤ y) (h3 : x + y + z = 13) (h4 : x * y * z = 36) :
  (x = 9 ∧ y = 2 ∧ y = 2) ∨ (x = 6 ∧ y = 6 ∧ z = 1) :=
begin
  have : x ≤ 13, { linarith },
  revert z, revert y, revert x,
  dec_trivial
end


/- TEXT:


EXAMPLE: -/
-- QUOTE:

-- QUOTE.

/- TEXT:


EXAMPLE: -/
-- QUOTE:

-- QUOTE.


/- TEXT:

EXAMPLE: -/

-- QUOTE:




theorem mem_of_dvd_prod_primes {s : finset ℕ} {p : ℕ} (prime_p : p.prime) :
  (∀ n ∈ s, nat.prime n) →  (p ∣ ∏ n in s, n) → p ∈ s :=
begin
  intros h₀ h₁,
  induction s using finset.induction_on with a s ans ih,
  { simp at h₁,
    linarith [prime_p.two_le] },
  simp [finset.prod_insert ans, prime_p.dvd_mul] at h₀ h₁,
  rw mem_insert,
  -- finish off
  cases h₁ with h₁ h₁,
  { left, exact prime_p.eq_of_dvd_of_prime h₀.1 h₁ },
  right,
  exact ih h₀.2 h₁
end

theorem primes_infinite' : ∀ (s : finset nat), ∃ p, nat.prime p ∧ p ∉ s :=
begin
  intro s,
  by_contradiction h,
  push_neg at h,
  set s' := s.filter nat.prime with s'_def,
  have mem_s' : ∀ {n : ℕ}, n ∈ s' ↔ n.prime,
  { intro n,
    simp [s'_def],
    apply h },
  have : 2 ≤ (∏ i in s', i) + 1,
  { apply nat.succ_le_succ,
    apply nat.succ_le_of_lt,
    apply finset.prod_pos,
    intros n ns',
    apply (mem_s'.mp ns').pos },
  rcases exists_prime_factor this with ⟨p, pp, pdvd⟩,
  have : p ∣ (∏ i in s', i),
  { apply dvd_prod_of_mem,
    rw mem_s',
    apply pp },
  have : p ∣ 1,
  { convert nat.dvd_sub' pdvd this, simp },
  have := nat.le_of_dvd zero_lt_one this,
  linarith [pp.two_le]
end

theorem bounded_of_ex_finset (Q : ℕ → Prop) [decidable_pred Q]:
  (∃ s : finset ℕ, ∀ k, Q k → k ∈ s) → ∃ n, ∀ k, Q k → k < n :=
begin
  rintros ⟨s, hs⟩,
  use s.sup id + 1,
  intros k Qk,
  apply nat.lt_succ_of_le,
  show id k ≤ s.sup id,
  apply le_sup (hs k Qk)
end

theorem ex_finset_of_bounded (Q : ℕ → Prop) [decidable_pred Q]:
  (∃ n, ∀ k, Q k → k ≤ n) → (∃ s : finset ℕ, ∀ k, Q k ↔ k ∈ s) :=
begin
  rintros ⟨n, hn⟩,
  use (range (n + 1)).filter Q,
  intro k,
  simp [nat.lt_succ_iff],
  exact hn k
end

-- QUOTE.

/- TEXT:

EXAMPLE: -/
-- QUOTE:

-- QUOTE.

/- TEXT:

EXAMPLE: -/
-- QUOTE:

-- QUOTE.

/- TEXT:
A small variation on this argument shows that there are,
in fact, infinitely many primes congruent to 3 modulo 4.
EXAMPLE: -/
-- QUOTE:
example : 27 % 4 = 3 := by norm_num
-- QUOTE.


example (n : ℕ) : (4 * n + 3) % 4 = 3 :=
by { rw [add_comm, nat.add_mul_mod_self_left], norm_num }

theorem mod_4_eq_3_or_mod_4_eq_3 {m n : ℕ} (h : m * n % 4 = 3) :
  m % 4 = 3 ∨ n % 4 = 3 :=
begin
  revert h,
  rw [nat.mul_mod],
  have : m % 4 < 4 := nat.mod_lt m (by norm_num),
  interval_cases m % 4 with hm; simp [hm],
  have : n % 4 < 4 := nat.mod_lt n (by norm_num),
  interval_cases n % 4 with hn; simp [hn]; norm_num
end
-- QUOTE.

/- TEXT:

EXAMPLE: -/
theorem exists_prime_factor_mod_4_eq_3 {n : nat} (h : 2 ≤ n) (h' : n % 4 = 3) :
  ∃ p : nat, p.prime ∧ p ∣ n ∧ p % 4 = 3 :=
begin
  by_cases np : n.prime,
  { use [n, np, dvd_rfl, h'] },
  induction n using nat.strong_induction_on with n ih,
  dsimp at ih,
  rw nat.prime_def_lt at np,
  push_neg at np,
  rcases np h with ⟨m, mltn, mdvdn, mne1⟩,
  have neq : m * (n / m) = n := nat.mul_div_cancel' mdvdn,
  have : m ≠ 0,
    { intro mz, rw [mz, zero_dvd_iff] at mdvdn, linarith },
  have mgt2 : 2 ≤ m := two_le this mne1,
  have : m % 4 = 3 ∨ (n / m) % 4 = 3,
  { apply mod_4_eq_3_or_mod_4_eq_3, rw [neq, h'] },
  cases this with h1 h1,
  { by_cases mp : m.prime,
    { use [m, mp, mdvdn, h1], },
    rcases ih m mltn mgt2 h1 mp with ⟨p, pp, pdvd, p4eq⟩,
    use [p, pp, pdvd.trans mdvdn, p4eq] },
  have ndivmnz : n / m ≠ 0,
  { intro ndivmz, rw [ndivmz, mul_zero] at neq,
    rw ←neq at h, norm_num at h },
  have ndivmn1 : n / m ≠ 1,
  { intro ndivm1, rw [ndivm1, mul_one] at neq,
    rw ←neq at mltn, exact lt_irrefl _ mltn },
  have ndivmgt2 : 2 ≤ n / m := two_le ndivmnz ndivmn1,
  have ndivmdvd : n / m ∣ n,
  { apply nat.div_dvd_of_dvd mdvdn },
  have ndivmlt : n / m < n,
  { apply nat.div_lt_self _ mgt2,
    linarith },
  by_cases ndivmp : (n / m).prime,
  { use [n / m, ndivmp, ndivmdvd, h1] },
  rcases ih (n / m) ndivmlt ndivmgt2 h1 ndivmp with ⟨p, pp, pdvd, p4eq⟩,
  use [p, pp, pdvd.trans ndivmdvd, p4eq]
end

theorem primes_mod_4_eq_3_infinite : ∀ n, ∃ p > n, nat.prime p ∧ p % 4 = 3 :=
begin
  by_contradiction h,
  push_neg at h,
  cases h with n hn,
  have : ∃ s : finset nat, ∀ p : ℕ, p.prime ∧ p % 4 = 3 ↔ p ∈ s,
  { apply ex_finset_of_bounded,
    use n,
    rintros p ⟨pp, nltp⟩,
    contrapose! nltp,
    exact hn _ nltp pp },
  cases this with s hs,
  have two_le_M : 2 ≤ 4 * (∏ i in erase s 3, i) + 3,
  { linarith },
  have M_mod_4 : (4 * (∏ i in erase s 3, i) + 3) % 4 = 3,
  { rw [add_comm, nat.add_mul_mod_self_left], norm_num },
  rcases exists_prime_factor_mod_4_eq_3 two_le_M M_mod_4 with ⟨p, pp, pdvd, p4eq⟩,
  have ps : p ∈ s,
  { rw ←hs p, exact ⟨pp, p4eq⟩ },
  have pne3 : p ≠ 3,
  { intro peq,
    rw [peq, ←nat.dvd_add_iff_left (dvd_refl 3)] at pdvd,
    rw nat.prime_three.dvd_mul at pdvd,
    norm_num at pdvd,
    have : 3 ∈ s.erase 3,
    { apply mem_of_dvd_prod_primes nat.prime_three _ pdvd,
      intro n, simp [← hs n], tauto },
    simp at this,
    exact this },
  have : p ∣ 4 * (∏ i in erase s 3, i),
  { apply dvd_trans _ (dvd_mul_left _ _),
    apply dvd_prod_of_mem,
    simp, split; assumption },
  have : p ∣ 3,
  { convert nat.dvd_sub' pdvd this, simp },
  have : p = 3,
  { apply pp.eq_of_dvd_of_prime nat.prime_three this },
  contradiction
end

-- OMIT:

/-
Later:
o fibonacci numbers
o binomial coefficients

(The former is a good example of having more than one base case.)

TODO: mention ``local attribute`` at some point.
-/