<<<<<<< HEAD
# talkdesk-features-elixir-poc
=======
# Feature Flags

Talkdesk uses Split to manage Feature Flags. However, the company is taking advantage of clients provided by Split, which does not offer a Elixir client.

The objective of this task is to develop a Proof of Concept (POC) for an Elixir client that connects to Split and is capable of retrieving and validate features.

## Setup

The POC was developed using Elixir version 1.7.3.

To check if you have the correct version use the following command:

```
elixir --version
```

If you do not have the correct version or do not have elixir, you can get it from the [Elixir website](https://elixir-lang.org/install.html).

After getting elixir, install project dependencies with:

```
mix deps.get
```

## Test

To run the tests use:

```
mix test
```

## Start application

To start the application use:

```
iex -S mix
```

With the application running, you can use two commands: get and is_alive.

### get

The get command retrieves a flag with the given name and attributes. If a flag is not available returns the default treatment.

```
FeatureFlags.API.get(name, attrs \\ [], default \\ "off")
```

As an example:

```
flag = FeatureFlags.API.get(
  "CXM_prototype_runtime",
  [{"killed", false}, {"rules", []}],
  "off")
```

### is_alive

The is_alive command checks if a given feature flag is active or not.

```
FeatureFlags.API.is_alive(flag)
```
>>>>>>> Changed project structure.
