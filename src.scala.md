% Evolutionary Algorithms

# Core

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
