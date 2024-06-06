# Dynamic Programming for Unit Commitment

## Introduction

Due to the nature of human activities, customers’ electricity demand change on a regular basis. To deal with these cyclic variations, the dispatcher must turn on just enough generating units to match the load demand at each interval of the scheduling horizon. This is
the primary goal of Unit Commitment (UC). Another purpose of unit commitment in regulated industry is to reduce operational costs while
meeting demand [1].
Optimal unit commitment problem can be stated as “Determine an optimal pattern for the start up and shut down of generators in
order to minimize the total operating cost during a period of study called the scheduling horizon without violating any of the operating
constraints” [2].
The short-term unit commitment challenge is to calculate the optimum operating level of the available generating units for each
hour of the following day and for up to seven days in order to meet the forecasted level of demand with the lowest operating cost while
meeting all of the physical and operational restrictions of the power system. Some of the more common constraints incorporated to the
unit commitment problem are load balance, spinning reserve, scheduled reserve, offline reserve, must-run units, and fuel consumption,
among others. Constraints that are particular to thermal units include minimum and maximum up and down time limits, start-up costs, and
minimum and maximum generation limits [1].
To have a complete solution of unit commitment problem, the economic dispatch problem (EDP) must be solved as well. There are
two possible ways to do this; the first is to obtain a unit commitment schedule then an economic dispatch is found for this schedule. The
other way is to solve both UCP and EDP simultaneously. This makes the problem more difficult to solve. Yet, it is believed that the second
method guarantees a more optimal commitment schedule to be found [2]. In this paper the latter is being employed through dynamic
programming.
This paper is organized as follows. Section II explains the operation and technical constraints of unit commitment problem. The dynamic
programming model used to represent the unit commitment problem is discussed in Section III. In addition, the sample UC problem is
presented followed by the resulting schedule of the start-up and shut down of generators. Finally, Section V concludes the paper.

## Unit Commitment Problem Formulation

### Notation

<!-- $$
    \begin{aligned}
            u(i, t):& \quad \quad   \text {Status of 	unit i at period t }\\
            p(i, t):& \quad \quad \text {Power produced 	by unit i during period } \mathrm{t}\\
            C_{i}[p(i, t)]:& \quad \quad \text {Running 	cost of unit i during period t }\\
            S C_{i}[u(i, t)]:& \quad \quad \text 	{Start-up cost of unit i during period t }\\
            N=& \quad \quad \text {Number of available 	generating units}\\
            T=& \quad \quad \text {Number of periods in 	the optimization horizon}\\
    \end{aligned}
$$ --> 

<div align="center"><img style="background: white;" src="svg\ew908eWgMN.svg"></div>