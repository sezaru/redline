defmodule Test.RedlineTest do
  alias Test.Redline.Pipelines.{Pipeline1, Pipeline2}

  use ExUnit.Case

  defmodule Pipeline do
    use Redline, name: :pipeline, input: :some_input, state: %{some: :state}
  end

  test "__using__/1 creates a new pipeline" do
    assert Pipeline.name() == :pipeline
    assert Pipeline.new() == %{some: :state}
    assert Pipeline.options() == [name: :pipeline, input: :some_input]
  end

  test "new/0 returns the pipeline state" do
    assert Pipeline1.new() == %{results: %{}, states: %{}}

    assert Pipeline2.new() == %{results: %{}, states: %{}}
  end

  test "run/1 runs pipeline" do
    assert {value, state} = Pipeline1.run(1)

    assert value == 9

    assert state.results == %{step_1: 2, step_2: 4, step_3: 5, step_4: 9, step_1_b: 3}
    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}, step_4: %{}, step_1_b: %{}}

    assert {value, state} = Pipeline2.run(1)

    assert value == :stop

    assert state.results == %{step_a: 2, step_b: 2, step_1: :stop, step_4: 4}
    assert state.states == %{step_a: %{}, step_b: %{}, step_1: %{last: 2}, step_4: %{}}
  end

  test "run/2 runs pipeline" do
    state = Pipeline1.new()

    assert {value, state} = Pipeline1.run(1, state)

    assert value == 9

    assert state.results == %{step_1: 2, step_2: 4, step_3: 5, step_4: 9, step_1_b: 3}
    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}, step_4: %{}, step_1_b: %{}}

    state = Pipeline2.new()

    assert {value, state} = Pipeline2.run(1, state)

    assert value == :stop

    assert state.results == %{step_a: 2, step_b: 2, step_1: :stop, step_4: 4}
    assert state.states == %{step_a: %{}, step_b: %{}, step_1: %{last: 2}, step_4: %{}}

    assert {value, state} = Pipeline2.run(2, state)

    assert value == [5, 6]

    assert state.results == %{step_a: 3, step_b: 3, step_1: 5, step_4: 6}
    assert state.states == %{step_a: %{}, step_b: %{}, step_1: %{last: 3}, step_4: %{}}
  end
end
