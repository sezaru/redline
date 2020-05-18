defmodule Test.Redline.Impl.MultiInputTest do
  alias Redline.Impl.MultiInput

  alias Test.Redline.Steps.Step4

  use ExUnit.Case

  test "run_step/2 runs a step with multiple inputs" do
    state = %{
      results: %{step_1: 2, step_2: 4, step_3: 5},
      states: %{step_1: %{}, step_2: %{}, step_3: %{}}
    }

    step = {:step, Step4, %{inputs: [:step_2, :step_3], name: :step_4}}

    {value, state} = MultiInput.run_step(state, step)

    assert value == 9

    assert state.results == %{step_1: 2, step_2: 4, step_3: 5, step_4: 9}
    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}, step_4: %{}}
  end

  test "run_step/4 runs a step with multiple inputs" do
    inputs = {4, 5}
    name = :step_4
    module = Step4
    state = %{
      results: %{step_1: 2, step_2: 4, step_3: 5},
      states: %{step_1: %{}, step_2: %{}, step_3: %{}}
    }

    {value, state} = MultiInput.run_step(inputs, name, module, state)
    
    assert value == 9
    assert state == %{}
  end
end
