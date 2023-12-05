---
title: Evolutive Integration Testing of HTTP APIs with OpenAPI
date: October 30, 2018
image: generic.jpg
description: This article describes an experimental approach to describing HTTP API integration tests
---

Automated tests are vital to prevent regressions and find problems early on,
but the value they offer is proportional to the tester’s skills.

Automating the process of writing automated tests is the premise behind
property-based and generative testing. Testers write logical statements about
the system, and the test framework produces test cases with semi-random inputs
to break such properties.

This technique works well if what you are testing is representable as a logical
invariant, but not so much for stateful higher-level integration test cases.

Leaving outliers aside, users try to use software for its intended purpose. In
my experience, most impactful bugs occur on untested subtle variations from the
happy path.

For this reason, a core part of my testing process is to write test cases for
the happy path and then come up with variations.

Can we automate this process?
-----------------------------

We can’t do non-trivial automated mutation of test cases without
making assumptions over the software under test and the structure of the test
cases themselves.

In this article, I’ll consider HTTP APIs, who share well-understood semantics
thanks to the HTTP protocol, along with [OpenAPI](https://www.openapis.org), a
specification to describe APIs that allows us to understand in more depth how
the software uses the HTTP protocol to do its job.

Developers write integration test cases in full-featured programming languages,
which makes tests hard to analyze and change without breaking their semantics.

For this reason, lets consider a simple DSL tuned to write HTTP integration
test cases.

Mutating Test Cases
-------------------

Here is a non-exhaustive list of transformations:

- Pick any HTTP request that includes a required property in the body (check
  with the OpenAPI spec), omit it, assert that the status code is `400 Bad
  Request`, and discard the remaining of the test case

- Pick any HTTP request that includes a required header (check with the OpenAPI
  spec), omit it, assert that the status code is 4xx, and discard the remaining
  of the test case

- Pick any HTTP request that includes an optional property in the body (check
  with the OpenAPI spec), omit it, assert that the status code is the same as
  when the optional property was there, ignore the assertions on the response
  body, and discard the remaining of the test case

- Pick any HTTP request and an alternated undefined HTTP method for that same
  path (except `OPTIONS` and `TRACE`) (check the OpenAPI spec), use the
  undefined HTTP method, assert that the status code is `405 Method Not
  Allowed`, and discard the remaining of the test case

- If the OpenAPI spec defines more than one server, pick a test case that
  performs more than one HTTP request, randomly assign servers to each HTTP
  request in the test case, and leave the assertions intact

- Pick a `PATCH` or `PUT` HTTP request, duplicate those requests X times in a
  row, and leave the assertions intact

- Pick a `PATCH` request, remove all parameters, assert that the status code is
  `400 Bad Request`, and discard the remaining of the test case

- Pick a `DELETE` HTTP request, duplicate those requests X times in a row,
  assert that all `DELETE` requests other than the first ones result in `404
  Not Found`, and leave the other assertions intact

Consider the following DSL test case that creates a device, fetches it back,
changes the name, and fetches it back again, and deletes it. We also have a
spec that defines that there are two instances of the server running at
`localhost:8000` and `localhost:8001`:

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
{ Id2, Name2, Color2 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id2 = Id
ASSERT Name2 = "Device Bar"
ASSERT Color2 = "red"
200 DELETE localhost:8000/api/v1/device/{Id}
404 GET localhost:8000/api/v1/device/{Id}
```

Here is one possible set of mutations that could result from a one-pass of the
above algorithms:

```
400 POST localhost:8000/api/v1/device color="red"
```

```
201 POST localhost:8000/api/v1/device name="Device Foo"
```

```
405 PUT localhost:8000/api/v1/device name="Device Foo" color="red"
```

```
405 DELETE localhost:8000/api/v1/device name="Device Foo" color="red"
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
405 POST localhost:8000/api/v1/device/{Id}
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
405 POST localhost:8000/api/v1/device/{Id} name="Device Bar"
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
405 POST localhost:8000/api/v1/device/{Id}
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
{ Id2, Name2, Color2 } := 200 GET localhost:8001/api/v1/device/{Id}
ASSERT Id2 = Id
ASSERT Name2 = "Device Bar"
ASSERT Color2 = "red"
200 DELETE localhost:8000/api/v1/device/{Id}
404 GET localhost:8000/api/v1/device/{Id}
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
200 PATCH localhost:8001/api/v1/device/{Id} name="Device Bar"
{ Id2, Name2, Color2 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id2 = Id
ASSERT Name2 = "Device Bar"
ASSERT Color2 = "red"
200 DELETE localhost:8000/api/v1/device/{Id}
404 GET localhost:8000/api/v1/device/{Id}
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
{ Id2, Name2, Color2 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id2 = Id
ASSERT Name2 = "Device Bar"
ASSERT Color2 = "red"
200 DELETE localhost:8000/api/v1/device/{Id}
404 GET localhost:8000/api/v1/device/{Id}
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
{ Id2, Name2, Color2 } := 200 GET localhost:8000/api/v1/device/{Id}
ASSERT Id2 = Id
ASSERT Name2 = "Device Bar"
ASSERT Color2 = "red"
200 DELETE localhost:8000/api/v1/device/{Id}
404 DELETE localhost:8000/api/v1/device/{Id}
404 DELETE localhost:8000/api/v1/device/{Id}
404 GET localhost:8000/api/v1/device/{Id}
```

```
{ Id, _, _ } := 201 POST localhost:8000/api/v1/device name="Device Foo" color="red"
{ Id1, Name1, Color1 } := 200 GET localhost:8001/api/v1/device/{Id}
ASSERT Id1 = Id
ASSERT Name1 = "Device Foo"
ASSERT Color1 = "red"
200 PATCH localhost:8000/api/v1/device/{Id} name="Device Bar"
{ Id2, Name2, Color2 } := 200 GET localhost:8001/api/v1/device/{Id}
ASSERT Id2 = Id
ASSERT Name2 = "Device Bar"
ASSERT Color2 = "red"
200 DELETE localhost:8000/api/v1/device/{Id}
404 GET localhost:8001/api/v1/device/{Id}
```

Even with some rules omitted, we expanded a single medium-sized integration
test case into 12 integration test cases. We may even consider mutating the
mutated results to get more test cases.

Overall, this approach is not about finding a way for testers to write fewer
tests, but a way for those same tests to have much more impact, and unveil the
most common bugs as early as possible.
