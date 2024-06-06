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

### Objective Function

When working on an optimization problem, we work towards
maximizing or minimizing an objective function. The objective
function of UC problem can be modified as

<!-- $$
\begin{equation}
    \min _{u(i, t) ; p(i, t)} \sum_{t=1}^{T} \sum_{i=1}^{N}\left\{C_{i}[p(i, t)]+S C_{i}[u(i, t)]\right\}
\end{equation}\
$$ --> 

<div align="center"><img style="background: white;" src="svg\BgqJFoaT18.svg"></div>

### System Constraints

 Power balance constraints: The total unit generation output
must satisfy the system load demand requirement at each time step
t, therefore

<!-- $$
\begin{equation}
    \sum_{i=1}^{N} u(i, t) p(i, t)=L(t)
\end{equation}
				
where is $L(t) $ the load demand.
$$ --> 

<div align="center"><img style="background: white;" src="svg\1obPLKMjBu.svg"></div>

2) Reserve generation capacity: Spinning reserve is the term used
to describe the total amount of generation available from all units
synchronized (i.e., spinning) on the system, minus the present load
and losses being supplied

<!-- $$
\begin{equation}
    \sum_{i=1}^{N} u(i, t)\left[P_{i}^{\max }-p(i, t)\right] \geq R(t)\\
\end{equation}
$$ --> 

<div align="center"><img style="background: white;" src="svg\IH9RmG3xF1.svg"></div>

### Unit Constraints

1) Maximum/Minumum generation limits: For each committed
unit, the power generation p(i, t) should be within the generation
limits of the unit, i.e. between its minimum and maximum possible
generation. This can be expressed as:

<!-- $$
\begin{equation}
    u(i, t) P_{i}^{\min } \leq p(i, t) \leq u(i, t) P_{i}^{\max } \quad \forall i \in N, t \in 1 \ldots T
\end{equation}
$$ --> 

<div align="center"><img style="background: white;" src="svg\wwnJVmz037.svg"></div>

2) Minimum up time and down time: Once a plant turns on, it
must stay on for a certain number of hours before it can be turned
off again. Similarly, once off it must stay off for a certain number of
hours before it can be turned on again.

<!-- $$
\begin{align}
    \text { If } u(i, t)=&1 \text { and } t_{i}^{u p}<t_{i}^{u p, \min } \text { then } u(i, t+1)=1\\
    \text { If } u(i, t)=&0 \text { and } t_{i}^{\text {down }}<t_{i}^{\text {down }, \min } \text { then } u(i, t+1)=0
\end{align}
$$ --> 

<div align="center"><img style="background: white;" src="svg\j5irMHPiQ5.svg"></div>

3) Maximum ramp rates: To avoid damaging the turbine, the
electrical output of a unit cannot change by more than a certain
amount over a period of time.

<!-- $$
\begin{align}
    \text{Ramp up}\rightarrow \quad &p(i, t+1)-p(i, t) \leq \Delta P_{i}^{u p, \max }\\
    \text{Ramp down}\rightarrow \quad &p(i, t)-p(i, t+1) \leq \Delta P_{i}^{\text {down }, \max }
\end{align}
$$ --> 

<div align="center"><img style="background: white;" src="svg\jldrNVpkTr.svg"></div>

4) Unit Hot/Cold Start Constraints: A recently shut-down plant
generally is quicker and more efficient to start-up than a cooled one.
This difference in cost can be modeled in the costfunction. We assume
a step-function for the cost. If a plant is turned off within some time
period, it only requires the cold start cost, else the hot-start cost. This
is expressed below

<!-- $$
\begin{equation}
    \text { StartupCost }= \begin{cases}\text { hotstartcost, } & \text { if down-time } \leq \text { cold start } \mathrm{T} \\ \text { coldstartcost, } & \text { otherwise }\end{cases}
\end{equation}
$$ --> 

<div align="center"><img style="background: white;" src="svg\elXRkR1WXE.svg"></div>

Unit restrictions such as offline time, maintenance schedule, security constraints, and so on are not included but can be represented in addition to those proposed above.