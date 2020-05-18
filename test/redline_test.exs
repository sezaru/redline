defmodule Test.RedlineTest do
  alias Redline.Errors.CompilationError

  alias Test.Redline.Pipelines.{Pipeline1, Pipeline2}

  use ExUnit.Case

  test "__using__/1 creates a new pipeline" do
    defmodule TestPipeline1 do
      alias Test.Redline.Steps.Step1

      use Redline, name: :pipeline, input: :some_input

      step Step1, input: :some_input
    end

    assert TestPipeline1.name() == :pipeline
    assert TestPipeline1.new() == %{results: %{}, states: %{}}
    assert TestPipeline1.options() == [name: :pipeline, input: :some_input]
  end

  test "__using__/1 creates a new pipeline with multiple inputs" do
    defmodule TestPipeline2 do
      alias Test.Redline.Steps.Step1

      use Redline, name: :pipeline, inputs: [:lhs, :rhs]

      step Step1, name: :step_1_a, input: :lhs
      step Step1, name: :step_1_b, input: :rhs
    end

    assert TestPipeline2.name() == :pipeline
    assert TestPipeline2.new() == %{results: %{}, states: %{}}
    assert TestPipeline2.options() == [name: :pipeline, inputs: [:lhs, :rhs]]
  end

  test "__using__/1 raises if pipeline has duplicated step names" do
    assert_raise CompilationError, fn ->
      defmodule TestPipeline3 do
        alias Test.Redline.Steps.Step1

        use Redline, name: :pipeline

        step Step1, name: :step_1
        step Step1, name: :step_1
      end
    end
  end

  test "__using__/1 raises if pipeline has initial_input name" do
    assert_raise CompilationError, fn ->
      defmodule TestPipeline4 do
        alias Test.Redline.Steps.Step1

        use Redline, name: :pipeline

        step Step1, name: :initial_input
      end
    end
  end

  test "__using__/1 raises if some step input is missing" do
    assert_raise CompilationError, fn ->
      defmodule TestPipeline5 do
        alias Test.Redline.Steps.Step1

        use Redline, name: :pipeline

        step Step1, input: :missing_step
      end
    end
  end

  test "__using__/1 raises if one of step inputs is missing" do
    assert_raise CompilationError, fn ->
      defmodule TestPipeline6 do
        alias Test.Redline.Steps.Step4

        use Redline, name: :pipeline

        step Step4, inputs: [:initial_input, :missing_step]
      end
    end
  end

  test "__using__/1 raises if some inner_step input is missing" do
    assert_raise CompilationError, fn ->
      defmodule TestPipeline7 do
        alias Test.Redline.Steps.Step1

        use Redline, name: :pipeline

        step [Step1, {Step1, name: :step_1_b, input: :missing_step}]
      end
    end
  end

  test "new/0 returns the pipeline state" do
    assert Pipeline1.new() == %{results: %{}, states: %{}}

    assert Pipeline2.new() == %{results: %{}, states: %{}}
  end

  test "run/1 runs pipeline" do
    assert {value, state} = Pipeline1.run(1)

    assert value == 9

    assert state.results == %{
             step_1: 2,
             step_2: 4,
             step_3: 5,
             step_4: 9,
             step_1_b: 3,
             initial_input: 1
           }

    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}, step_4: %{}, step_1_b: %{}}

    assert {value, state} = Pipeline2.run(1)

    assert value == :stop

    assert state.results == %{step_a: 2, step_b: 2, step_1: :stop, step_4: 4, initial_input: 1}
    assert state.states == %{step_a: %{}, step_b: %{}, step_1: %{last: 2}, step_4: %{}}
  end

  test "run/2 runs pipeline" do
    state = Pipeline1.new()

    assert {value, state} = Pipeline1.run(1, state)

    assert value == 9

    assert state.results == %{
             step_1: 2,
             step_2: 4,
             step_3: 5,
             step_4: 9,
             step_1_b: 3,
             initial_input: 1
           }

    assert state.states == %{step_1: %{}, step_2: %{}, step_3: %{}, step_4: %{}, step_1_b: %{}}

    state = Pipeline2.new()

    assert {value, state} = Pipeline2.run(1, state)

    assert value == :stop

    assert state.results == %{step_a: 2, step_b: 2, step_1: :stop, step_4: 4, initial_input: 1}
    assert state.states == %{step_a: %{}, step_b: %{}, step_1: %{last: 2}, step_4: %{}}

    assert {value, state} = Pipeline2.run(2, state)

    assert value == [5, 6]

    assert state.results == %{step_a: 3, step_b: 3, step_1: 5, step_4: 6, initial_input: 2}
    assert state.states == %{step_a: %{}, step_b: %{}, step_1: %{last: 3}, step_4: %{}}
  end
end
