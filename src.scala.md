% Evolutionary Algorithms

# Introduction

## Namespacing

The namespacing package of this project is called `eva4s`.

```scala
package object eva4s {
```

The base package object provides a convenient type alias for a pair of [individuals][Individual], a
**Couple**. Such a couple is used in some places of the library, when recombining individuals to new
children, namely the [recombination][] interface and its companion [parental selection][]. This type
alias helps both the library and its users to write more concise and expressive source code.

```scala
  /** Type alias for a pair of individuals. */
  type Couple[Genome] = (Individual[Genome],Individual[Genome])
}
```

# Core Abstractions

This chapter includes all of the abstractions that are required for users of this library to
implement their own [evolutionary algorithm][].

## Individual

An `Individual` represents a *candidate solution* to a problem. It contains the *genome*, the
genetic information, which, more directly, *is* this candidate solution. It also contains the
*fitness* value of its genome, which will be calculated in advance to the individual creation, so it
can be cached here instead of needing to be reevaluated every time it is accessed. For more
information about fitness and its calculation, see the dedicated [fitness][] section.

```scala
/** Represents a candidate solution of a problem along with its fitness. */
case class Individual[Genome] private[eva4s] (genome: Genome, fitness: Double)
```

The constructor is hidden from end-users on purpose to avoid assigning a wrong fitness value to the
genome. To see how individuals are created, see the [fitness][] section.

## Fitness

In biology, the fitness of an individual, describes its ability to both survive and reproduce. In
the context of evolutionary algorithms the fitness value tells us how *optimal* a given candidate
solution is for solving a given problem. Fitness is used by both [environmental selection][] to
decide who survives and [parental selection][] to decide who mates.

The **Fitness** interface is used to calculate the fitness of genomes.

```scala
/** Calculates the fitness value of genomes. */
trait Fitness {
```

It requires a single abstract type, the type of genome of which we want to calculate the fitness.

```scala
  /** Genome type of the individuals. */
  type Genome
```

The main function of this interface returns the fitness value of a given *genome*. This is the only
function of this interface that needs to be implemented by users of this library.

```scala
  /** Returns the fitness value of the given genome. */
  def fitness(genome: Genome): Double
```

The purpose of the following function is the convenient creation of a new individual. It is just a
convenience wrapper around the [Individual][] constructor that uses the correct fitness value
according to the evolutionary algorithm. Use it like any other constructor.

```scala
  /** Returns a new individual from the given genome. */
  final def Individual(genome: Genome): Individual[Genome] =
    new Individual(genome, fitness(genome))
}
```

## Creation

The **Creation** interface provides the convenient *creation* of individuals. These individuals
genomes are expected to be generated *randomly*. It extends [Fitness][] for its convenient
`Individual` constructor. The abstract `Genome` type is also inherited from `Fitness`.

```scala
/** Creates randomly generated individuals. */
trait Creation extends Fitness {
```

The main function of this interface returns a newly generated *genome*, which, as explained above,
is supposed to be generated randomly. This is the only function of this interface that needs to be
implemented by users of this library.

```scala
  /** Returns a randomly generated genome. */
  def ancestor: Genome
```

The following convenience function directly returns a new individual using a new, randomly generated
`ancestor` genome. It utilizes the individual constructor of [Fitness][].

```scala
  /** Returns a randomly generated individual. */
  final def Ancestor: Individual[Genome] =
    Individual(ancestor)
}
```

## Mutation

The **Mutation** interface provides the convenient *mutation* of individuals. These individuals
genomes are expected to be mutated *randomly*. It extends [Fitness][] for its convenient
`Individual` constructor. The abstract `Genome` type is also inherited from `Fitness`.

```scala
/** Mutates genomes. */
trait Mutation extends Fitness {
```

The main function of this interface returns a new, mutated *genome*, which, as explained above, is
supposed to be mutated randomly. This is the only function of this interface that needs to be
implemented by users of this library.

```scala
  /** Returns a new genome by mutating the given one. */
  def mutate(genome: Genome): Genome
```

The following convenience function directly returns a new individual using a new, randomly mutated
genome. It utilizes the individual constructor of [Fitness][].

```scala
  /** Returns a new individual by mutating the given one. */
  final def Mutant(individual: Individual[Genome]): Individual[Genome] =
    Individual(mutate(individual.genome))
}
```

## Recombination

The **Recombination** interface provides the convenient *recombination* of individuals. It extends
[Fitness][] for its convenient `Individual` constructor. The abstract `Genome` type is also
inherited from `Fitness`.

```scala
/** Recombines genomes. */
trait Recombination extends Fitness {
```

The main function of this interface returns a new *genome* by recombining the given ones. This is
the only function of this interface that needs to be implemented by users of this library.

```scala
  /** Returns a new genome by recombining the given ones. */
  def recombine(g1: Genome, g2: Genome): Genome
```

The following convenience function directly returns a new child individual by recombining the given
pair of parents. It utilizes the individual constructor of [Fitness][].

```scala
  /** Returns a new individual by recombining the given pair of parents. */
  final def Child(parents: Couple[Genome]): Individual[Genome] =
    Individual(recombine(parents._1.genome, parents._2.genome))
}
```

## Evolutionary Algorithm

Finally, an **Evolutionary Algorithm** is the combination of [Creation][], [Mutation][] and
[Recombination][].

```scala
trait EvolutionaryAlgorithm extends Creation with Mutation with Recombination {
```

It is completed by the addition of the **Problem** type and a function that returns the particular
**problem** instance that is to be solved. This problem instance is supposed to be overridden by a
simple value.

```scala
  type Problem

  /** Returns the problem to solve. */
  def problem: Problem
}
```

# Evolution

This chapter focuses on how an [evolutionary algorithm][] gets executed.

## Evolver

An **Evolver** executes an evolutionary algorithm. It is to an evolutionary algorithm what an
executor is to a thread. How an evolutionary algorithm is executed, i.e. sequential, parallel,
distributed, depends on the `Evolver` implementation.

```scala
/** Executes an evolutionary algorithm. */
trait Evolver {
```

The main function of this interface runs the given evolutionary algorithm and returns the fittest
individual after the evolution.

```scala
  /** Returns the fittest individual after evolution. */
  def apply[Genome,Problem](eva: EvolutionaryAlgorithm[Genome,Problem]): Individual[Genome]
}
