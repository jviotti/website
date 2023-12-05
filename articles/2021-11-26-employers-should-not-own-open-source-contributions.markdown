---
title: Employers should not own open-source contributions
date: November 26, 2021
image: generic.jpg
description: This article makes a case on why employers should not attempt to own the IP of the contributions of their employees
---

A growing number of companies across industries depend on open-source software
one way or another, and there is substantial research to back up that claim.
The canonical example is the [2018 Open Source Security and Risk Analysis by
Synopsys](https://www.ciosummits.com/2018_Open_Source_Security_and_Risk_Analysis.pdf)
report, which finds that 96% of more than 1100 analyzed applications include
open-source components and that on average 57% of the codebases consist of
open-source code. Even as early as in 2003, [Lakhani and Wolf
(2003)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=443040) found that
approximately 40% of software engineers that contribute to open-source are paid
by their employers to do so and that "one-third of the respondents in their
survey felt a sense of obligation to give back to the free and open-source
software community." Furthermore, such hacker spirit seems to be finding its
way up to software companies too. For example, [Andersen-Gott, Ghinea and
Bygstad
(2011)](https://www.sciencedirect.com/science/article/pii/S026840121100123X)
found that every company they interviewed expressed a moral obligation to
contribute to open source.

What do employment contracts say?
---------------------------------

Despite the benefits that companies get from open-source and their desire to
contribute back, many companies still offer employment contracts that are not
friendly to open-source contributions from an intellectual property point of
view.

Almost every employment contract I've seen outlines strict intellectual
property ownership claims over any work that cannot be unambiguously proven to
not be related to the company. Some companies go the extra mile to claim full
ownership of every idea, invention, or contribution that the employee might
create during their time of employment, even if such work was performed during
their free time and without competing with the employer in any way.

In other words, companies typically own a part of your intellectual property
that includes open-source contributions and in some cases unquestionably own
all of it.

So what is the problem?
-----------------------

Depending on the type of work you do for your employer, such intellectual
property conditions make sense. However, I argue that such clauses often become
a problem for software engineers for whom open-source is a key part of their
roles.

For example, imagine that your company develops an application using a certain
open-source framework. Sooner or later, your company will be interested in
hiring software engineers that are intimately familiar with such framework.
The natural way the find these people is to look for those involved in the
open-source project either as casual contributors or appointed members of its
governance. When one of these software engineers joins your company, they will
likely produce open-source contributions that are directly related to the
company's application. They will also produce open-source contributions in
their free time as part of their overall involvement which might have an impact
on the company's application either directly or indirectly. Under such a
scenario, whether an open-source contribution is owned by the company or not
quickly becomes ambiguous. Such ambiguity then results in various problems:

- **Contributor License Agreements (CLAs)**: The contributor might not be able
  to sign CLAs as an individual as in many cases, the potential contribution
  might not be their intellectual property. Contributors don't sign CLAs for
  every individual contribution, so typically employees need to get the company
  to sign the CLAs to be on the safe side. Getting companies to sign CLAs,
  adhering to any additional requirements they might impose (like using a
  company e-mail for commits), and having them maintain the white-list of
  employees that are allowed to contribute involves a significant overhead for
  both the contributor and the company. On top of that, not every open-source
  project has a process in place to accept contributions that involve
  company-owned intellectual property.

- **Current Contract Violations**: The ambiguous nature of such contributions
  often means that there is a surprising amount of existing employees
  unknowingly violating their contracts by signing CLAs as individuals and
  upstreaming contributions that are arguably owned by the company. Employers
  do not typically chase down employees for these minor violations but
  employees are still likely to feel uncomfortable once they realize what the
  contract has to say about that.

- **Scare Away Open Source Talent**: Attracting key open-source talent into a
  company can have a significant positive impact on the organization. However,
  open-source talent is typically sensitive to intellectual property clauses.
  An excellent candidate at the offer stage might object or even refuse to sign
  a contract that significantly impacts the roles that such candidate might
  have in one or more open-source projects. On the flip side, a set of
  intellectual property clauses that are friendly to open-source attracts
  open-source talent into the company.

How can we fix this?
--------------------

To solve this problem, contracts can be modified to permit and encourage
open-source contributions with no intellectual property rights back to the
company, while still protecting the competitive advantage of the proprietary
software developed by the company. An example clause that serves this purpose
reads like this:

> The Company shall not own any intellectual property, under any
circumstances, over contributions made to open-source projects not owned by
Company, independently of whether these external open-source contributions
impact Company directly or indirectly, resulted from work done at Company, and
independently of whether or not these external open-source contributions are
created using equipment provided by Company or not.

This clause helps employees from accidentally violating their contracts
regarding open-source contributions, allows employees to sign CLAs as
individuals, allows them to easily upstream any open-source patch they create,
encourages them to make open-source contributions time and attracts and retains
key members of the open-source community.

Parting thoughts
----------------

A company's competitive advantage is rarely a set of "secret" patches to a set
of external open-source projects. If that was the case, the company would not
exist if it wasn't for such open-source projects. Liberating open-source
contributions from intellectual property ties benefits employees and employers
while fostering the idea of free software that has undoubtedly changed the
world.
