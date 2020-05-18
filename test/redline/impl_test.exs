defmodule Test.Redline.ImplTest do
  alias Redline.Impl

  alias Test.Redline.Steps

  use ExUnit.Case

  test "run/2 runs the steps with input" do
    steps = [
      {:step, Steps.Step1, %{name: :step_1}},
      {:step, Steps.Step2, %{input: :step_1, name: :step_2}}
    ]

    {value, state} = Impl.run(1, steps)

    assert value == 4

    assert state.results == %{step_1: 2, step_2: 4}
    assert state.states == %{step_1: %{}, step_2: %{}}
  end

  test "run/2 runs with parallel steps" do
    steps = [{:step, [{Steps.Step2, %{name: :step_2}}, {Steps.Step3, %{name: :step_3}}]}]

    {value, state} = Impl.run(1, steps)

    assert value == [3, 4]

    assert state.results == %{step_2: 3, step_3: 4}
    assert state.states == %{step_2: %{}, step_3: %{}}
  end

  test "run/2 runs with parallel steps with input" do
    steps = [
      {:step, Steps.Step1, %{name: :step_1}},
      {:step,
       [
         {Steps.Step2, %{input: :step_1, name: :step_2}},
         {Steps.Step3, %{input: :step_1, name: :step_3}}
       ]}
    ]

    {value, state} = Impl.run(1, steps)

    assert value == [4, 5]

    assert state.results == %{step_1: 2, step_2: 4, step_3: 5}
    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}}
  end

  test "run/2 runs with multiple inputs" do
    steps = [
      {:step,
       [
         {Steps.Step2, %{name: :step_2}},
         {Steps.Step3, %{name: :step_3}}
       ]},
      {:step, Steps.Step4, %{inputs: [:step_2, :step_3], name: :step_4}}
    ]

    {value, state} = Impl.run(1, steps)

    assert value == 7

    assert state.results == %{step_2: 3, step_3: 4, step_4: 7}
    assert state.states == %{step_2: %{}, step_3: %{}, step_4: %{}}
  end

  test "run/3 runs the steps with input and state" do
    steps = [
      {:step, Test.Redline.Steps.Step1, %{name: :step_1}},
      {:step, Test.Redline.Steps.Step2, %{input: :step_1, name: :step_2}}
    ]

    state = %{results: %{step_1: 2, step_2: 4}, states: %{step_1: %{}, step_2: %{}}}

    {value, state} = Impl.run(2, state, steps)

    assert value == 5

    assert state.results == %{step_1: 3, step_2: 5}
    assert state.states == %{step_1: %{}, step_2: %{}}
  end

  test "run/3 runs with parallel steps" do
    steps = [{:step, [{Steps.Step2, %{name: :step_2}}, {Steps.Step3, %{name: :step_3}}]}]

    state = %{results: %{step_2: 3, step_3: 4}, states: %{step_2: %{}, step_3: %{}}}

    {value, state} = Impl.run(1, state, steps)

    assert value == [3, 4]

    assert state.results == %{step_2: 3, step_3: 4}
    assert state.states == %{step_2: %{}, step_3: %{}}
  end

  test "run/3 runs with parallel steps with input" do
    steps = [
      {:step, Steps.Step1, %{name: :step_1}},
      {:step,
       [
         {Steps.Step2, %{input: :step_1, name: :step_2}},
         {Steps.Step3, %{input: :step_1, name: :step_3}}
       ]}
    ]

    state = %{
      results: %{step_1: 2, step_2: 4, step_3: 5},
      states: %{step_1: %{}, step_2: %{}, step_3: %{}}
    }

    {value, state} = Impl.run(1, state, steps)

    assert value == [4, 5]

    assert state.results == %{step_1: 2, step_2: 4, step_3: 5}
    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}}
  end

  test "run/3 runs with multiple inputs" do
    steps = [
      {:step,
       [
         {Steps.Step2, %{name: :step_2}},
         {Steps.Step3, %{name: :step_3}}
       ]},
      {:step, Steps.Step4, %{inputs: [:step_2, :step_3], name: :step_4}}
    ]

    state = %{
      results: %{step_2: 3, step_3: 4, step_4: 7},
      states: %{step_2: %{}, step_3: %{}, step_4: %{}}
    }

    {value, state} = Impl.run(1, state, steps)

    assert value == 7

    assert state.results == %{step_2: 3, step_3: 4, step_4: 7}
    assert state.states == %{step_2: %{}, step_3: %{}, step_4: %{}}
  end
end
