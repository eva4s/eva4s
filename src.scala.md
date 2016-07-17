% Evolutionary Algorithms

**TODO:** Use RNG in all places where relevant to allow reproducible evolution. Also, use
[[Reporter]] to log RNG seed.

# Introduction

## What is an Evolutionary Algorithm?

**TODO**

## About Optimization Problems

**TODO**

## Namespacing

The namespacing package of this project is called `eva4s`.

```scala
package object eva4s {
```

## Type Aliases

The base package object provides a convenient type alias for a pair of [individuals][Individual], a
**Couple**. Such a couple is used in some places of the library, when recombining individuals to new
children, namely the [recombination][] interface and its companion [parental selection][]. This type
alias helps both the library and its users to write more concise and expressive source code.

```scala
  /** Type alias for a pair of individuals. */
  type Couple[Genome] = (Individual[Genome],Individual[Genome])
```

The **Mutagen** function type alias helps clarify its otherwise unspecific function type
signature. Mutagens are explored in more detail in the [controlling mutation][] section.

```scala
  /** Type alias for a mutagen function. */
  type Mutagen = Int => Double
}
```

**TODO:** The probability value of a mutagen should be constrained with type information, i.e. it
should only allow values between zero (0%) and one (100%). This should be enforced by the type
system and the compiler, possibly with tagged types, plain `Double` is simply too broad.

# Core Abstractions

This chapter includes all of the abstractions that are required for users of this library to
implement their own [evolutionary algorithm][].

## Individual

An `Individual` represents a *candidate solution* to a problem. It contains the *genome*, the
genetic information, which, more directly, *is* this candidate solution. It also contains the
*fitness* value of its genome, which will be calculated in advance to the individual creation, so it
can be cached here instead of needing to be reevaluated every time it is accessed. For more
information about fitness and its calculation, see the [fitness][] section.

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
    Individual(genome, fitness(genome))
}
```

## Creation

The **Creation** interface provides the convenient *creation* of individuals. These individuals
genomes are expected to be generated *in a random fashion*. These randomly generated individuals
are used by [[Evolver]] implementations for the initial generation.

This interface extends [Fitness][] for its convenient `Individual` constructor. The abstract
`Genome` type is also inherited from `Fitness`.

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
genomes are expected to be mutated *randomly*. **TODO:** Describe purpose of this interface.

This interface extends [Fitness][] for its convenient `Individual` constructor. The abstract
`Genome` type is also inherited from `Fitness`.

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

The **Recombination** interface provides the convenient *recombination* of individuals.
**TODO:** Describe purpose of this interface.

This interface extends [Fitness][] for its convenient `Individual` constructor. The abstract
`Genome` type is also inherited from `Fitness`.

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
**problem** instance that is to be solved. This problem instance is supposed to be overridden with
a simple value.

```scala
  type Problem

  /** Returns the problem to solve. */
  def problem: Problem
}
```

# Evolution

This chapter focuses on how an [evolutionary algorithm][] is processed.

## Evolver

An **Evolver** runs an evolutionary algorithm. It is to an evolutionary algorithm what an executor
is to a thread. Whether an evolutionary algorithm is run sequentially, in parallel or distributed,
depends on the `Evolver` implementation.

```scala
/** Runs an evolutionary algorithm. */
trait Evolver {
```

The main function of this interface runs the given evolutionary algorithm and returns the fittest
individual after the evolution.

```scala
  /** Returns the fittest individual after evolution. */
  def apply[Genome,Problem](eva: EvolutionaryAlgorithm): Individual[eva.Genome]
```

An evolver also contains a `Reporter` which reports on the progress of the evolution from generation
to generation. For more information, see the dedicated [reporter][] section below. This reporter
instance is supposed to be overridden by a simple value.

```scala
  /** Returns the used reporter. */
  def reporter: Reporter
}
```

## SingleEvolver

An evolver that recombines individuals as often as given by a fixed amount and reduces all
individuals, *including* the parent generation, to a fixed population size. Each child may
be mutated by the probability given by the [Mutagen][].

Both [selecting][environmental selection] and [matchmaking][parental selection] drive this
evolver, though it depends on the amount of survivers and pairs in which ratio.

```scala
package eva4s
package evolving

import scala.annotation.tailrec
import scala.util.Random

class SingleEvolver(
  generations: Int = 200,
  survivers: Int = 23,
  pairs: Int = 100,
  matchmaker: Matchmaker = matchmaking.RandomForcedMatchmaker,
  mutagen: Mutagen = mutating.ConstantMutagen(0.3),
  selecter: Selecter = selecting.PlusSelecter,
  val reporter: Reporter = Reporter.ConsoleReporter)
    extends Evolver {

  def apply(eva: EvolutionaryAlgorithm) = {
    val ancestors = Vector.fill(survivers)(eva.Ancestor)

    @tailrec
    def evolve(generation: Int, parents: Seq[Individual[eva.Genome]]): Individual[eva.Genome] = {
      if (generation == generations) {
        parents minBy { _.fitness }
      } else {
        val mutationProbability = mutagen(generation)

        val offspring = for {
          pair <- matchmaker.findPairs(pairs, parents)
          child = eva.Child(pair)
        } yield if (Random.nextDouble < mutationProbability) eva.Mutant(child) else child

        val nextGeneration = selecter.select(parents, offspring)

        reporter.report(generation, offspring)
        evolve(generation = generation + 1, parents = nextGeneration)
      }
    }

    val fittest = evolve(generation = 1, parents = ancestors)
    reporter.report(generations, fittest)
    fittest
  }

}
```

## Reporter

A **Reporter** reports on the progress of the evolution. It may report by logging to a file, to the
console, to a graphical user interface or it may do simply nothing.

```scala
/** Reports on the progress of the evolution. */
trait Reporter {
```

The following function reports on an evolutionary step. This information may be about the currently
fittest individual or the average fitness.

```scala
  /** Reports statistics of an evolutionary step. */
  def report(generation: Int, offspring: Seq[Individual[_]]): Unit
```

The following function reports on the last evolutionary step, namely the fittest individual.

```scala
  /** Reports the fittest individual of the final generation. */
  def report(generation: Int, fittest: Individual[_]): Unit
}
```

The `Reporter` companion object contains simple, default reporter implementations. It also contains
a composite reporter that can be used to combine multiple reporter instances.

```scala
/** Contains simple reporter implementations. */
object Reporter {
```

A simple reporter that writes to the [standard output stream](https://en.wikipedia.org/wiki/stdout).

```scala
  /** Prints simple statistics to STDOUT. */
  object ConsoleReporter extends Reporter {
```

The progress report on the evolutionary steps prints the generation, the best, average and worst
fitness.

```scala
    def report(generation: Int, offspring: Seq[Individual[_]]): Unit = {
      val fittest = offspring.minBy(_.fitness)
      val unfittest = offspring.maxBy(_.fitness)
      val average = offspring.foldLeft(0.0)(_ + _.fitness) / offspring.size

      Console.println(s"""gen: $generation fit: $fittest average: $average unfit: $unfittest""")
    }
```

The fittest individual is also just printed.

```scala
    def report(generation: Int, fittest: Individual[_]): Unit = {
      Console.println(fittest)
    }
  }
```

A reporter implementation that simply does nothing. Use it, if reporting is irrelevant and the
fittest individual is the only relevant information you want from running an evolutionary
algorithm.

```scala
  /** Does nothing. */
  object None extends Reporter {
    def report(generation: Int, offspring: Seq[Individual[_]]): Unit = ()
    def report(generation: Int, fittest: Individual[_]): Unit = ()
  }
```

Finally, there is also a composite reporter. Via its companion object factory you can supply a list
of reporters which will all be run in the sequence they are provided.

```scala
  /** Reports to a list of subordinate reporters. */
  case class Composite private (reporters: List[Reporter]) extends Reporter {

    def report(generation: Int, offspring: Seq[Individual[_]]): Unit =
      reporters.foreach(_.report(generation, offspring))

    def report(generation: Int, fittest: Individual[_]): Unit =
      reporters.foreach(_.report(generation, fittest))

  }

  /** Factory for composite reporters. */
  object Composite {

    /** Returns a new composite reporter. */
    def apply(reporters: Reporter*) =
      new Composite(reporters.toList)

  }

}
```

# Controlling Evolution

## Environmental Selection

Environmental selection determines how the individuals for the next generation are chosen.

### Selecter

A **Selecter** determines how the individuals for the next generation are chosen. The amount of
individuals returned equals the size of the parent generation.

Selecter implementations may choose whether or not to include the parent generation in the selecting
process or if they just want to consider the offspring.

```scala
/** Determines how the individuals for the next generation are chosen. */
trait Selecter {

  /** Returns the fittest individuals. */
  def select[Genome](parents: Seq[Individual[Genome]], offspring: Seq[Individual[Genome]]): Seq[Individual[Genome]]

}
```

### Plus Selection

```scala
/** A deterministic selecter which chooses the fittest individuals.
  *
  * Plus selection aka (\mu+\lambda) selection represents an elitist selection, which
  * deterministically chooses the best \mu individuals form all individuals, i.e. parents (\mu) and
  * offspring (\lambda).
  */
object PlusSelecter extends Selecter {

  def select[Genome](parents: Seq[Individual[Genome]], offspring: Seq[Individual[Genome]]): Seq[Individual[Genome]] = {
    (parents ++ offspring).sortBy(_.fitness).take(parents.size)
  }

}
```

## Parental Selection

### Matchmaker

```scala
/** A matchmaker pairs individuals up with each other. It models parental selection.
  *
  * @note You can find matchmaker implementations in the [[matchmaking]] package.
  */
trait Matchmaker {

  /** Returns a specified amount of pairs out of the individuals. */
  def findPairs[Genome](pairs: Int, individuals: Seq[Individual[Genome]]): Seq[Couple[Genome]]

}
```

### Random Forced Matchmaker

```scala
import util.collection._

/** A matchmaker implementation that returns af fixed amount of arbitrary pairs of individuals.
  *
  * This is the simplest form of probabilistic matchmaking.
  */
object RandomForcedMatchmaker extends Matchmaker {

  def findPairs[Genome](pairs: Int, parents: Seq[Individual[Genome]]): Seq[Couple[Genome]] = {
    Vector.fill(pairs)(parents.choosePair)
  }

}
```

## Controlling Mutation

A **Mutagen** determines the probability with which individuals mutate, depending on the current
generation.

### Constant Mutagen

```scala
/** A mutagen that always has the same probability. */
case class ConstantMutagen(probability: Double) extends Mutagen {
  def apply(generation: Int): Double = probability
}
```

# Evolutionary Algorithm Applications

```scala
/** This class can be used to quickly run an evolutionary algorithm with an evolver. Here is an
  * example to showcase how to implement this:
  *
  * {{{
  * object Example extends EvolutionaryApp {
  *   type Genome =
  *   type Problem =
  *
  *   val eva = new EvolutionaryAlgorithm[Genome,Problem]] {
  *     val problem =
  *     def fitness(genome: Genome) =
  *     ...
  *   }
  *
  *   val evolver = new evolving.SingleEvolver()
  * }
  * }}}
  */
abstract class EvolutionaryApp {

  /** Returns the used evolutionary algorithm. */
  def eva: EvolutionaryAlgorithm[_,_]

  /** Returns the used evolver. */
  def evolver: Evolver

  /** Runs the evolutionary algorithm through the evolver. */
  def main(args: Array[String]): Unit = {
    val _ = evolver(eva)
  }

}
```

## Example Applications

This example uses the mathematical function **f(x) = x<sup>2</sup> + 4** which has a global minimum
at (0,4). Thus the through the evolution generated optimal Individual should be close to a genome of
**0** and fitness of **4**. This evolutionary algorithm will start with larger randomly generated
**x**-values, mutate only slightly by adding / subtracting **1** to the genome and recombining by
building the average of the genomes. You should be able to observe the impact on how fast the
algorithm converges to the optimum by fiddling around with these functions as well as the parameters
of the evolver.

```scala
package org.example

import eva4s._

object Example extends EvolutionaryApp {
  val eva = new EvolutionaryAlgorithm[Double,Function[Double,Double]] {
    val problem = (x: Double) => x * x + 4
    def fitness(genome: Double) = problem(genome)
    def ancestor: Double = util.Random.nextDouble() * 1000
    def mutate(genome: Double): Double = if (util.Random.nextBoolean()) genome + 1 else genome - 1
    def recombine(g1: Double, g2: Double) = (g1 + g2) / 2
  }

  val evolver = new evolving.SingleEvolver()
}
```

# Utility

## Collections

```scala
import scala.language.higherKinds
import scala.util.Random

object collection {

  implicit class SeqEnhancements[CC[X] <: Seq[X],X](coll: CC[X]) {

    def shuffle: Seq[X] = coll.map(_ -> Random.nextLong).sortBy(_._2).map(_._1)

    def choose(n: Int): Seq[X] = shuffle.take(n)

    def choosePair: (X,X) = {
      val two = choose(2)
      (two(0),two(1))
    }

  }

}
```
