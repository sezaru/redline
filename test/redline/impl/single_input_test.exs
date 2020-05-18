defmodule Test.Redline.Impl.SingleInputTest do
  alias Redline.Impl.SingleInput

  alias Test.Redline.Steps.{Step1, Step2}

  use ExUnit.Case

  test "run_step/2 runs a step with single input" do
    state = %{results: %{step_1: 2}, states: %{step_1: %{}}}

    step = {:step, Step2, %{name: :step_2, input: :step_1}}

    {value, state} = SingleInput.run_step(state, step)

    assert value == 4

    assert state.results == %{step_1: 2, step_2: 4}
    assert state.states == %{step_1: %{}, step_2: %{}}
  end

  test "run_step/4 runs a step with multiple inputs" do
    inputs = 1
    name = :step_1
    module = Step1
    state = %{results: %{}, states: %{}}

    {value, state} = SingleInput.run_step(inputs, name, module, state)

    assert value == 2
    assert state == %{}
  end
end
