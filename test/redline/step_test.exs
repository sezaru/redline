defmodule Test.Redline.StepTest do
  alias Test.Redline.Steps

  use ExUnit.Case

  defmodule Step do
    use Redline.Step, name: :step, input: :some_input, state: %{some: :state}

    @impl Redline.Step
    def run(input, state), do: {input, state}
  end

  test "__using__/1 creates a new pipeline" do
    assert Step.name() == :step
    assert Step.new() == %{some: :state}
    assert Step.options() == [name: :step, input: :some_input]
  end

  test "new/0 returns the step state" do
    assert Steps.Step1.new() == %{}

    assert Steps.Step1WithState.new() == %{last: nil}
  end

  test "options/0 returns the step options" do
    assert Steps.Step1.options() == [name: :step_1]
    assert Steps.Step2.options() == [name: :step_2, input: :step_1]

    assert Steps.Step1WithState.options() == [name: :step_1]
  end

  test "name/0 returns the step name" do
    assert Steps.Step1.name() == :step_1
    assert Steps.Step2.name() == :step_2

    assert Steps.Step1WithState.name() == :step_1
  end

  test "run/1 runs the step without initial state" do
    {value, state} = Steps.Step1.run(1)

    assert value == 2
    assert state == %{}
  end

  test "run/1 runs the step with state without initial state" do
    {value, state} = Steps.Step1WithState.run(1)

    assert value == :stop
    assert state == %{last: 1}
  end

  test "run/2 runs the step" do
    state = Steps.Step1.new()

    {value, state} = Steps.Step1.run(1, state)

    assert value == 2
    assert state == %{}

    {value, state} = Steps.Step1.run(2, state)

    assert value == 3
    assert state == %{}
  end

  test "run/2 runs the step with state" do
    state = Steps.Step1WithState.new()

    {value, state} = Steps.Step1WithState.run(1, state)

    assert value == :stop
    assert state == %{last: 1}

    {value, state} = Steps.Step1WithState.run(2, state)

    assert value == 3
    assert state == %{last: 2}
  end
end
