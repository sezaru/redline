defmodule Test.Redline.Impl.ParallelTest do
  alias Redline.Impl.Parallel

  alias Test.Redline.Steps.{Step1, Step2, Step3, Step4, Step1WithState, Step1WithError}

  use ExUnit.Case

  test "run_step/2 runs a step in parallel" do
    state = %{results: %{step_1: 2}, states: %{step_1: %{}}}

    step = [{Step2, %{input: :step_1, name: :step_2}}, {Step3, %{input: :step_1, name: :step_3}}]

    {value, state} = Parallel.run_step(state, step)

    assert value == [4, 5]

    assert state.results == %{step_1: 2, step_2: 4, step_3: 5}
    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}}
  end

  test "run_step/2 runs a step in parallel with multiple inputs" do
    state = %{results: %{step_2: 1, step_3: 2}, states: %{step_2: %{}, step_3: %{}}}

    step = [
      {Step4, %{name: :step_4_a, inputs: [:step_2, :step_3]}},
      {Step4, %{name: :step_4_b, inputs: [:step_2, :step_3]}}
    ]

    {value, state} = Parallel.run_step(state, step)

    assert value == [3, 3]

    assert state.results == %{step_2: 1, step_3: 2, step_4_a: 3, step_4_b: 3}
    assert state.states == %{step_2: %{}, step_3: %{}, step_4_a: %{}, step_4_b: %{}}
  end

  test "run_step/2 returns stop if one inner step returns stop too" do
    state = %{results: %{step_1: 2}, states: %{step_1: %{}}}

    step = [
      {Step1WithState, %{input: :step_1, name: :step_1_with_state}},
      {Step3, %{input: :step_1, name: :step_3}}
    ]

    {value, state} = Parallel.run_step(state, step)

    assert value == :stop

    assert state.results == %{step_1: 2, step_3: 5, step_1_with_state: :stop}
    assert state.states == %{step_1: %{}, step_3: %{}, step_1_with_state: %{last: 2}}
  end

  test "run_step/2 returns error if one inner step returns error too" do
    state = %{results: %{step_1: 2}, states: %{step_1: %{}}}

    step = [
      {Step1WithError, %{input: :step_1, name: :step_1_with_error}},
      {Step3, %{input: :step_1, name: :step_3}}
    ]

    {value, state} = Parallel.run_step(state, step)

    assert value == {:error, :some_reason}

    assert state.results == %{step_1: 2, step_3: 5, step_1_with_error: {:error, :some_reason}}
    assert state.states == %{step_1: %{}, step_3: %{}, step_1_with_error: %{}}
  end
end
