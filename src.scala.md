% Evolutionary Algorithms

# Core

## Individual

An `Individual` represents a *candidate solution* to a problem. It contains the *genome*, the
genetic information, which, more directly, *is* this candidate solution. It also contains the
*fitness* value of its genome, which will be calculated in advance to the individual creation, so it
can be cached here instead of needing to be reevaluated every time it is accessed. For more
information about fitness and its calculation, see the dedicated [fitness][] section.

```scala
case class Individual[Genome] private[eva4s] (genome: Genome, fitness: Double)
```

The constructor is hidden from end-users on purpose to avoid assigning a wrong fitness value to the
genome. To see how individuals are created, see the [fitness][] section.

## Fitness

The fitness of an individual, in biology, describes its ability to both survive and reproduce. In
the context of evolutionary algorithms it serves as a value describing how *optimal* a candidate
solution is for solving a given problem. It is used by both [environmental selection][] to decide
who survives and [parental selection][] to decide who mates.

The **Fitness** interface is used to calculate the fitness of genomes.

```scala
trait Fitness {
```

It requires a single abstract type, the type of genome of which we want to calculate the fitness.

```scala
  type Genome
```

The main function of this interface returns the fitness value of a given *genome*. This is the only
function of this interface that needs to be implemented by users of this library.

```scala
  def fitness(genome: Genome): Double
```

A secondary, convenience function returns the fitness of a given *individual*. It simply uses the
genome of the given individual.

```scala
  def fitness(individual: Individual[Genome]): Double =
    fitness(individual.genome)
```

The purpose of the following function is the convenient creation of a new individual. It is just a
convenience wrapper around the [Individual][] constructor that uses the correct fitness value
according to the evolutionary algorithm. Use it like any other constructor.

```scala
  def Individual(genome: Genome): Individual[Genome] =
    new Individual(genome, fitness(genome))
}
```
